import 'package:flutter/cupertino.dart';
import 'services/notification_service.dart';

class PantallaNotificaciones extends StatefulWidget {
  const PantallaNotificaciones({super.key});

  @override
  State<PantallaNotificaciones> createState() => _PantallaNotificacionesState();
}

class _PantallaNotificacionesState extends State<PantallaNotificaciones> {
  void _enviarNotificacion(String titulo, String mensaje) {
    NotificationService().mostrarNotificacion(
      context: context,
      titulo: titulo,
      mensaje: mensaje,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Icon(
            CupertinoIcons.back,
            color: CupertinoColors.activeBlue,
          ),
        ),
        middle: const Text('Notificaciones'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Centro de Notificaciones',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.activeBlue,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Toca los botones para recibir notificaciones:',
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 24),
              // Notificación de éxito
              CupertinoButton.filled(
                onPressed: () {
                  _enviarNotificacion(
                    'Éxito',
                    'Tu operación se completó correctamente',
                  );
                },
                child: const Text('Notificación de Éxito'),
              ),
              const SizedBox(height: 12),

              // Notificación de información
              CupertinoButton.filled(
                onPressed: () {
                  _enviarNotificacion(
                    'Información',
                    'Se han cargado 10 nuevos posts desde la API',
                  );
                },
                child: const Text('Notificación de Información'),
              ),
              const SizedBox(height: 12),

              // Notificación de advertencia
              CupertinoButton.filled(
                onPressed: () {
                  _enviarNotificacion(
                    'Advertencia',
                    'Tu sesión está por expirar. Inicia sesión nuevamente.',
                  );
                },
                child: const Text('Notificación de Advertencia'),
              ),
              const SizedBox(height: 12),

              // Notificación de error
              CupertinoButton.filled(
                onPressed: () {
                  _enviarNotificacion(
                    'Error',
                    'No se pudo completar la operación. Intenta más tarde.',
                  );
                },
                child: const Text('Notificación de Error'),
              ),
              const SizedBox(height: 12),

              // Notificación personalizada
              CupertinoButton.filled(
                onPressed: () {
                  _enviarNotificacion(
                    'Nueva Tarea Completada',
                    'Felicidades! Has completado todas las tareas del día.',
                  );
                },
                child: const Text('Notificación Personalizada'),
              ),
              const SizedBox(height: 12),

              // Notificación de sincronización
              CupertinoButton.filled(
                onPressed: () {
                  _enviarNotificacion(
                    'Sincronización Completada',
                    'Los datos se sincronizaron exitosamente con el servidor.',
                  );
                },
                child: const Text('Notificación de Sincronización'),
              ),
              const SizedBox(height: 24),

              // Sección de información
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CupertinoColors.systemGrey,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: CupertinoColors.white.withOpacity(0.05),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Acerca de las Notificaciones',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.activeBlue,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Las notificaciones locales se utilizan para alertar al usuario sobre eventos importantes de la aplicación sin depender de un servidor remoto.\n\n'
                      'Ejemplos de uso:\n'
                      '• Confirmación de acciones (crear, guardar, eliminar)\n'
                      '• Avisos sobre cambios importantes\n'
                      '• Recordatorios y tareas\n'
                      '• Estado de sincronización\n'
                      '• Errores y excepciones',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
