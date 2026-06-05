import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await notificationsPlugin.initialize(settings);
  }

  static Future<void> mostrarNotificacionInmediata({
    required int id,
    required String titulo,
    required String cuerpo,
  }) async {
    const AndroidNotificationDetails
    androidDetails = AndroidNotificationDetails(
      'canal_reportes_id', // ID del canal
      'Alertas de Reporte Ciudadano', // Nombre del canal visible en ajustes del cel
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await notificationsPlugin.show(id, titulo, cuerpo, platformDetails);
  }

  static Future showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'main_channel',
          'Main Notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    // Envolvemos el lanzamiento en un try-catch por si el sistema operativo niega permisos
    try {
      await notificationsPlugin.show(0, title, body, details);
    } catch (e) {
      // Si falla la interfaz de la alerta, que imprima en consola pero que NO rompa el guardado de tu reporte
      print("Error silencioso en notificación visual: \$e");
    }
  }
}
