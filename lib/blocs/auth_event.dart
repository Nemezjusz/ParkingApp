abstract class AuthEvent {}

class LoggedIn extends AuthEvent {
  final String token;
  LoggedIn(this.token);
}

class LoggedOut extends AuthEvent {}
