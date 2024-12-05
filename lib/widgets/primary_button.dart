import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback press;
  final Color? color;
  final Color textColor;
  final BorderRadius borderRadius;
  final double elevation;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.press,
    this.color,
    this.textColor = Colors.white,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.elevation = 2,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: press,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Theme.of(context).primaryColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18), // Increased padding
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
        ),
        elevation: elevation,
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 18, color: textColor), // Increased font size
      ),
    );
  }
}
