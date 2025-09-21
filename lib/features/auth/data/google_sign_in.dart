import 'dart:io' show Platform;
import 'package:google_sign_in/google_sign_in.dart' as gsi;
import 'package:firebase_auth/firebase_auth.dart' as fa;

const String _serverClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

class GoogleSignInService {
  final gsi.GoogleSignIn _googleSignIn = gsi.GoogleSignIn.instance;
  
  gsi.GoogleSignIn get googleSignIn => _googleSignIn;

  Future<gsi.GoogleSignInAccount?> signIn() async {
    try {
      if (Platform.isAndroid && _serverClientId.isEmpty) {
        print('Google Sign-In Error: serverClientId is required on Android.');
        return null;
      }
      if (Platform.isAndroid) {
        await _googleSignIn.initialize(serverClientId: _serverClientId);
      }

      final account = await _googleSignIn.authenticate(scopeHint: const ['email']);
      if (account == null) return null;

      final tokenData = await account.authentication;

      final credential = fa.GoogleAuthProvider.credential(
        idToken: tokenData.idToken,
      );

      await fa.FirebaseAuth.instance.signInWithCredential(credential);
      return account;
    } on gsi.GoogleSignInException catch (error) {
      print('Google Sign-In Error: $error');
      return null;
    } catch (error) {
      print('Google Sign-In Unexpected Error: $error');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await fa.FirebaseAuth.instance.signOut();
    } catch (_) {}
    await _googleSignIn.signOut();
  }
}