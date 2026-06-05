import 'package:google_sign_in/google_sign_in.dart';

class SocialAuthService {

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<Map<String, dynamic>?> loginConGoogle() async {
    try {

      await _googleSignIn.initialize();

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // Extraemos la autenticación de los servidores de Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      return {
        'provider': 'google',
        'email': googleUser.email,
        'name': googleUser.displayName,
        'id_token': googleAuth.idToken,       
      };
    } catch (e) {
      print('Error o cancelación en Google Sign-In: $e');
      return null;
    }
  }
}