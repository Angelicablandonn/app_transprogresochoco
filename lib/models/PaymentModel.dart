class PaymentModel {
  // Datos de la tarjeta de crédito o débito
  String cardNumber; // Número de la tarjeta
  String cardHolderName; // Nombre del titular de la tarjeta
  String cardExpirationDate; // Fecha de vencimiento de la tarjeta (MM/AA)
  String cardCVV; // Código de seguridad de la tarjeta

  // Detalles de la transacción
  double amount; // Monto de la transacción
  String currency; // Moneda utilizada (por ejemplo, COP para pesos colombianos)
  String orderId; // Número de orden o identificador de la compra

  // Información del cliente
  String email; // Correo electrónico del cliente

  // Constructor para crear una instancia de PaymentModel
  PaymentModel({
    required this.cardNumber,
    required this.cardHolderName,
    required this.cardExpirationDate,
    required this.cardCVV,
    required this.amount,
    required this.currency,
    required this.orderId,
    required this.email,
  });

  // Método para convertir el modelo en un mapa
  Map<String, dynamic> toMap() {
    return {
      'cardNumber': cardNumber,
      'cardHolderName': cardHolderName,
      'cardExpirationDate': cardExpirationDate,
      'cardCVV': cardCVV,
      'amount': amount,
      'currency': currency,
      'orderId': orderId,
      'email': email,
    };
  }

  // Constructor para crear una instancia desde un mapa
  PaymentModel.fromMap(Map<String, dynamic> map)
      : cardNumber = map['cardNumber'],
        cardHolderName = map['cardHolderName'],
        cardExpirationDate = map['cardExpirationDate'],
        cardCVV = map['cardCVV'],
        amount = map['amount'],
        currency = map['currency'],
        orderId = map['orderId'],
        email = map['email'];
}
