abstract class AuthEvent {}

class LoggedIn extends AuthEvent {
  final String token;
  final String userEmail;

  LoggedIn(this.token, this.userEmail);
}

class LoggedOut extends AuthEvent {}
