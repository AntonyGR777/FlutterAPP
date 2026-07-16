import 'package:flutter/cupertino.dart';

import 'services/audit_log_service.dart';

class LecturaArchivo extends StatefulWidget {
  const LecturaArchivo({super.key});

  @override
  State<LecturaArchivo> createState() => _LecturaArchivoState();
}

class _LecturaArchivoState extends State<LecturaArchivo> {
  String _texto = 'Presiona el boton para leer la bitacora de movimientos.';
  String _ruta = '';

  Future<void> _leerBitacora() async {
    final texto = await AuditLogService.instance.leerBitacora();
    final ruta = await AuditLogService.instance.filePath;
    setState(() {
      _texto = texto;
      _ruta = ruta;
    });
  }

  Future<void> _limpiarBitacora() async {
    await AuditLogService.instance.limpiarBitacora();
    await _leerBitacora();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(
            CupertinoIcons.back,
            color: CupertinoColors.activeBlue,
          ),
        ),
        middle: const Text('Bitacora .txt'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CupertinoButton.filled(
                onPressed: _leerBitacora,
                child: const Text('Leer bitacora'),
              ),
              const SizedBox(height: 10),
              CupertinoButton(
                color: CupertinoColors.systemRed,
                onPressed: _limpiarBitacora,
                child: const Text('Limpiar bitacora'),
              ),
              if (_ruta.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  'Archivo: $_ruta',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Expanded(child: _CajaArchivo(texto: _texto)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CajaArchivo extends StatelessWidget {
  const _CajaArchivo({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: CupertinoColors.systemGrey),
          borderRadius: BorderRadius.circular(8),
          color: CupertinoColors.white.withOpacity(0.07),
        ),
        child: Text(
          texto,
          style: const TextStyle(
            fontSize: 14,
            color: CupertinoColors.white,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}
