import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30.0, // Ajusta la altura
      color: Colors.black,
      child: Center(
        child: Text(
          'Transprogreso Choco Ltda ©2023.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }
}
