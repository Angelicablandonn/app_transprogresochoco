import 'package:flutter/material.dart';
import 'package:app_transprogresochoco/controllers/UserController.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final UserController _userController = UserController();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Panel de Administrador'),
      actions: [
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: () async {
            // Llama al método de cerrar sesión del administrador
            await _userController.signOut(context);
          },
        ),
      ],
    );
  }
}
