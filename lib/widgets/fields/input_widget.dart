import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:intl/intl.dart';

enum FieldType { text, dropdown, date }

class InputWidget<T> extends StatefulWidget {
  final String hintText;
  final IconData prefixIcon;
  final FieldBloc fieldBloc;
  final FieldType fieldType;
  final List<T>? items;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Widget Function(BuildContext, T)? itemBuilder;
  final List<String>? autofillHints;
  final bool isReadOnly;
  final TextInputType? textInputType;
  final bool obscureText;

  const InputWidget({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    required this.fieldBloc,
    this.fieldType = FieldType.text,
    this.items,
    this.firstDate,
    this.lastDate,
    this.itemBuilder,
    this.autofillHints,
    this.isReadOnly = false,
    this.textInputType,
    this.obscureText = false,
  });

  @override
  _InputWidgetState<T> createState() => _InputWidgetState<T>();
}

class _InputWidgetState<T> extends State<InputWidget<T>> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final decoration = InputDecoration(
      hintText: widget.hintText,
      prefixIcon: Icon(
        widget.prefixIcon,
        color: theme.colorScheme.primary,
      ),
      suffixIcon: widget.obscureText
          ? IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                color: theme.colorScheme.primary.withOpacity(0.7),
              ),
              onPressed: _toggleObscureText,
            )
          : null,
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
      fillColor:
          theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surfaceVariant,
      hintStyle: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(0.6),
      ),
    );

    switch (widget.fieldType) {
      case FieldType.dropdown:
        return DropdownFieldBlocBuilder<T>(
          selectFieldBloc: widget.fieldBloc as SelectFieldBloc<T, dynamic>,
          decoration: decoration,
          itemBuilder: (context, value) => FieldItem(
            child: widget.itemBuilder != null
                ? widget.itemBuilder!(context, value)
                : Text(value.toString()),
          ),
        );
      case FieldType.date:
        if (widget.firstDate == null || widget.lastDate == null) {
          throw ArgumentError(
            'For FieldType.date, firstDate and lastDate must be provided.',
          );
        }
        return DateTimeFieldBlocBuilder(
          dateTimeFieldBloc: widget.fieldBloc as InputFieldBloc<DateTime, dynamic>,
          format: DateFormat('yyyy-MM-dd'),
          firstDate: widget.firstDate!,
          lastDate: widget.lastDate!,
          initialDate: widget.firstDate!,
          decoration: decoration,
        );
      case FieldType.text:
      default:
        return TextFieldBlocBuilder(
          textFieldBloc: widget.fieldBloc as TextFieldBloc,
          autofocus: false,
          readOnly: widget.isReadOnly,
          autofillHints: widget.autofillHints,
          keyboardType: widget.textInputType,
          obscureText: _obscureText,
          decoration: decoration,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontSize: 16,
          ),
          cursorColor: theme.colorScheme.primary,
        );
    }
  }
}
