
class AuthUser {
  final String fullName;
  final String email;
  final String role;

  AuthUser({
    required this.fullName,
    required this.email,
    required this.role,
  });
}

class AuthService {
  // TEMPORARY ACCOUNTS FOR TESTING
  static final List<Map<String, String>> _users = [];

  // REGISTER
  static Future<String?> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    // Check if email already exists
    final existingUser = _users.any(
      (user) => user['email'] == normalizedEmail,
    );

    if (existingUser) {
      return 'This email is already registered.';
    }

    // Save temporary account
    _users.add({
      'fullName': fullName.trim(),
      'email': normalizedEmail,
      'password': password,
      'role': role,
    });

    return null;
  }

  // LOGIN
  static Future<AuthUser?> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    for (final user in _users) {
      if (user['email'] == normalizedEmail &&
          user['password'] == password) {
        return AuthUser(
          fullName: user['fullName']!,
          email: user['email']!,
          role: user['role']!,
        );
      }
    }

    return null;
  }
}
