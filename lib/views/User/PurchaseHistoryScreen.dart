import 'package:flutter/material.dart';
import 'package:app_transprogresochoco/controllers/UserController.dart';
import 'package:app_transprogresochoco/models/TicketSale.dart';
import 'package:app_transprogresochoco/models/RouteModel.dart';

class PurchaseHistoryScreen extends StatefulWidget {
  @override
  _PurchaseHistoryScreenState createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  final UserController _userController = UserController();

  Future<void> _downloadInvoice(TicketSale purchase) async {
    RouteModel? route = await _userController.getRouteById(purchase.routeId);
    if (route != null) {
      await _userController.downloadInvoice(purchase, route);
    } else {
      print('No se puede obtener la información de la ruta para la compra.');
    }
  }

  Future<void> _refreshHistory() async {
    setState(() {
      // Puedes realizar alguna acción adicional si es necesario antes de volver a cargar el historial
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Compras'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshHistory,
        child: FutureBuilder<List<TicketSale>>(
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
                        'Ruta: ${purchase.routeId}',
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fecha de Compra: ${purchase.saleDate.toDate()}',
                          ),
                          Text('Cantidad de Boletos: ${purchase.quantity}'),
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
                              icon: Icon(Icons.download),
                              onPressed: () async {
                                await _downloadInvoice(purchase);
                              },
                            )
                          : null,
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
