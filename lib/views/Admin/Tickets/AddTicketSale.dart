import 'package:flutter/material.dart';
import 'package:app_transprogresochoco/controllers/AdminController.dart';
import 'package:app_transprogresochoco/models/RouteModel.dart';
import 'package:app_transprogresochoco/models/TicketSale.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTicketSaleView extends StatefulWidget {
  @override
  _AddTicketSaleViewState createState() => _AddTicketSaleViewState();
}

class _AddTicketSaleViewState extends State<AddTicketSaleView> {
  final _formKey = GlobalKey<FormState>();
  final _controller = AdminController();
  String? _selectedRouteId;
  int _quantity = 1;
  TextEditingController _customerNameController = TextEditingController();
  TextEditingController _customerEmailController = TextEditingController();
  TextEditingController _paymentMethodController = TextEditingController();
  late Future<List<RouteModel>> _routesFuture;
  late bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _routesFuture = _controller.getRoutes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Venta de Tiquete'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isProcessing
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDropDownRoute(),
                    SizedBox(height: 16.0),
                    _buildQuantitySelector(),
                    SizedBox(height: 16.0),
                    _buildTextFormField(_customerNameController,
                        'Nombre del Cliente', Icons.person),
                    SizedBox(height: 16.0),
                    _buildTextFormField(_customerEmailController,
                        'Correo Electrónico', Icons.email),
                    SizedBox(height: 16.0),
                    _buildTextFormField(_paymentMethodController,
                        'Método de Pago', Icons.payment),
                    SizedBox(height: 16.0),
                    _buildAddTicketButton(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDropDownRoute() {
    return FutureBuilder<List<RouteModel>>(
      future: _routesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error al cargar las rutas');
        }
        final routes = snapshot.data ?? [];
        return DropdownButtonFormField<String>(
          value: _selectedRouteId,
          items: routes.map((route) {
            return DropdownMenuItem<String>(
              value: route.id,
              child: Text('${route.origin} - ${route.destination}'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedRouteId = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Seleccione una ruta';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.remove),
          onPressed: () {
            setState(() {
              if (_quantity > 1) {
                _quantity--;
              }
            });
          },
        ),
        Text('$_quantity', style: TextStyle(fontSize: 20)),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            setState(() {
              _quantity++;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTextFormField(
      TextEditingController controller, String labelText, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ingrese el $labelText';
        }
        return null;
      },
    );
  }

  Widget _buildAddTicketButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          setState(() {
            _isProcessing = true;
          });
          await _addTicketSale();
          setState(() {
            _isProcessing = false;
          });
        }
      },
      child: Text('Agregar Venta', style: TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        primary: Colors.blue,
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _addTicketSale() async {
    if (_selectedRouteId != null) {
      final route = await _controller.getRouteById(_selectedRouteId!);
      if (route != null) {
        final FirebaseAuth _auth = FirebaseAuth.instance;
        final User? currentUser = _auth.currentUser;
        if (currentUser != null) {
          try {
            await _controller.addTicketSale(
              TicketSale(
                id: '',
                customerName: _customerNameController.text,
                customerEmail: _customerEmailController.text,
                amount: route.ticketPrice * _quantity,
                quantity: _quantity,
                paymentMethod: _paymentMethodController.text,
                saleDate: Timestamp.now(),
                routeId: route.id,
                ticketPrice: route.ticketPrice,
                userId: currentUser.uid,
                downloadURL: '',
                purchaseHistoryId: '',
              ),
              route,
              _quantity,
              '', // Add missing arguments here
              '',
            );
            await _storePurchaseHistory();
          } catch (e) {
            print('Error al agregar la venta de tiquete: $e');
          }
        }
      }
    }
  }

  Future<void> _storePurchaseHistory() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      try {
        final List<TicketSale> ticketSales =
            await _controller.getPurchaseHistory(currentUser.uid);
        final TicketSale latestTicketSale = ticketSales.isNotEmpty
            ? ticketSales.first
            : TicketSale(
                id: '',
                customerName: '',
                customerEmail: '',
                amount: 0.0,
                quantity: 0,
                paymentMethod: '',
                saleDate: Timestamp.now(),
                routeId: '',
                ticketPrice: 0.0,
                userId: currentUser.uid,
                downloadURL: '',
                purchaseHistoryId: '',
              );

        await _controller.storePurchaseHistory(latestTicketSale);
      } catch (e) {
        print('Error al almacenar la compra en el historial: $e');
      }
    }
  }
}
