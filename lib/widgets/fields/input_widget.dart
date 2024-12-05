import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:smart_parking/models/parking_spot.dart';
import 'package:intl/intl.dart';

enum FieldType { text, dropdown, date }

class InputWidget<T> extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final decoration = InputDecoration(
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
      fillColor: theme.inputDecorationTheme.fillColor ??
          theme.colorScheme.surfaceVariant,
      hintStyle: theme.textTheme.bodyMedium!.copyWith(
        color: theme.textTheme.bodyMedium!.color!.withOpacity(0.6),
      ),
    );

    switch (fieldType) {
      case FieldType.dropdown:
        return DropdownSearch<T>(
          items: items ?? [],
          itemAsString: (T item) {
            if (item is ParkingSpot) {
              return item.prettyId;
            }
            return item.toString();
          },
          onChanged: (T? selectedItem) {
            if (selectedItem != null) {
              (fieldBloc as SelectFieldBloc<T, dynamic>)
                  .updateValue(selectedItem);
            }
          },
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: decoration,
          ),
          popupProps: PopupProps.menu(
            showSearchBox: true,
            constraints: const BoxConstraints(maxHeight: 300),
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          selectedItem: items != null && items!.isNotEmpty
              ? items!.first
              : null,
        );

      case FieldType.date:
        if (firstDate == null || lastDate == null) {
          throw ArgumentError(
            'Dla FieldType.date, firstDate i lastDate muszą być podane.',
          );
        }
        return DateTimeFieldBlocBuilder(
          dateTimeFieldBloc:
              fieldBloc as InputFieldBloc<DateTime, dynamic>,
          format: DateFormat('yyyy-MM-dd'),
          firstDate: firstDate!,
          lastDate: lastDate!,
          initialDate: firstDate!,
          decoration: decoration,
          textColor: MaterialStateProperty.all(theme.textTheme.titleSmall!.color),
        );

      case FieldType.text:
      default:
        return TextFieldBlocBuilder(
          textFieldBloc: fieldBloc as TextFieldBloc,
          autofocus: false,
          readOnly: isReadOnly,
          autofillHints: autofillHints,
          keyboardType: textInputType,
          // obscureText: obscureText,
          suffixButton: obscureText ? SuffixButton.obscureText : null,
          decoration: decoration,
          cursorColor: theme.colorScheme.primary,
        );
    }
  }
}
