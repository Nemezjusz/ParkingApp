import 'package:flutter/material.dart';
import 'package:smart_parking/constants/constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: primaryColor,
      elevation: 6.0,
      title: Row(
        children: [
          Icon(Icons.local_parking, color: Colors.white),
          SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
      leading: IconButton(
        icon: Icon(Icons.refresh),
        onPressed: () {
          print("Refresh Parking Map");
        },
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey[700],
            child: Icon(Icons.person, color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
