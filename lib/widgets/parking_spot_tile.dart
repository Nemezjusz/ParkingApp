import 'package:flutter/material.dart';

class ParkingSpotTile extends StatelessWidget {
  final String id;
  final String color;
  final VoidCallback onTap;

  const ParkingSpotTile({
    Key? key,
    required this.id,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine border color based on the status
    Color borderColor;
    Widget? icon;

    switch (color.toLowerCase()) {
      case 'green':
        borderColor = Colors.green;
        break;
      case 'yellow':
        borderColor = Colors.yellow.shade700;
        break;
      case 'red':
      case 'red_blink':
      case 'blue':
        borderColor = Colors.red;
        icon = Image.asset(
          'assets/images/car.png', // Path to the car image
          height: 40,
          fit: BoxFit.contain,
        );
        break;
      default:
        borderColor = Colors.grey;
    }

    return GestureDetector(
      onTap: color.toLowerCase() == 'occupied' ? null : onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        padding: const EdgeInsets.all(16.0),
        width: 140,
        height:96,
        decoration: BoxDecoration(
          color: borderColor.withOpacity(0.1),
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) icon,
            Text(
              id,
              style: TextStyle(
                color: borderColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
