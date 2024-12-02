import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final double iconSize;
  final TextStyle? titleStyle;
  final Widget? trailing; // Opcjonalny widget po prawej stronie

  const SectionHeader({
    Key? key,
    required this.icon,
    required this.title,
    this.iconSize = 24.0,
    this.titleStyle,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = GoogleFonts.poppins(
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Równomierne rozmieszczenie
      crossAxisAlignment: CrossAxisAlignment.center, // Wyśrodkowanie w pionie
      children: [
        Row(
          children: [
            Icon(icon, size: iconSize),
            const SizedBox(width: 10),
            Text(
              title,
              style: titleStyle ?? defaultTextStyle,
            ),
          ],
        ),
        if (trailing != null) trailing!, // Wyświetl trailing, jeśli podano
      ],
    );
  }
}
