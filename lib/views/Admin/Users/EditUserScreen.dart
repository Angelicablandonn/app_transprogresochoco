import 'package:flutter/material.dart';
import 'package:app_transprogresochoco/models/UserModel.dart'; // Importa tu modelo de usuario aquí
import 'package:app_transprogresochoco/controllers/AdminController.dart'; // Importa tu controlador aquí

class EditUserScreen extends StatefulWidget {
  final String uid;
  final UserModel user; // Asegúrate de tener este argumento

  EditUserScreen({required this.uid, required this.user});

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final AdminController _adminController =
      AdminController(); // Instancia del controlador
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    // Inicializa los controladores de texto con los datos actuales del usuario
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneNumberController =
        TextEditingController(text: widget.user.phoneNumber);
    _passwordController = TextEditingController(text: widget.user.password);
  }

  @override
  void dispose() {
    // Libera los controladores de texto al cerrar la pantalla
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updateUser() async {
    // Actualiza el usuario con los nuevos valores
    final updatedUser = UserModel(
      uid: widget.user.uid,
      fullName: _fullNameController.text,
      email: _emailController.text,
      phoneNumber: _phoneNumberController.text,
      profilePicture: widget.user.profilePicture, // Mantén la imagen actual
      isAdmin: widget.user.isAdmin, // Mantén el estado de administrador
      password: _passwordController.text, // Actualiza la contraseña
    );

    try {
      // Llama a la función del controlador para actualizar el usuario
      await _adminController.updateUser(updatedUser);

      // Muestra un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Usuario actualizado con éxito.'),
          duration: Duration(seconds: 3),
        ),
      );

      // Navega de regreso a la pantalla anterior
      Navigator.of(context).pop();
    } catch (e) {
      // Muestra un mensaje de error si la actualización falla
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar el usuario: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Usuario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _fullNameController,
              decoration: InputDecoration(labelText: 'Nombre Completo'),
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Correo Electrónico'),
            ),
            TextFormField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: 'Número de Teléfono'),
            ),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _updateUser, // Llama a la función de actualización
              child: Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
