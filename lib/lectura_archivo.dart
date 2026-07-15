import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class LecturaArchivo extends StatefulWidget {
  const LecturaArchivo({super.key});

  @override
  State<LecturaArchivo> createState() => _LecturaArchivoState();
}

class _LecturaArchivoState extends State<LecturaArchivo> {
  String _texto = 'Presiona el boton para leer datos.txt';

  Future<void> _leerTxt() async {
    final texto = await rootBundle.loadString('assets/datos.txt');
    setState(() {
      _texto = texto;
    });
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
        middle: const Text('Archivo .txt'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CupertinoButton.filled(
                onPressed: _leerTxt,
                child: const Text('Leer datos.txt'),
              ),
              const SizedBox(height: 10),
              _CajaArchivo(texto: _texto),
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
    return Container(
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
        ),
      ),
    );
  }
}
