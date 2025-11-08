import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:system_fonts/system_fonts.dart' as sf;
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends GetxService {
  static const _kSeedKey = 'theme_seed_argb';
  static const _kModeKey = 'theme_mode'; // system | light | dark
  static const _kFontKey = 'theme_font_family'; // 'system' or font family name

  // 注意：使用 Rx<Color>(...) 而不是 .obs 在 MaterialColor 上，避免后续赋值普通 Color 时出现
  // “type 'Color' is not a subtype of type 'MaterialColor'” 的运行时类型冲突。
  final Rx<Color> seed = Rx<Color>(Colors.indigo);
  final Rx<ThemeMode> mode = ThemeMode.system.obs;
  final RxString fontFamily = 'system'.obs;

  ThemeData get lightTheme {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed.value,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    );
    return _applyFont(base);
  }

  ThemeData get darkTheme {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed.value,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );
    return _applyFont(base);
  }

  Future<ThemeService> init() async {
    final sp = await SharedPreferences.getInstance();
    final argb = sp.getInt(_kSeedKey);
    final modeStr = sp.getString(_kModeKey);
    final fontStr = sp.getString(_kFontKey);

    if (argb != null) {
      seed.value = Color(argb);
    }
    if (modeStr != null) {
      mode.value = _parseMode(modeStr);
    }
    if (fontStr != null && fontStr.isNotEmpty) {
      fontFamily.value = fontStr;
    }
    return this;
  }

  Future<void> applySeed(Color color) async {
    seed.value = color;
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kSeedKey, color.value);
  }

  Future<void> setMode(ThemeMode m) async {
    mode.value = m;
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kModeKey, _modeToString(m));
  }

  Future<void> applyFont(String font) async {
    String familyToUse = font;
    // 仅桌面端尝试加载系统字体，返回可用的 family 名称
    if (GetPlatform.isDesktop && font.isNotEmpty && font != 'system') {
      try {
        final loaded = await sf.SystemFonts().loadFont(font);
        if (loaded != null && loaded.isNotEmpty) {
          familyToUse = loaded;
        }
      } catch (_) {
        // 忽略加载错误，回退到传入名称/系统字体
      }
    }

    fontFamily.value = familyToUse;
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kFontKey, familyToUse);
  }

  ThemeData _applyFont(ThemeData base) {
    final f = fontFamily.value;
    if (f.isEmpty || f == 'system') return base;
    // 直接通过 ThemeData.fontFamily 应用字体族名（在桌面端通过 system_fonts 预加载）
    return base.copyWith(
      textTheme: base.textTheme.apply(fontFamily: f),
      primaryTextTheme: base.primaryTextTheme.apply(fontFamily: f),
    );
  }

  // 提供系统字体列表（仅桌面端）
  Future<List<String>> getInstalledFonts() async {
    if (!GetPlatform.isDesktop) return <String>[];
    try {
      return sf.SystemFonts().getFontList();
    } catch (_) {
      return <String>[];
    }
  }

  ThemeMode _parseMode(String s) {
    switch (s) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _modeToString(ThemeMode m) {
    switch (m) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
