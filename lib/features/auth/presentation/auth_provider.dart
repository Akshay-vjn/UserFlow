import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsi;
import 'package:userflow/core/database/database_helper.dart';
import 'package:userflow/features/auth/data/google_sign_in.dart';

final googleSignInServiceProvider = Provider<GoogleSignInService>((ref) => GoogleSignInService());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(googleSignInServiceProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  final GoogleSignInService _googleSignInService;

  AuthNotifier(this._googleSignInService) : super(AuthInitial());

  void ensureResolved() {
    if (state is AuthInitial) state = AuthUnauthenticated();
  }

  bool get isAuthenticated => state is AuthAuthenticated;

  Future<void> restoreFromLocal() async {
    if (state is AuthInitial) {
      state = AuthLoading();
      try {
        final dbHelper = DatabaseHelper.instance;
        final savedAuth = await dbHelper.getGoogleAuth();
        
        if (savedAuth != null && savedAuth['google_id'] != null && savedAuth['email'] != null) {
          state = AuthAuthenticated(null, localData: savedAuth);
        } else {
          state = AuthUnauthenticated();
        }
      } catch (e) {
        state = AuthError('Failed to restore session: $e');
      }
    }
  }

  Future<void> signIn() async {
    state = AuthLoading();
    final user = await _googleSignInService.signIn();
    if (user != null) {
      final dbHelper = DatabaseHelper.instance;
      
      final auth = await user.authentication;
      await dbHelper.saveGoogleAuth({
        'google_id': user.id,
        'display_name': user.displayName,
        'email': user.email,
        'photo_url': user.photoUrl,
        'server_auth_code': '',
        'access_token': '',
        'id_token': auth.idToken ?? '',
      });
      
      await dbHelper.clearUsers();
      await dbHelper.insertUser({
        'name': user.displayName, 
        'email': user.email, 
        'avatar': user.photoUrl
      });
      
      state = AuthAuthenticated(user);
    } else {
      state = AuthError('Sign-In Failed');
    }
  }

  Future<void> signOut() async {
    await _googleSignInService.signOut();
    await DatabaseHelper.instance.clearAllAuth();
    state = AuthUnauthenticated();
  }
}

abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState { 
  final gsi.GoogleSignInAccount? user; 
  final Map<String, dynamic>? localData;
  AuthAuthenticated(this.user, {this.localData});
}
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState { final String message; AuthError(this.message); }
