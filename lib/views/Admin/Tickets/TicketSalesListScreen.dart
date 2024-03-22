import 'package:flutter/material.dart';
import 'package:app_transprogresochoco/controllers/AdminController.dart';
import 'package:app_transprogresochoco/models/TicketSale.dart';
import 'package:app_transprogresochoco/views/Admin/Tickets/EditTicketSaleScreen.dart';

class TicketSalesListScreen extends StatefulWidget {
  @override
  _TicketSalesListScreenState createState() => _TicketSalesListScreenState();
}

class _TicketSalesListScreenState extends State<TicketSalesListScreen> {
  final AdminController _adminController = AdminController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ventas de Tiquetes'),
      ),
      body: FutureBuilder<List<TicketSale>>(
        future: _adminController.getTicketSales(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar las ventas de tiquetes'),
            );
          } else {
            final ticketSales = snapshot.data;

            if (ticketSales == null || ticketSales.isEmpty) {
              return Center(
                child: Text('No hay ventas de tiquetes disponibles.'),
              );
            }

            return ListView.builder(
              itemCount: ticketSales.length,
              itemBuilder: (context, index) {
                final sale = ticketSales[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  elevation: 4.0,
                  child: ListTile(
                    title: Text('Cliente: ${sale.customerName}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8.0),
                        Text('Correo Electrónico: ${sale.customerEmail}'),
                        Text(
                            'Monto Total: \$${sale.amount.toStringAsFixed(2)}'),
                        Text('Cantidad de Tiquetes: ${sale.quantity}'),
                        Text('Método de Pago: ${sale.paymentMethod}'),
                        Text(
                          'Fecha de Venta: ${sale.saleDate.toDate().toString()}',
                        ),
                        Text('ID de Ruta: ${sale.routeId}'),
                        Text(
                          'Precio Unitario del Tiquete: \$${sale.ticketPrice.toStringAsFixed(2)}',
                        ),
                        Text('Estado de Aprobación: ${sale.approvalStatus}'),
                        Text('ID de Usuario: ${sale.userId}'),
                        SizedBox(height: 8.0),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _editTicketSale(sale);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteTicketSale(sale.id);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Icon(Icons.arrow_back),
      ),
    );
  }

  void _editTicketSale(TicketSale sale) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTicketSaleScreen(ticketSale: sale),
      ),
    ).then((result) {
      if (result != null && result) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Venta de tiquetes editada con éxito.'),
        ));
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al editar la venta de tiquetes: $error'),
      ));
    });
  }

  void _deleteTicketSale(String ticketSaleId) {
    _adminController.deleteTicketSale(ticketSaleId).then((_) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Venta de tiquetes eliminada con éxito.'),
      ));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al eliminar la venta de tiquetes: $error'),
      ));
    });
  }
}
