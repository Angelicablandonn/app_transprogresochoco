import 'package:flutter/material.dart';
import 'package:app_transprogresochoco/controllers/UserController.dart';
import 'package:app_transprogresochoco/models/TicketSale.dart';
import 'package:app_transprogresochoco/models/RouteModel.dart';
import 'package:app_transprogresochoco/models/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_transprogresochoco/views/User/ProfileScreen.dart';

class PurchaseHistoryScreen extends StatefulWidget {
  @override
  _PurchaseHistoryScreenState createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  final UserController _userController = UserController();
  List<RouteModel> routes = [];
  Future<void> _refreshHistory() async {
    setState(() {
      // Puedes realizar alguna acción adicional si es necesario antes de volver a cargar el historial
    });
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      // Verificar si hay un usuario actualmente autenticado
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Si hay un usuario autenticado, puedes retornar su información
        // Puedes acceder a su ID, email, etc., según tus necesidades
        return UserModel(
          uid: user.uid,
          fullName: user.displayName ?? '',
          email: user.email ?? '',
          phoneNumber: user.phoneNumber ?? '',
          profilePicture: user.photoURL,
          isAdmin:
              false, // Deberías obtener esto de tu base de datos, ya que Firebase Auth no lo proporciona
          password:
              '', // No deberías acceder a la contraseña del usuario desde FirebaseAuth
        );
      } else {
        // Si no hay un usuario autenticado, puedes retornar null
        return null;
      }
    } catch (e) {
      // Manejar cualquier error que pueda ocurrir al obtener el usuario actual
      print('Error al obtener el usuario actual: $e');
      return null;
    }
  }

  Future<void> _showSearchRoutesDialog() async {
    final originController = TextEditingController();
    final destinationController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          title: Text(
            'Buscar Rutas',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF123456),
            ),
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.4,
            child: Column(
              children: [
                TextField(
                  controller: originController,
                  decoration: InputDecoration(
                    hintText: 'Origen',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: destinationController,
                  decoration: InputDecoration(
                    hintText: 'Destino',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                ListTile(
                  leading: Icon(Icons.calendar_today),
                  title: Text("Seleccionar fecha"),
                  subtitle: Text(
                      "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(DateTime.now().year + 1),
                    );
                    if (picked != null && picked != selectedDate) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                primary: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancelar',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
                primary: Colors.white,
              ),
              onPressed: () {
                _searchRoutes(originController.text, destinationController.text,
                    selectedDate);
                Navigator.pop(context);
              },
              child: Text(
                'Buscar',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _searchRoutes(
      String origin, String destination, DateTime date) async {
    try {
      final foundRoutes =
          await _userController.searchRoutes(origin, destination, date);
      setState(() {
        routes = foundRoutes;
      });
    } catch (error) {
      print('Error al buscar rutas: $error');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              height: 32,
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Transprogreso Choco LTDA',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xFF123456),
        elevation: 0, // Remove elevation
      ),
      body: RefreshIndicator(
        onRefresh: _refreshHistory,
        child: FutureBuilder<List<TicketSale>>(
          future: _userController.getPurchaseHistory(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.red),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'No hay historial de compras disponible.',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            } else {
              List<TicketSale> purchaseHistory = snapshot.data!;

              return ListView.builder(
                itemCount: purchaseHistory.length,
                itemBuilder: (context, index) {
                  TicketSale purchase = purchaseHistory[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        title: Text(
                          'Ruta: ${purchase.id}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fecha de Compra: ${purchase.saleDate.toDate()}',
                            ),
                            Text(
                              'Cantidad de Boletos: ${purchase.quantity}',
                            ),
                            Text(
                              'Total: \$${purchase.amount.toStringAsFixed(2)}',
                            ),
                            Text(
                              'Estado de Aprobación: ${purchase.approvalStatus}',
                            ),
                          ],
                        ),
                        trailing: purchase.approvalStatus == 'Aprobado'
                            ? IconButton(
                                icon: Icon(
                                  Icons.download,
                                  color: Theme.of(context).primaryColor,
                                ),
                                onPressed: () async {
                                  RouteModel? route = await _userController
                                      .getRouteById(purchase.routeId);
                                  if (route != null) {
                                    await _userController.downloadInvoice(
                                        context, purchase, route);
                                  } else {
                                    print(
                                        'No se puede obtener la información de la ruta para la compra.');
                                  }
                                },
                              )
                            : null,
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Registro de Compra',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Salir',
          ),
        ],
        unselectedItemColor: Colors.grey,
        selectedItemColor: Theme.of(context).primaryColor,
        showUnselectedLabels: true,
        currentIndex:
            1, // Cambia a 1 para que el icono de Registro de Compra esté seleccionado
        onTap: (index) async {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/purchase_history');
              break;
            case 2:
              // Obtener el usuario actual
              UserModel? currentUser = await getCurrentUser();

              // Verificar si se obtuvo el usuario correctamente
              if (currentUser != null) {
                // Navegar a la pantalla de perfil y pasar el usuario como argumento
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(user: currentUser),
                  ),
                );
              } else {
                // Manejar el caso en el que no se pudo obtener el usuario
                print('No se pudo obtener el usuario actual');
              }
              break;
            case 3:
              _showSearchRoutesDialog();
              break;
            case 4:
              await _userController.signOut;
              Navigator.pushReplacementNamed(context, '/login');
              break;
          }
        },
      ),
    );
  }
}
