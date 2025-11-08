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
