class Routes {
  static const String root = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String mediaLibraryDetail = '/media-library'; // 需要拼接 /:id
  static const String profileEdit = '/profile/edit';
  static const String settings = '/settings';
  static const String uploadList = '/upload';
  static const String uploadEdit = '/upload/edit'; // 可拼接 /:id
  static const String bookDetail = '/book'; // 需传递参数 id
  static const String readerPage = "/reader";
}
