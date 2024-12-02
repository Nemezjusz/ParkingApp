// abstract class AuthState {
//   final bool isAuthenticated;
//   final String? token;
//   final String? userEmail;

//   const AuthState({required this.isAuthenticated, this.token, this.userEmail});
// }

// class AuthInitial extends AuthState {
//   const AuthInitial() : super(isAuthenticated: false);
// }

// class Authenticated extends AuthState {
//   final String userEmail;

//   const Authenticated(String token, this.userEmail)
//       : super(isAuthenticated: true, token: token, userEmail: userEmail);
// }

// class Unauthenticated extends AuthState {
//   const Unauthenticated() : super(isAuthenticated: false);
// }
