import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_complete_guide/Models/Place.dart';

class PlaceDB {
  final CollectionReference placesCollection =
      FirebaseFirestore.instance.collection('locations');

  List<Place> _placeList(QuerySnapshot snapshot) {
    // double lat = 41.3174;
    // double lon = 69.2483;
    // int i = 1;
    // done() async {
    //   while (i < 2001) {
    //     await placesCollection.doc(i.toString()).set({
    //       'name': 'Place' + i.toString(),
    //       'descrption': 'Description' + i.toString(),
    //       'lat': lat + 0.001,
    //       'lon': lon + 0.001,
    //     });
    //     lat = lat + 0.001;
    //     lon = lon + 0.001;
    //     i = i + 1;
    //   }
    // }
    // done();
    return snapshot.docs.map((doc) {
      return Place(
        name: doc.data()['name'] ?? '',
        description: doc.data()['description'] ?? '',
        lat: doc.data()['lat'] ?? 0,
        lon: doc.data()['lon'] ?? 0,
        by: doc.data()['by'] ?? '',
        images: doc.data()['images'],
        days: doc.data()['days'],
        spm: doc.data()['spm'],
        type: doc.data()['type'],
        id: doc.id,
      );
    }).toList();
  }

  Stream<List<Place>> get places {
    return placesCollection.snapshots().map(_placeList);
  }
  
}
