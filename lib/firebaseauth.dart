import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider{

  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> signInWithEmail(String email, String password) async{

    try{
      AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;
      if(user != null){
        return true;
      }
      else{
        return false;
      }
    }
    catch(e){
      return false;
    }


  }

}