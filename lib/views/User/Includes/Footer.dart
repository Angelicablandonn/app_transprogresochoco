import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Transprogreso del Choco LTDA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0, // Ajusta el tamaño del texto según sea necesario
            ),
          ),
          SizedBox(width: 10.0), // Espaciado entre el texto y el logo
          Image.asset(
            'assets/images/logo.png',
            height: 50.0,
            width: 50.0,
          ),
        ],
      ),
    );
  }
}
