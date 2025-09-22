import 'dart:io' show Platform;
import 'package:google_sign_in/google_sign_in.dart' as gsi;
import 'package:firebase_auth/firebase_auth.dart' as fa;

const String _serverClientId = String.fromEnvironment(
  'GOOGLE_SERVER_CLIENT_ID',
  defaultValue: '975651004709-fln78b18fnfosporfoq458kksk64arr9.apps.googleusercontent.com',
);

class GoogleSignInService {
  final gsi.GoogleSignIn _googleSignIn = gsi.GoogleSignIn.instance;
  
  gsi.GoogleSignIn get googleSignIn => _googleSignIn;

  Future<gsi.GoogleSignInAccount?> signIn() async {
    try {
      await _googleSignIn.initialize(serverClientId: _serverClientId);

      if (_googleSignIn.supportsAuthenticate()) {
        final account = await _googleSignIn.authenticate();
        if (account == null) return null;

        final tokenData = await account.authentication;

        final credential = fa.GoogleAuthProvider.credential(
          idToken: tokenData.idToken,
        );

        await fa.FirebaseAuth.instance.signInWithCredential(credential);
        return account;
      } else {
        // Authenticate method not supported on this platform
        return null;
      }
    } on gsi.GoogleSignInException catch (error) {
      // Google Sign-In Error: $error
      return null;
    } catch (error) {
      // Google Sign-In Unexpected Error: $error
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