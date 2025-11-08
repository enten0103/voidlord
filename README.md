# voidlord

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## 路由与结构（GetX）

本项目基于 GetX 提供最简路由与登录示例：

- 路由
	- `/login` 登录页（未登录默认跳转到此）
	- `/` 应用主体 Root 页（通过中间件拦截，未登录会被重定向到 `/login`）
- 关键文件
	- `lib/main.dart`：入口，注册 `AuthService` 并使用 `GetMaterialApp`
	- `lib/routes/app_routes.dart`：路由常量
	- `lib/routes/app_pages.dart`：路由表与鉴权中间件
	- `lib/services/auth_service.dart`：登录状态服务（内存模拟）
	- `lib/pages/login_page.dart`：登录页（输入用户名/密码后登录）
	- `lib/pages/root_page.dart`：主体页（右上角可注销）

## 运行

Windows PowerShell 示例：

```powershell
flutter pub get
flutter run
```

## 测试

包含一个基本的登录-跳转-登出流程测试：

```powershell
flutter test
```

## 构建时环境（env/build config）

本项目提供基于 `--dart-define` 的构建期常量注入能力，集中在 `lib/config/app_environment.dart`：

- 变量
	- `FLAVOR`：环境标识（如 dev/test/prod），默认 `dev`
	- `BACKEND_BASE_URL`：后端基础地址，默认 `http://localhost:8080`
	- `SENTRY_DSN`：可选的 DSN，默认空字符串
- 使用位置
	- `BackendService` 会读取 `AppEnvironment.baseUrl` 作为统一的后端地址来源
	- 入口处会注入 `BackendService` 到 GetX 容器

示例：

Windows（开发运行）：

```powershell
flutter run -d windows --dart-define=FLAVOR=dev --dart-define=BACKEND_BASE_URL=http://127.0.0.1:8080
```

Android（打包）：

```powershell
flutter build apk --release --dart-define=FLAVOR=prod --dart-define=BACKEND_BASE_URL=https://api.example.com
```

Web：

```powershell
flutter run -d chrome --dart-define=FLAVOR=test --dart-define=BACKEND_BASE_URL=https://staging.example.com
```

注意：`String.fromEnvironment` 是编译期常量机制，修改值需重新构建/运行。
