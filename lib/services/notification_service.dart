import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static const MethodChannel _channel = MethodChannel(
    'proyecto1/notificaciones',
  );

  NotificationService._internal();

  factory NotificationService() => _instance;

  Future<void> initialize() async {
    try {
      await _channel.invokeMethod<void>('initialize');
    } catch (_) {
      // En plataformas sin canal nativo, la app usa dialogos como respaldo.
    }
  }

  Future<void> mostrarNotificacion({
    required BuildContext context,
    required String titulo,
    required String mensaje,
    String? payload,
  }) async {
    try {
      await _channel.invokeMethod<void>('showNotification', {
        'title': titulo,
        'message': mensaje,
      });
      return;
    } catch (_) {
      // Si el canal no existe, mantenemos una respuesta visible en Flutter.
    }

    await showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  Future<void> cancelarNotificacion() async {
    try {
      await _channel.invokeMethod<void>('cancelNotification');
    } catch (_) {
      // Sin accion de respaldo necesaria.
    }
  }
}
