import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_transprogresochoco/controllers/UserController.dart';
import 'package:app_transprogresochoco/models/UserModel.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final UserController _userController = UserController();
  String? _errorMessage;
  String? _profilePicture;
  bool _loading = false;
  bool _isPasswordVisible = false;

  Future<void> _register() async {
    final String fullName = _fullNameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String phoneNumber = _phoneNumberController.text;

    if (_profilePicture != null) {
      _showLoadingIndicator();

      final UserModel? registeredUser = await _userController.registerUser(
        context,
        email,
        password,
        fullName,
        phoneNumber,
      );

      _hideLoadingIndicator();

      if (registeredUser != null) {
        // Registration successful
        // Navigate to the next screen or perform necessary actions here.
      } else {
        setState(() {
          _errorMessage =
              'Error al registrar usuario. Por favor, inténtalo de nuevo.';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Debes seleccionar una foto de perfil.';
      });
    }
  }

  Future<void> _pickProfilePicture() async {
    final imagePicker = ImagePicker();
    final XFile? pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _profilePicture = pickedFile.path;
      });
    }
  }

  void _showLoadingIndicator() {
    setState(() {
      _loading = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16.0),
              Text('Registrando...'),
            ],
          ),
        );
      },
    );
  }

  void _hideLoadingIndicator() {
    setState(() {
      _loading = false;
    });

    Navigator.of(context).pop(); // Close the AlertDialog
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'Registro de Usuario',
        style: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      backgroundColor: Color(0xFF123456),
      elevation: 0.0,
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            _buildLogo(),
            SizedBox(height: 5.0),
            _buildTextField(
              _fullNameController,
              'Nombre Completo',
              Icons.person_outline_rounded,
            ),
            SizedBox(height: 14.0),
            _buildTextField(
              _emailController,
              'Correo Electrónico',
              Icons.email_outlined,
            ),
            SizedBox(height: 14.0),
            _buildPasswordField(
              _passwordController,
              'Contraseña',
              Icons.lock_outline,
            ),
            SizedBox(height: 14.0),
            _buildTextField(
              _phoneNumberController,
              'Número de Teléfono',
              Icons.phone_outlined,
            ),
            SizedBox(height: 24.0),
            _buildProfilePictureSelector(),
            SizedBox(height: 12.0),
            _buildRegisterButton(),
            SizedBox(height: 12.0),
            if (_errorMessage != null)
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

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/logo.png',
      width: 250.0,
      height: 250.0,
      fit: BoxFit.contain,
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String labelText, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(
          icon,
          color: Colors.blue,
        ),
        fillColor: Colors.grey[200],
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.all(16.0),
      ),
      style: TextStyle(
        fontSize: 16.0,
        color: Colors.black,
      ),
    );
  }

  Widget _buildPasswordField(
      TextEditingController controller, String labelText, IconData icon) {
    return TextFormField(
      controller: controller,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(
          icon,
          color: Colors.blue,
        ),
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
          child: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.blue,
          ),
        ),
        fillColor: Colors.grey[200],
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.all(16.0),
      ),
      style: TextStyle(
        fontSize: 16.0,
        color: Colors.black,
      ),
    );
  }

  Widget _buildProfilePictureSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seleccionar Foto de Perfil',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.0),
        GestureDetector(
          onTap: _pickProfilePicture,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.blue,
                  size: 20.0,
                ),
                SizedBox(width: 8.0),
                Text(
                  'Seleccionar desde Galería',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_profilePicture != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Foto de Perfil seleccionada: $_profilePicture',
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: _register,
      style: ElevatedButton.styleFrom(
        primary: Color(0xFF0D9276),
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        shadowColor: Colors.black38,
        elevation: 8.0,
      ),
      child: _loading
          ? CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
          : Text(
              'Registrarse',
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.white,
              ),
            ),
    );
  }
}
