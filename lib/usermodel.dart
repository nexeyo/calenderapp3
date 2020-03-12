import 'package:cloud_firestore/cloud_firestore.dart';

class User{
  final String id;
  final String displayName;
  final String email;
  final String photoUrl;
  final String mobile;

  User({
    this.id,
    this.displayName,
    this.photoUrl,
    this.email,
    this.mobile,
});

  factory User.fromDocument(DocumentSnapshot doc){
    return User(
      id: doc['id'],
      email: doc['email'],
      photoUrl: doc['photoUrl'],
      displayName: doc['displayName'],
      mobile : doc['mobile'],
    );
  }
}
