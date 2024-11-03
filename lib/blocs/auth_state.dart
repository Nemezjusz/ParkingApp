class AuthState {
  final bool isAuthenticated;
  final String? token;

  AuthState({
    required this.isAuthenticated,
    this.token,
  });
}

class AuthInitial extends AuthState {
  AuthInitial() : super(isAuthenticated: false);
}

class Authenticated extends AuthState {
  Authenticated(String token)
      : super(isAuthenticated: true, token: token);
}

class Unauthenticated extends AuthState {
  Unauthenticated() : super(isAuthenticated: false);
}
