import 'package:flutter/material.dart';
import 'package:app_transprogresochoco/models/UserModel.dart';
import 'package:app_transprogresochoco/controllers/AdminController.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddUserView extends StatefulWidget {
  @override
  _AddUserViewState createState() => _AddUserViewState();
}

class _AddUserViewState extends State<AddUserView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AdminController _adminController = AdminController();

  File? _profilePicture;
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Usuario'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserIcon(),
              SizedBox(height: 16.0),
              _buildTextField(
                _fullNameController,
                'Nombre Completo',
                Icons.person,
              ),
              SizedBox(height: 16.0),
              _buildTextField(
                _emailController,
                'Correo Electrónico',
                Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16.0),
              _buildTextField(
                _phoneNumberController,
                'Número de Teléfono',
                Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16.0),
              _buildPasswordField(),
              SizedBox(height: 24.0),
              _buildAddUserButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserIcon() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          child: CircleAvatar(
            radius: 64,
            backgroundColor: Colors.grey[300],
            backgroundImage:
                _profilePicture != null ? FileImage(_profilePicture!) : null,
            child: _profilePicture == null
                ? Icon(Icons.person, size: 64, color: Colors.white)
                : null,
          ),
        ),
        SizedBox(height: 16.0),
        ElevatedButton.icon(
          onPressed: _selectProfilePicture,
          icon: Icon(Icons.camera_alt),
          label: Text('Seleccionar Foto de Perfil'),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, ingresa un valor válido';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        prefixIcon: Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _showPassword = !_showPassword;
            });
          },
        ),
      ),
      obscureText: !_showPassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, ingresa una contraseña válida';
        }
        return null;
      },
    );
  }

  Widget _buildAddUserButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          final String newUid =
              DateTime.now().millisecondsSinceEpoch.toString();
          final newUser = UserModel(
            uid: newUid,
            fullName: _fullNameController.text,
            email: _emailController.text,
            phoneNumber: _phoneNumberController.text,
            profilePicture: _profilePicture?.path ?? '',
            password: _passwordController.text,
          );
          _showPasswordDialog(newUser);
        }
      },
      child: Text('Guardar Usuario'),
    );
  }

  void _selectProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profilePicture = File(pickedFile.path);
      });
    }
  }

  void _showPasswordDialog(UserModel newUser) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Establecer Contraseña'),
          content: _buildPasswordField(),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () {
                final String password = _passwordController.text;
                newUser.profilePicture = _profilePicture?.path ?? '';
                _adminController.addUserWithPassword(
                    newUser, password, context);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
