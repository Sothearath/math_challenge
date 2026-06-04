import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get user => _auth.currentUser;

  Future<AuthService> init() async {
    try {
      if (_auth.currentUser == null) {
        final cred = await _auth.signInAnonymously();

        debugPrint('Anonymous UID: ${cred.user?.uid}');
      } else {
        debugPrint('Existing UID: ${_auth.currentUser?.uid}');
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Auth Error: ${e.code}');
      debugPrint('Auth Message: ${e.message}');
      rethrow;
    }

    return this;
  }
}