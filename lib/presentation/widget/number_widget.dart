import 'package:flutter/material.dart';

class NumberWidget extends StatelessWidget {
  final int number;

  NumberWidget({required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        number.toString(),
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }
}
