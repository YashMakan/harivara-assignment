import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harivara/models/char_text_fields.dart';

class Database {
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('char_text_fields');

  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }

  Future pruneDB() async {
    var snapshots = await collection.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }

  Future addCharTextFields(CharTextFields charTextFields) async {
    if (charTextFields.referenceId == null) {
      var result = await collection.add(charTextFields.toJson());
      return result.id;
    } else {
      await collection
          .doc(charTextFields.referenceId)
          .update(charTextFields.toJson());
    }
  }
}
