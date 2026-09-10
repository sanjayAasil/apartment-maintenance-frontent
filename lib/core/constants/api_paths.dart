abstract final class ApiPaths {
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const me = '/auth/me';
  static const users = '/users';

  static String user(String id) => '/users/$id';
  static String userStatus(String id) => '/users/$id/status';

  static const publicPaths = {login, register};
}
