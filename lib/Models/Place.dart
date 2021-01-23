import 'package:cloud_firestore/cloud_firestore.dart';

class Place {
  final String name, description, by, id;
  final double lat, lon;
  final List images, services;

  Place(
      {this.name,
      this.description,
      this.lat,
      this.lon,
      this.by,
      this.images,
      this.services,
      this.id});

  Place.fromSnapshot(DocumentSnapshot snapshot)
      : name = snapshot.data()['name'],
        description = snapshot.data()['description'],
        by = snapshot.data()['by'],
        lat = snapshot.data()['lat'],
        lon = snapshot.data()['lon'],
        images = snapshot.data()['images'],
        services = snapshot.data()['services'],
        id = snapshot.id;
}
