Future<void> _register() async {
  final String fullName = _fullNameController.text;
  final String email = _emailController.text;
  final String password = _passwordController.text;
  final String phoneNumber = _phoneNumberController.text;

  try {
    // Verifica si _profilePicture tiene una ruta válida.
    if (_profilePicture == null) {
      throw 'Debes seleccionar una foto de perfil.';
    }

    // Muestra un indicador de carga durante el registro.
    showLoadingIndicator();

    final UserModel user = UserModel(
      uid: '', // Puedes asignar un valor por defecto si es necesario
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      profilePicture: _profilePicture,
      password: password,
    );

    final UserModel? registeredUser = await _userController.registerUser(
      context,
      email,
      password,
      fullName,
      phoneNumber,
    );

    if (registeredUser != null) {
      // Registro exitoso, puedes navegar a la siguiente pantalla
      // o realizar las acciones necesarias aquí.
    } else {
      // Registro fallido, muestra un mensaje de error.
      showError('Error al registrar usuario. Por favor, inténtalo de nuevo.');
    }
  } catch (error) {
    // Captura cualquier error durante el registro y muestra un mensaje descriptivo.
    showError('Error: $error');
  } finally {
    // Oculta el indicador de carga al finalizar el registro.
    hideLoadingIndicator();
  }
}

void showLoadingIndicator() {
  // Implementa la lógica para mostrar un indicador de carga.
  // Puedes usar un widget como CircularProgressIndicator o un modal.
}

void hideLoadingIndicator() {
  // Implementa la lógica para ocultar el indicador de carga.
}

void showError(String errorMessage) {
  setState(() {
    _errorMessage = errorMessage;
  });
}
