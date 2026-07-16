import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'session_service.dart';

class AuditLogService {
  AuditLogService._();

  static final AuditLogService instance = AuditLogService._();

  static const fileName = 'bitacora_api.txt';

  Future<File> get _file async {
    final directory = await getApplicationDocumentsDirectory();
    return File(p.join(directory.path, fileName));
  }

  Future<String> get filePath async {
    return (await _file).path;
  }

  Future<void> registrarMovimiento({
    required String accion,
    required String entidad,
    required String resultadoApi,
    required Map<String, Object?> detalles,
  }) async {
    final file = await _file;
    if (!await file.exists()) {
      await file.create(recursive: true);
      await file.writeAsString(_encabezado(), mode: FileMode.write);
    }

    final ahora = DateTime.now();
    final linea = StringBuffer()
      ..writeln('Fecha y hora: ${_formatearFecha(ahora)}')
      ..writeln('Usuario: ${SessionService.usuarioActual}')
      ..writeln('Accion: $accion')
      ..writeln('Entidad: $entidad')
      ..writeln('Resultado API: $resultadoApi');

    detalles.forEach((key, value) {
      linea.writeln('$key: ${value ?? "Sin dato"}');
    });

    linea.writeln('----------------------------------------');

    await file.writeAsString(linea.toString(), mode: FileMode.append);
  }

  Future<String> leerBitacora() async {
    final file = await _file;
    if (!await file.exists()) {
      return 'Todavia no hay movimientos registrados.\n\n'
          'Cuando agregues, edites o elimines Meks desde la API, aqui se '
          'guardara la bitacora con usuario, fecha, hora y detalles.';
    }

    final contenido = await file.readAsString();
    if (contenido.trim().isEmpty) {
      return 'La bitacora existe, pero aun esta vacia.';
    }

    return contenido;
  }

  Future<void> limpiarBitacora() async {
    final file = await _file;
    await file.writeAsString(_encabezado(), mode: FileMode.write);
  }

  String _encabezado() {
    return 'BITACORA DE MOVIMIENTOS DE API\n'
        'Archivo generado por Proyecto Flutter - Programacion Movil\n'
        '========================================\n\n';
  }

  String _formatearFecha(DateTime fecha) {
    String dosDigitos(int valor) => valor.toString().padLeft(2, '0');

    final dia = dosDigitos(fecha.day);
    final mes = dosDigitos(fecha.month);
    final anio = fecha.year;
    final hora = dosDigitos(fecha.hour);
    final minuto = dosDigitos(fecha.minute);
    final segundo = dosDigitos(fecha.second);

    return '$dia/$mes/$anio $hora:$minuto:$segundo';
  }
}
