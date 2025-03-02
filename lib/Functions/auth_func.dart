import 'package:firebase_auth/firebase_auth.dart';

class AuthFunc {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<UserCredential?> signup(email, password) async {
    try {
      UserCredential user = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return user;
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<UserCredential?> signin(email, password) async {
    try {
      UserCredential user = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return user;
    } catch (e) {
      print(e.toString());
    }
    return null;
  }
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e.toString());
    }
  }
}
