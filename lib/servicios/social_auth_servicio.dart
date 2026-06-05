import 'package:google_sign_in/google_sign_in.dart';

class SocialAuthService {
  // 🟢 1. En la versión 7 ya no se usan paréntesis, se llama a la instancia global
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<Map<String, dynamic>?> loginConGoogle() async {
    try {
      // 🟢 2. Novedad obligatoria de la v7: Se debe inicializar antes de usarse
      await _googleSignIn.initialize();

      // 🟢 3. El viejo signIn() fue reemplazado por authenticate()
      // Nota: En la v7, si el usuario cancela la ventana emergente, cae directo al "catch"
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // Extraemos la autenticación de los servidores de Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 🎯 Retornamos los datos limpios para tu Dio y tu API en Laravel/AWS
      return {
        'provider': 'google',
        'email': googleUser.email,
        'name': googleUser.displayName,
        
        // 🟢 4. Ya solo enviamos el id_token (El accessToken fue removido por Google)
        // Tu backend solo necesita este id_token para verificar la cuenta.
        'id_token': googleAuth.idToken,       
      };
    } catch (e) {
      // En la versión 7, cerrar o cancelar la ventanita se detecta aquí
      print('🔥 Error o cancelación en Google Sign-In: $e');
      return null;
    }
  }
}