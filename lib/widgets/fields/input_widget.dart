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
    return TextFieldBlocBuilder(
      textFieldBloc: fieldBloc,
      autofocus: false,
      readOnly: isReadOnly,
      autofillHints: autofillHints,
      keyboardType: textInputType,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      style: const TextStyle(fontSize: 16),
    );
  }
}
