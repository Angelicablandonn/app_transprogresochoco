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
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneNumberController =
        TextEditingController(text: widget.user.phoneNumber);
    _passwordController = TextEditingController();
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
    if (_formKey.currentState!.validate()) {
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

        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar el usuario: $e'),
            duration: Duration(seconds: 3),
          ),
        );
      }
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
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildLabel('Nombre Completo'),
                _buildTextField(_fullNameController, 'Nombre Completo'),
                _buildLabel('Correo Electrónico'),
                _buildTextField(_emailController, 'Correo Electrónico'),
                _buildLabel('Número de Teléfono'),
                _buildTextField(_phoneNumberController, 'Número de Teléfono'),
                _buildLabel('Nueva Contraseña'),
                _buildPasswordTextField(
                    _passwordController, 'Nueva Contraseña'),
                SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: _updateUser,
                  child: Text('Guardar Cambios'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, ingrese un valor válido';
          }
          return null;
        },
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
        validator: (value) {
          if (value != null && value.isNotEmpty && value.length < 6) {
            return 'La contraseña debe tener al menos 6 caracteres';
          }
          return null;
        },
      ),
    );
  }
}
