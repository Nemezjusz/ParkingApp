import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:smart_parking/blocs/login_form_bloc.dart';
import 'package:smart_parking/navigation/app_router_paths.dart';
import 'package:smart_parking/widgets/dialogs/loading_dialog.dart';
import 'package:smart_parking/widgets/fields/input_widget.dart';
import 'package:smart_parking/widgets/primary_button.dart';
import 'package:smart_parking/constants/constants.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginFormBloc(),
      child: Builder(
        builder: (context) {
          final loginFormBloc = context.read<LoginFormBloc>();

          return Scaffold(
            resizeToAvoidBottomInset: true,
            body: FormBlocListener<LoginFormBloc, String, String>(
              onSubmitting: (context, state) {
                LoadingDialog.show(context);
              },
              onSuccess: (context, state) async {
                LoadingDialog.hide(context);

                // Przekierowanie po zalogowaniu.
                context.go(AppRouterPaths.views);
              },
              onFailure: (context, state) {
                LoadingDialog.hide(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.failureResponse!)),
                );
              },
              onLoading: (context, state) {
                LoadingDialog.show(context);
              },
              onSubmissionFailed: (context, state) {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Check your credentials and try again!"),
                  ),
                );
              },
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: kDefaultPadding),
                        Center(
                          child: Image.asset(
                            "assets/images/logo.png",
                            scale: 1,
                          ),
                        ),
                        const SizedBox(height: kDefaultPadding),
                        Text(
                          "Sign in to your account",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: kDefaultPadding),
                        InputWidget(
                          hintText: "Email",
                          prefixIcon: Icons.email_outlined,
                          textInputType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          fieldBloc: loginFormBloc.email,
                        ),
                        InputWidget(
                          hintText: "Password",
                          prefixIcon: Icons.lock_outlined,
                          obscureText: true,
                          textInputType: TextInputType.visiblePassword,
                          autofillHints: const [AutofillHints.password],
                          fieldBloc: loginFormBloc.password,
                        ),
                        const SizedBox(height: kDefaultPadding),
                        PrimaryButton(
                          text: "Sign In",
                          press: () => loginFormBloc.submit(),
                        ),
                        const SizedBox(height: kDefaultPadding * 2),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
