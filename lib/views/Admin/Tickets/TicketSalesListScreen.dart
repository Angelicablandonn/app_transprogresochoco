import 'package:flutter/material.dart';
import 'package:app_transprogresochoco/controllers/AdminController.dart';
import 'package:app_transprogresochoco/models/TicketSale.dart';

class TicketSalesListScreen extends StatefulWidget {
  @override
  _TicketSalesListScreenState createState() => _TicketSalesListScreenState();
}

class _TicketSalesListScreenState extends State<TicketSalesListScreen> {
  final _controller =
      AdminController(); // Asegúrate de tener el controlador adecuado

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ventas de Tiquetes'),
      ),
      body: FutureBuilder<List<TicketSale>>(
        future: _controller.getTicketSales(), // Obtener las ventas de tiquetes
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Muestra un indicador de carga mientras se cargan los datos.
          } else if (snapshot.hasError) {
            return Text('Error al cargar las ventas de tiquetes');
          } else {
            final ticketSales = snapshot.data;
            if (ticketSales == null || ticketSales.isEmpty) {
              return Text('No hay ventas de tiquetes disponibles.');
            }
            return ListView.builder(
              itemCount: ticketSales.length,
              itemBuilder: (context, index) {
                final sale = ticketSales[index];
                return ListTile(
                  title: Text('Cliente: ${sale.customerName}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Correo Electrónico: ${sale.customerEmail}'),
                      Text('Monto Total: \$${sale.amount.toStringAsFixed(2)}'),
                      Text('Cantidad de Tiquetes: ${sale.quantity}'),
                      Text('Método de Pago: ${sale.paymentMethod}'),
                      Text(
                          'Fecha de Venta: ${sale.saleDate.toDate().toString()}'),
                      Text('ID de Ruta: ${sale.routeId}'),
                      Text(
                          'Precio Unitario del Tiquete: \$${sale.ticketPrice.toStringAsFixed(2)}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _editTicketSale(sale); // Editar la venta de tiquetes
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteTicketSale(
                              sale.id); // Eliminar la venta de tiquetes por ID
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pop(); // Regresar atrás
        },
        child: Icon(Icons.arrow_back),
      ),
    );
  }

  void _editTicketSale(TicketSale sale) {
    // Implementa la lógica para editar la venta de tiquetes aquí, usando el controlador.
    _controller.updateTicketSale(sale).then((_) {
      // Actualizar la lista después de editar la venta (si es necesario).
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Venta de tiquetes editada con éxito.'),
      ));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al editar la venta de tiquetes: $error'),
      ));
    });
  }

  void _deleteTicketSale(String ticketSaleId) {
    // Implementa la lógica para eliminar la venta de tiquetes aquí, usando el controlador.
    _controller.deleteTicketSale(ticketSaleId).then((_) {
      // Actualizar la lista después de eliminar la venta (si es necesario).
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
