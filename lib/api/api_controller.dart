class RoutesApi {
  static const String baseUrl = 'https://senoaji.daffahmad.my.id/firdaus';

  // auth
  static String loginUrl() => '$baseUrl/login';
  static String userUrl() => '$baseUrl/user';
  static String logoutUrl() => '$baseUrl/logout';
}