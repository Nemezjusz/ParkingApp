abstract class AuthState {
  final bool isAuthenticated;
  final String? token;

  const AuthState({required this.isAuthenticated, this.token});
}

class AuthInitial extends AuthState {
  const AuthInitial() : super(isAuthenticated: false);
}

class Authenticated extends AuthState {
  @override
  final String token;
  const Authenticated(this.token) : super(isAuthenticated: true, token: token);
}

class Unauthenticated extends AuthState {
  const Unauthenticated() : super(isAuthenticated: false);
}
