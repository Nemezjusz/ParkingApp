import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class InputWidget extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final TextFieldBloc fieldBloc;
  final List<String>? autofillHints;
  final bool isReadOnly;
  final TextInputType? textInputType;
  final bool obscureText;

  const InputWidget({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    required this.fieldBloc,
    this.autofillHints,
    this.isReadOnly = false,
    this.textInputType,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    // Pobranie aktualnego motywu
    final theme = Theme.of(context);

    return TextFieldBlocBuilder(
      textFieldBloc: fieldBloc,
      autofocus: false,
      readOnly: isReadOnly,
      autofillHints: autofillHints,
      keyboardType: textInputType,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(
          prefixIcon,
          color: theme.colorScheme.primary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2.0,
          ),
        ),
        filled: true,
        fillColor: theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surfaceVariant,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface,
        fontSize: 16,
      ),
      cursorColor: theme.colorScheme.primary,
    );
  }
}
