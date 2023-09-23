import 'package:flutter/material.dart';
import 'package:app_transprogresochoco/controllers/AdminController.dart';
import 'package:app_transprogresochoco/models/UserModel.dart';

class ListUsersView extends StatefulWidget {
  @override
  _ListUsersViewState createState() => _ListUsersViewState();
}

class _ListUsersViewState extends State<ListUsersView> {
  final AdminController _adminController = AdminController();
  late Future<List<Map<String, dynamic>>> _userListFuture;

  @override
  void initState() {
    super.initState();
    _loadUserList();
  }

  Future<void> _loadUserList() async {
    try {
      final userList = await _adminController.getUsers();
      setState(() {
        _userListFuture = Future.value(userList);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar la lista de usuarios: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Usuarios'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Usuarios Registrados:',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _userListFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final userList = snapshot.data!;
                    return ListView.builder(
                      itemCount: userList.length,
                      itemBuilder: (context, index) {
                        final user = userList[index];
                        final fullName = user['fullName'] ?? '';
                        final email = user['email'] ?? '';

                        return ListTile(
                          title: Text(fullName),
                          subtitle: Text(email),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  final uid = user[
                                      'uid']; // Obtén el UID del usuario que se va a editar
                                  Navigator.of(context)
                                      .pushNamed('/edit_user', arguments: {
                                    'uid':
                                        uid, // Asegúrate de tener el UID correcto
                                    'user':
                                        user, // Asegúrate de tener el UserModel correcto
                                  });
                                },
                              ),
                              // En el itemBuilder de ListView.builder en ListUsersView
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  final uid = user['uid'];
                                  final fullName = user['fullName'];

                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Confirmar Eliminación'),
                                        content: Text(
                                            '¿Seguro que deseas eliminar a $fullName?'),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text('Cancelar'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text('Eliminar'),
                                            onPressed: () async {
                                              // Llama a la función para eliminar el usuario
                                              await _adminController
                                                  .deleteUser(uid);

                                              // Cierra el cuadro de diálogo de confirmación
                                              Navigator.of(context).pop();

                                              // Actualiza la lista de usuarios (puedes usar setState o cargar nuevamente la lista)
                                              _loadUserList();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              )
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(child: Text('No hay usuarios registrados.'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
