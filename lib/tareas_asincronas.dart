import 'dart:async';
import 'dart:isolate';

import 'package:flutter/cupertino.dart';

class TareasAsincronas extends StatefulWidget {
  const TareasAsincronas({super.key});

  @override
  State<TareasAsincronas> createState() => _TareasAsincronasState();
}

class _TareasAsincronasState extends State<TareasAsincronas> {
  late Future<String> _futureData;
  String _asyncAwaitResult = 'Esperando...';
  int _timerCount = 0;
  String _computeResult = 'Esperando...';
  bool _isLoadingCompute = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _futureData = _simularCargaFuture();
  }

  Future<String> _simularCargaFuture() {
    return Future.delayed(
      const Duration(seconds: 2),
      () => 'Datos cargados exitosamente desde FutureBuilder',
    );
  }

  void _ejecutarAsyncAwait() async {
    setState(() {
      _asyncAwaitResult = 'Cargando...';
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _asyncAwaitResult = 'Operación completada con async/await';
      });
    }
  }

  static String _contarLetrasEnIsolate(String texto) {
    final letras = texto.replaceAll(' ', '').length;
    return '"$texto" tiene $letras letras';
  }

  void _ejecutarCompute() async {
    setState(() {
      _isLoadingCompute = true;
      _computeResult = 'Contando letras en isolate...';
    });

    try {
      final resultado = await Isolate.run(
        () => _contarLetrasEnIsolate('Mexico Mundial'),
      );
      if (mounted) {
        setState(() {
          _computeResult = resultado;
          _isLoadingCompute = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _computeResult = 'Error: $e';
          _isLoadingCompute = false;
        });
      }
    }
  }

  void _iniciarTimer() {
    _timer?.cancel();
    _timerCount = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _timerCount++;
        });
      }
    });
  }

  void _detenerTimer() {
    _timer?.cancel();
    if (mounted) {
      setState(() {
        _timerCount = 0;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
        middle: const Text('Tareas'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildSeccion(
                    titulo: '1. FutureBuilder',
                    child: FutureBuilder<String>(
                      future: _futureData,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CupertinoActivityIndicator();
                        } else if (snapshot.hasError) {
                          return Text(
                            'Error: ${snapshot.error}',
                            textAlign: TextAlign.center,
                          );
                        } else if (snapshot.hasData) {
                          return _buildResultado(
                            texto: snapshot.data!,
                            color: CupertinoColors.activeGreen,
                          );
                        } else {
                          return const Text('Sin datos');
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSeccion(
                    titulo: '2. Async/Await',
                    child: Column(
                      children: [
                        _buildResultado(
                          texto: _asyncAwaitResult,
                          color: CupertinoColors.activeBlue,
                        ),
                        const SizedBox(height: 12),
                        CupertinoButton.filled(
                          onPressed: _ejecutarAsyncAwait,
                          child: const Text('Ejecutar Async/Await'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSeccion(
                    titulo: '3. Compute (Isolate)',
                    child: Column(
                      children: [
                        _buildResultado(
                          texto: _computeResult,
                          color: CupertinoColors.systemOrange,
                        ),
                        const SizedBox(height: 12),
                        CupertinoButton.filled(
                          onPressed:
                              _isLoadingCompute ? null : _ejecutarCompute,
                          child: _isLoadingCompute
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CupertinoActivityIndicator(radius: 8),
                                )
                              : const Text('Ejecutar Compute'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSeccion(
                    titulo: '4. Timer.periodic',
                    child: Column(
                      children: [
                        _buildResultado(
                          texto: 'Contador: $_timerCount segundos',
                          color: CupertinoColors.systemRed,
                          fontSize: 24,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CupertinoButton.filled(
                              onPressed: _iniciarTimer,
                              child: const Text('Iniciar'),
                            ),
                            const SizedBox(width: 16),
                            CupertinoButton(
                              color: CupertinoColors.systemRed,
                              onPressed: _detenerTimer,
                              child: const Text('Detener'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeccion({
    required String titulo,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          titulo,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.activeBlue,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildResultado({
    required String texto,
    required Color color,
    double fontSize = 16,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
