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

  String? _selectedRouteId;
  int _quantity = 1;
  TextEditingController _customerNameController = TextEditingController();
  TextEditingController _customerEmailController = TextEditingController();
  TextEditingController _paymentMethodController = TextEditingController();

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
                controller: _customerNameController,
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
                controller: _customerEmailController,
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
                controller: _paymentMethodController,
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
    if (_selectedRouteId != null) {
      final route = await _controller.getRouteById(_selectedRouteId!);

      if (route != null) {
        final ticketSale = TicketSale(
          id: '',
          customerName: _customerNameController.text,
          customerEmail: _customerEmailController.text,
          amount: route.ticketPrice * _quantity,
          quantity: _quantity,
          paymentMethod: _paymentMethodController.text,
          saleDate: Timestamp.now(),
          routeId: route.id,
          ticketPrice: route.ticketPrice,
        );

        await _controller.addTicketSale(ticketSale, route, _quantity);

        Navigator.of(context).pop();
      }
    }
  }
}
