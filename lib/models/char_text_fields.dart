import 'package:cloud_firestore/cloud_firestore.dart';

class CharTextFields {
  static const String leftValueKey = 'left_value';
  static const String rightValueKey = 'right_value';
  static const String referenceIdKey = 'reference_id';

  final int leftValue;
  final int rightValue;
  final String? referenceId;

  CharTextFields(this.leftValue, this.rightValue, {this.referenceId});

  factory CharTextFields.fromJson(Map<String, dynamic> json) =>
      CharTextFields(json[leftValueKey], json[rightValueKey],
          referenceId: json[referenceIdKey]);

  factory CharTextFields.fromSnapshot(QueryDocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    data[referenceIdKey] = snapshot.reference.id;
    return CharTextFields.fromJson(data);
  }

  Map<String, dynamic> toJson() => {
        leftValueKey: leftValue,
        rightValueKey: rightValue,
        referenceIdKey: referenceId
      };

  @override
  String toString() => 'CharTextFields<$leftValue,$rightValue>';
}
