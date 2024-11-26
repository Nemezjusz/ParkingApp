import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:logger/logger.dart';

class TimePickerFieldBlocBuilder extends StatelessWidget {
  final TextFieldBloc fieldBloc;
  final InputDecoration decoration;

  const TimePickerFieldBlocBuilder({
    super.key,
    required this.fieldBloc,
    required this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return TextFieldBlocBuilder(
      textFieldBloc: fieldBloc,
      decoration: decoration,
      readOnly: true,
      onTap: () async {
        TimeOfDay initialTime = TimeOfDay.now();
        if (fieldBloc.value.isNotEmpty) {
          final parts = fieldBloc.value.split(':');
          if (parts.length == 2) {
            initialTime = TimeOfDay(
              hour: int.parse(parts[0]),
              minute: int.parse(parts[1]),
            );
          }
        }

        Logger logger = Logger();

        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: initialTime,
        );

        if (pickedTime != null) {
          final now = DateTime.now();
          final dt = DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
          final formattedTime = DateFormat('HH:mm').format(dt);
          fieldBloc.updateValue(formattedTime);
          logger.i('Picked Time: $formattedTime');
        }
      },
      style: TextStyle(
        color: fieldBloc.value.isNotEmpty ? Colors.black : Colors.grey,
      ),
    );
  }
}
