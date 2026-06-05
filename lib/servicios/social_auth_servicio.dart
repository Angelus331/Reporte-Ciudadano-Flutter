import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class SocialAuthService {
  // Instancia oficial de Google configurada de forma independiente
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );

  // 🔥 1. LOGIN CON GOOGLE
  Future<Map<String, dynamic>?> loginConGoogle() async {
    try {
      // Forzamos cerrar sesión previa para evitar bugs de cuentas congeladas
      await _googleSignIn.signOut();

      // Desplegamos la ventanita nativa en el celular
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // El ciudadano canceló el proceso

      // Extraemos la autenticación segura de los servidores de Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      return {
        'provider': 'google',
        'email': googleUser.email,
        'name': googleUser.displayName,
        'id_token': googleAuth.idToken,       // Token JWT para validar en tu backend
        'access_token': googleAuth.accessToken, // Token de acceso secundario
      };
    } catch (e) {
      print('Error crítico Google Sign-In: $e');
      return null;
    }
  }

  // 🔥 2. LOGIN CON FACEBOOK
  Future<Map<String, dynamic>?> loginConFacebook() async {
    try {
      // Forzamos el cierre de sesión anterior
      await FacebookAuth.instance.logOut();

      // Solicitamos la interfaz nativa de la app de Facebook
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        // Obtenemos los datos públicos del perfil del ciudadano
        final userData = await FacebookAuth.instance.getUserData();

        return {
          'provider': 'facebook',
          'email': userData['email'],
          'name': userData['name'],
          'token': result.accessToken?.token, // Token para pasar a Laravel
        };
      }
      return null;
    } catch (e) {
      print('Error crítico Facebook Auth: $e');
      return null;
    }
  }
}