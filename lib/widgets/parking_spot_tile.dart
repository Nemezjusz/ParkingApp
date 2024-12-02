import 'package:flutter/material.dart';

class ParkingSpotTile extends StatelessWidget {
  final String id;
  final String status;
  final VoidCallback onTap;

  const ParkingSpotTile({
    Key? key,
    required this.id,
    required this.status,
    required this.onTap,
    required MaterialColor color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Określenie koloru na podstawie statusu
    Color borderColor;

    switch (status.toLowerCase()) {
      case 'free':
        borderColor = Colors.green;
        break;
      case 'reserved':
        borderColor = Colors.grey;
        break;
      case 'occupied':
        borderColor = Colors.red;
        break;
      default:
        borderColor = Colors.grey;
    }

    return GestureDetector(
      onTap: status.toLowerCase() == 'reserved' ? null : onTap, // Wyłączone tap dla zarezerwowanych
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        padding: const EdgeInsets.all(20.0),
        width: 150, // Zmniejszona szerokość
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (/*status.toLowerCase()*/ 'occupied' == 'occupied')
              Image.asset(
                height: 50,
                'assets/images/car.png', // Ścieżka do obrazka
                fit: BoxFit.contain,
              ),
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
