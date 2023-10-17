import 'package:flutter/material.dart';
import 'package:app_transprogresochoco/models/UserModel.dart';
import 'package:app_transprogresochoco/controllers/AdminController.dart';

class EditUserScreen extends StatefulWidget {
  final String uid;
  final UserModel user;

  EditUserScreen({required this.uid, required this.user});

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final AdminController _adminController = AdminController();
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneNumberController =
        TextEditingController(text: widget.user.phoneNumber);
    _passwordController =
        TextEditingController(); // No muestres la contraseña actual
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updateUser() async {
    final updatedUser = UserModel(
      uid: widget.user.uid,
      fullName: _fullNameController.text,
      email: _emailController.text,
      phoneNumber: _phoneNumberController.text,
      profilePicture: widget.user.profilePicture,
      isAdmin: widget.user.isAdmin,
      password: _passwordController.text,
    );

    try {
      await _adminController.updateUser(updatedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Usuario actualizado con éxito.'),
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.of(context).pop(); // Regresa a la pantalla anterior
    } catch (e) {
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
            _buildTextField(_fullNameController, 'Nombre Completo'),
            _buildTextField(_emailController, 'Correo Electrónico'),
            _buildTextField(_phoneNumberController, 'Número de Teléfono'),
            _buildPasswordTextField(_passwordController, 'Nueva Contraseña'),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _updateUser,
              child: Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildPasswordTextField(
      TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        obscureText: true,
      ),
    );
  }
}
