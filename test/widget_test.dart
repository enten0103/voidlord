// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voidlord/main.dart';
import 'package:get/get.dart';
import 'package:voidlord/services/auth_service.dart';

void main() {
  testWidgets('Login flow navigates to root', (WidgetTester tester) async {
    Get.testMode = true;
    // 测试环境需要手动注册全局服务
    Get.put<AuthService>(AuthService(), permanent: true);
    await tester.pumpWidget(const MyApp());

    // 初始为登录页
    expect(find.text('登录'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('usernameField')), 'user');
    await tester.enterText(find.byKey(const Key('passwordField')), 'pass');

    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pump();
    // 可能有加载动画，等待动画完成并路由跳转
    await tester.pumpAndSettle();

    // 到达 RootPage
    expect(find.text('应用主体'), findsWidgets);

    // 登出返回登录页
    await tester.tap(find.byKey(const Key('logoutButton')));
    await tester.pumpAndSettle();
    expect(find.text('登录'), findsOneWidget);

    // 确认服务状态
    final auth = Get.find<AuthService>();
    expect(auth.loggedIn.value, false);
  });
}
