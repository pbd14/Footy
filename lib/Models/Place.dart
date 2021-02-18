import 'package:cloud_firestore/cloud_firestore.dart';

class Place {
  final String name, description, by, id;
  final double lat, lon;
  final List images, services;
  final Map rates;

  Place(
      {this.name,
      this.description,
      this.lat,
      this.lon,
      this.by,
      this.images,
      this.services,
      this.rates,
      this.id});

  Place.fromSnapshot(DocumentSnapshot snapshot)
      : name = snapshot.data()['name'],
        description = snapshot.data()['description'],
        by = snapshot.data()['by'],
        lat = snapshot.data()['lat'],
        lon = snapshot.data()['lon'],
        images = snapshot.data()['images'],
        services = snapshot.data()['services'],
        rates = snapshot.data()['rates'],
        id = snapshot.id;
}
