import 'package:cloud_firestore/cloud_firestore.dart';

class Place {
  final String name, description, by, id, type;
  final double lat, lon, spm;
  final List images;
  final Map days;

  Place(
      {this.name,
      this.description,
      this.lat,
      this.lon,
      this.by,
      this.images,
      this.days,
      this.spm,
      this.id,
      this.type});

  Place.fromSnapshot(DocumentSnapshot snapshot)
      : name = snapshot.data()['name'],
        description = snapshot.data()['description'],
        by = snapshot.data()['by'],
        lat = snapshot.data()['lat'],
        lon = snapshot.data()['lon'],
        images = snapshot.data()['images'],
        days = snapshot.data()['days'],
        spm = snapshot.data()['spm'],
        type = snapshot.data()['type'],
        id = snapshot.id;
}
