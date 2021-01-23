import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String placeId, serviceId, userId, status, type, info, id;
  final double price;
  final String from, to, date;
  // ignore: non_constant_identifier_names
  final Timestamp timestamp_date;

  Booking(
      {this.placeId,
      this.serviceId,
      this.userId,
      this.price,
      this.from,
      this.to,
      this.date, 
      this.status,
      // ignore: non_constant_identifier_names
      this.timestamp_date, 
      this.type,
      this.info, 
      this.id});

  Booking.fromSnapshot(DocumentSnapshot snapshot)
      : placeId = snapshot.data()['placeId'],
        serviceId = snapshot.data()['serviceId'],
        userId = snapshot.data()['userId'],
        price = snapshot.data()['price'],
        from = snapshot.data()['from'],
        to = snapshot.data()['to'],
        date = snapshot.data()['date'],
        status = snapshot.data()['status'],
        timestamp_date = snapshot.data()['timestamp_date'],
        type = snapshot.data()['type'],
        info = snapshot.data()['info'],
        id = snapshot.id;
}
