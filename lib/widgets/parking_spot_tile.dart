import 'package:flutter/material.dart';

class ParkingSpotTile extends StatelessWidget {
  final String id;
  final Color color;

  const ParkingSpotTile({super.key, required this.id, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          id,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
