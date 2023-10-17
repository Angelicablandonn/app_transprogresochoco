import 'package:flutter/material.dart';
import 'package:app_transprogresochoco/controllers/AdminController.dart';
import 'package:app_transprogresochoco/models/TicketSale.dart';

class EditTicketSaleScreen extends StatefulWidget {
  final TicketSale ticketSale;

  EditTicketSaleScreen({required this.ticketSale});

  @override
  _EditTicketSaleScreenState createState() => _EditTicketSaleScreenState();
}

class _EditTicketSaleScreenState extends State<EditTicketSaleScreen> {
  final AdminController _controller = AdminController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _customerName = '';
  String _customerEmail = '';
  String _paymentMethod = '';

  @override
  void initState() {
    super.initState();
    _customerName = widget.ticketSale.customerName;
    _customerEmail = widget.ticketSale.customerEmail;
    _paymentMethod = widget.ticketSale.paymentMethod;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Venta de Tiquete'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                initialValue: _customerName,
                decoration: InputDecoration(
                  labelText: 'Nombre del Cliente',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el nombre del cliente';
                  }
                  return null;
                },
                onSaved: (value) {
                  setState(() {
                    _customerName = value!;
                  });
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                initialValue: _customerEmail,
                decoration: InputDecoration(
                  labelText: 'Correo Electrónico del Cliente',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el correo electrónico del cliente';
                  }
                  return null;
                },
                onSaved: (value) {
                  setState(() {
                    _customerEmail = value!;
                  });
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                initialValue: _paymentMethod,
                decoration: InputDecoration(
                  labelText: 'Método de Pago',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el método de pago utilizado';
                  }
                  return null;
                },
                onSaved: (value) {
                  setState(() {
                    _paymentMethod = value!;
                  });
                },
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _updateTicketSale();
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue, // Color del botón
                ),
                child: Text(
                  'Guardar Cambios',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateTicketSale() {
    final updatedTicketSale = TicketSale(
      id: widget.ticketSale.id,
      customerName: _customerName,
      customerEmail: _customerEmail,
      amount: widget.ticketSale.amount,
      quantity: widget.ticketSale.quantity,
      paymentMethod: _paymentMethod,
      saleDate: widget.ticketSale.saleDate,
      routeId: widget.ticketSale.routeId,
      ticketPrice: widget.ticketSale.ticketPrice,
    );

    _controller.updateTicketSale(updatedTicketSale).then((_) {
      Navigator.of(context)
          .pop(true); // Indica que la edición se completó con éxito
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al editar la venta de tiquetes: $error'),
      ));
    });
  }
}
