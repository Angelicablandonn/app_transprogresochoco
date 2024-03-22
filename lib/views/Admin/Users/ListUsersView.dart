import 'package:flutter/material.dart';
import 'package:app_transprogresochoco/models/UserModel.dart';
import 'package:app_transprogresochoco/controllers/AdminController.dart';
import 'package:app_transprogresochoco/views/Admin/Users/EditUserScreen.dart';

class ListUsersView extends StatefulWidget {
  @override
  _ListUsersViewState createState() => _ListUsersViewState();
}

class _ListUsersViewState extends State<ListUsersView> {
  final AdminController _adminController = AdminController();
  late Future<List<Map<String, dynamic>>> _userListFuture;
  TextEditingController _searchController = TextEditingController();

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

  Future<void> _searchUsers(String query) async {
    try {
      final userList = await _adminController.searchUsers(query);
      setState(() {
        _userListFuture = Future.value(userList);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al buscar usuarios: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _editUser(UserModel user) {
    String uid = user.uid;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditUserScreen(uid: uid, user: user),
      ),
    ).then((result) {
      if (result == true) {
        _loadUserList();
      }
    });
  }

  Future<void> _deleteUser(String uid) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar este usuario?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      await _adminController.deleteUser(uid);
      _loadUserList();
    }
  }

  Future<void> _refreshUserList() async {
    _loadUserList();
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
            TextField(
              controller: _searchController,
              onChanged: (query) {
                if (query.isEmpty) {
                  _loadUserList();
                } else {
                  _searchUsers(query);
                }
              },
              decoration: InputDecoration(
                labelText: 'Buscar usuarios por nombre o correo electrónico',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Usuarios Registrados:',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshUserList,
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _userListFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                            'Error al cargar la lista de usuarios: ${snapshot.error}'),
                      );
                    } else if (snapshot.hasData) {
                      final userList = snapshot.data!;
                      if (userList.isEmpty) {
                        return Center(
                          child: Text('No se encontraron usuarios'),
                        );
                      } else {
                        return ListView.builder(
                          itemCount: userList.length,
                          itemBuilder: (context, index) {
                            final user = UserModel.fromMap(userList[index]);
                            return ListTile(
                              title: Text(user.fullName),
                              subtitle: Text(user.email),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      _editUser(user);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      _deleteUser(user.uid);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    } else {
                      return Center(
                        child: Text('No se encontraron usuarios'),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
