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
        child: Form(
          key: _formKey,
          child: Column(
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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.black.withOpacity(0.5),
          ),
          padding: const EdgeInsets.all(16.0),
          child: CircleAvatar(
            backgroundColor: Colors.black,
            radius: 64,
            child: Icon(
              _profilePicture == null ? Icons.person : null,
              size: 64,
              color: Colors.white,
            ),
            backgroundImage:
                _profilePicture != null ? FileImage(_profilePicture!) : null,
          ),
        ),
        SizedBox(height: 16.0),
        Container(
          margin: EdgeInsets.all(10.0),
          child: ElevatedButton.icon(
            onPressed: _selectProfilePicture,
            style: ElevatedButton.styleFrom(
              primary: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            icon: Icon(Icons.camera_alt, color: Colors.white),
            label: Text(
              'Seleccionar Foto de Perfil',
              style: TextStyle(color: Colors.white),
            ),
          ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.black),
          labelStyle: TextStyle(color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, ingresa un valor válido';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextFormField(
        controller: _passwordController,
        decoration: InputDecoration(
          labelText: 'Contraseña',
          prefixIcon: Icon(Icons.lock, color: Colors.black),
          labelStyle: TextStyle(color: Colors.black),
          suffixIcon: IconButton(
            icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _showPassword = !_showPassword;
              });
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        obscureText: !_showPassword,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, ingresa una contraseña válida';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildAddUserButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ElevatedButton(
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
        style: ElevatedButton.styleFrom(
          primary: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: Text(
          'Guardar Usuario',
          style: TextStyle(color: Colors.white),
        ),
      ),
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
