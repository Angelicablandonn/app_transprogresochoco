import 'package:flutter/material.dart';
import 'package:app_transprogresochoco/controllers/UserController.dart';
import 'package:app_transprogresochoco/models/TicketSale.dart';

class PurchaseHistoryScreen extends StatefulWidget {
  @override
  _PurchaseHistoryScreenState createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  final UserController _userController = UserController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Compras'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(
                context); // Esta línea te lleva de vuelta a la pantalla anterior
          },
        ),
      ),
      body: FutureBuilder<List<TicketSale>>(
        future: _userController.getPurchaseHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No hay historial de compras disponible.'),
            );
          } else {
            List<TicketSale> purchaseHistory = snapshot.data!;

            return ListView.builder(
              itemCount: purchaseHistory.length,
              itemBuilder: (context, index) {
                TicketSale purchase = purchaseHistory[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                        'Ruta: ${purchase.routeId}'), // Replace with the appropriate field
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Fecha de Compra: ${purchase.saleDate.toDate()}'), // Adjust as per your date format
                        Text('Cantidad de Boletos: ${purchase.quantity}'),
                        Text('Total: \$${purchase.amount.toStringAsFixed(2)}'),
                        // Add more details as needed
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
