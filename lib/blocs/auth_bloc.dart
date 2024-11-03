import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoggedIn>((event, emit) {
      emit(Authenticated(event.token));
    });

    on<LoggedOut>((event, emit) {
      emit(Unauthenticated());
    });
  }
}
