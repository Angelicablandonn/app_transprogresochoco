import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:app_transprogresochoco/controllers/AdminController.dart';
import 'package:app_transprogresochoco/models/RouteModel.dart';
import 'package:app_transprogresochoco/models/TicketSale.dart';

class AddTicketSaleView extends StatefulWidget {
  @override
  _AddTicketSaleViewState createState() => _AddTicketSaleViewState();
}

class _AddTicketSaleViewState extends State<AddTicketSaleView> {
  final _formKey = GlobalKey<FormState>();
  final _controller = AdminController();

  RouteModel? _selectedRoute;
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar venta de tiquete'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Seleccione la ruta:'),
              FutureBuilder<List<RouteModel>>(
                future: _controller.getRoutes(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final routes = snapshot.data!;
                    return DropdownButtonFormField<RouteModel>(
                      value: _selectedRoute,
                      items: routes.map((route) {
                        return DropdownMenuItem<RouteModel>(
                          value: route,
                          child: Text('${route.origin} - ${route.destination}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRoute = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Seleccione una ruta';
                        }
                        return null;
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error al cargar las rutas');
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
              SizedBox(height: 16.0),
              Text('Cantidad de tiquetes:'),
              Row(
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
                  Text('$_quantity'),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        _quantity++;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nombre del cliente',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el nombre del cliente';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Correo electrónico del cliente',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el correo electrónico del cliente';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Método de pago utilizado',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el método de pago utilizado';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _addTicketSale();
                  }
                },
                child: Text('Agregar venta'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addTicketSale() async {
    if (_selectedRoute != null) {
      final ticketSale = TicketSale(
        id: '',
        customerName: '',
        customerEmail: '',
        amount: _selectedRoute!.ticketPrice * _quantity,
        quantity: _quantity,
        paymentMethod: '',
        saleDate: Timestamp.now(),
        routeId: _selectedRoute!.id,
        ticketPrice: _selectedRoute!.ticketPrice,
      );

      await _controller.addTicketSale(ticketSale, _selectedRoute!, _quantity);

      Navigator.of(context).pop();
    }
  }
}
