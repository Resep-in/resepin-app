class RoutesApi {
  static const String baseUrl = 'https://senoaji.daffahmad.my.id/firdaus';

  // auth
  static String loginUrl() => '$baseUrl/login';
  static String registerUrl() => '$baseUrl/register';
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
  static String recommendUrl() => '$baseUrl/recipe/recommend';
  static String predictUrl() => '$baseUrl/recipe/predict';
  static String detailUrl(int recipeId) => '$baseUrl/recipe/bookmark/detail/$recipeId';
}