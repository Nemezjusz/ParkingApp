import 'package:flutter/material.dart';

class ReservationItem extends StatelessWidget {
  final String spot;
  final String status;
  final String time;
  final Color color;

  const ReservationItem({
    Key? key,
    required this.spot,
    required this.status,
    required this.time,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData statusIcon;
    switch (status) {
      case 'Reserved':
        statusIcon = Icons.access_time;
        break;
      case 'Occupied':
        statusIcon = Icons.block;
        break;
      default:
        statusIcon = Icons.check_circle;
        break;
    }

    return Card(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: ListTile(
        leading: Icon(statusIcon, color: Colors.white),
        title: Text(
          'Spot: $spot',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Status: $status\nTime: $time',
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.cancel, color: Colors.white, size: 30),
          onPressed: () {
            // Pusta funkcja anulowania rezerwacji
            print("Cancel reservation for $spot");
          },
        ),
      ),
    );
  }
}
