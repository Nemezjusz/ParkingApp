import 'package:flutter/material.dart';
import 'package:smart_parking/constants/constants.dart';

class CustomTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const CustomTitle({
    Key? key,
    required this.icon,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 4),
          child: Row(
            children: [
              Icon(icon, color: iconAccentColor),
              SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const Divider(color: dividerColor),
      ],
    );
  }
}
