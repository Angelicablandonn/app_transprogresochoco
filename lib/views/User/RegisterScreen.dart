import 'package:flutter/material.dart';
import 'package:app_transprogresochoco/controllers/UserController.dart';
import 'package:app_transprogresochoco/models/UserModel.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final UserController _userController = UserController();
  String? _errorMessage; // Variable para almacenar el mensaje de error

  Future<void> _register() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String fullName = _fullNameController.text;
    final String phoneNumber = _phoneNumberController.text;

    final UserModel? user = await _userController.registerUser(
      context,
      email,
      password,
      fullName,
      phoneNumber,
    );

    if (user != null) {
      // Registro exitoso, puedes navegar a la siguiente pantalla
      // o realizar las acciones necesarias aquí.
    } else {
      // Registro fallido, muestra un mensaje de error.
      setState(() {
        _errorMessage =
            'Error al registrar usuario. Por favor, inténtalo de nuevo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrarse'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _fullNameController,
              decoration: InputDecoration(labelText: 'Nombre Completo'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Correo Electrónico'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Contraseña'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: 'Número de Teléfono'),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _register,
              child: Text('Registrarse'),
            ),
            if (_errorMessage != null) // Muestra el mensaje de error si existe
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
