class RoutesApi {
  static const String baseUrl = 'https://senoaji.daffahmad.my.id/firdaus';

  // auth
  static String loginUrl() => '$baseUrl/login';
  static String userUrl() => '$baseUrl/user';
  static String logoutUrl() => '$baseUrl/logout';

  // user
  static String editProfileUrl() => '$baseUrl/user/profile/edit';
  static String changePasswordUrl() => '$baseUrl/user/password/change';

  // bookmark
  static String addBookmarkUrl() => '$baseUrl/recipe/bookmark/add';
  static String removeBookmarkUrl() => '$baseUrl/recipe/bookmark/remove';
  static String listBookmarkUrl() => '$baseUrl/recipe/bookmark/list';

  // recipe
  static String healthCheckUrl() => '$baseUrl/recipe/predict/health-check';
  static String predicUrl() => '$baseUrl/recipe/predict';
}