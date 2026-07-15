import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'data/api_service.dart';
import 'data/mek_database.dart';
import 'services/notification_service.dart';

class GestionPosts extends StatefulWidget {
  const GestionPosts({super.key});

  @override
  State<GestionPosts> createState() => _GestionPostsState();
}

class _GestionPostsState extends State<GestionPosts> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apodoController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List<Mek> _meks = const [];
  _OrdenMeks _ordenActual = _OrdenMeks.nombre;
  bool _cargando = true;
  String _estado = 'Cargando meks desde SQLite...';

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    await MekDatabase.instance.init();
    await _sembrarMeksDesdeApiSiEstaVacio();
    await _cargarMeks();
  }

  Future<void> _sembrarMeksDesdeApiSiEstaVacio() async {
    final total = await MekDatabase.instance.contarMeks();
    if (total > 0) return;

    try {
      final posts = await ApiService.obtenerPosts();
      for (final post in posts.take(10)) {
        await MekDatabase.instance.agregarMek(
          nombre: 'Mek ${post.id}',
          apodo: 'Apodo ${post.id}',
          apiId: post.id,
        );
      }
    } catch (_) {
      // Si no hay internet, la pantalla queda lista para agregar meks locales.
    }
  }

  Future<void> _cargarMeks() async {
    final lista = await MekDatabase.instance.listarMeks(
      ordenarPorApodo: _ordenActual == _OrdenMeks.apodo,
    );
    if (!mounted) return;
    setState(() {
      _meks = lista;
      _estado = 'SQLite: ${lista.length} meks guardados';
      _cargando = false;
    });
  }

  Future<String?> _seleccionarFoto() async {
    final source = await showCupertinoModalPopup<ImageSource>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Seleccionar foto'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: const Text('Galeria'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text('Camara'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
      ),
    );

    if (source == null) return null;

    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (pickedFile == null) return null;
      return _guardarFotoEnApp(pickedFile);
    } catch (_) {
      if (!mounted) return null;
      _mostrarAlerta(
        'No se pudo cargar la foto. Revisa los permisos de camara o galeria.',
      );
      return null;
    }
  }

  Future<String> _guardarFotoEnApp(XFile pickedFile) async {
    final appDirectory = await getApplicationDocumentsDirectory();
    final fotosDirectory = Directory(p.join(appDirectory.path, 'meks'));

    if (!await fotosDirectory.exists()) {
      await fotosDirectory.create(recursive: true);
    }

    final extension = p.extension(pickedFile.path).isEmpty
        ? '.jpg'
        : p.extension(pickedFile.path);
    final fileName = 'mek_${DateTime.now().millisecondsSinceEpoch}$extension';
    final savedFile = File(p.join(fotosDirectory.path, fileName));

    await File(pickedFile.path).copy(savedFile.path);
    return savedFile.path;
  }

  Future<void> _mostrarFormularioCrear() async {
    _nombreController.clear();
    _apodoController.clear();
    String? fotoPath;

    await _mostrarFormulario(
      titulo: 'Agregar mek',
      getFotoPath: () => fotoPath,
      setFotoPath: (path) {
        fotoPath = path;
      },
      onGuardar: () async {
        final nombre = _nombreController.text.trim();
        final apodo = _apodoController.text.trim();
        int? apiId;
        var respuestaApi = true;

        try {
          final post = await ApiService.crearPost(
            userId: 1,
            title: nombre,
            body: apodo,
          );
          apiId = post.id;
        } catch (_) {
          respuestaApi = false;
        }

        await MekDatabase.instance.agregarMek(
          nombre: nombre,
          apodo: apodo,
          fotoPath: fotoPath,
          apiId: apiId,
        );

        if (!mounted) return;
        await _cargarMeks();
        setState(() {
          _estado = respuestaApi
              ? 'POST API + SQLite: mek agregado'
              : 'SQLite: mek agregado; API no respondio';
        });
        await _notificar(
          'Mek agregado',
          respuestaApi
              ? 'Se creo el registro en la API y en SQLite'
              : 'Se guardo en SQLite, pero la API no respondio',
        );
      },
    );
  }

  Future<void> _mostrarFormularioEditar(Mek mek) async {
    _nombreController.text = mek.nombre;
    _apodoController.text = mek.apodo;
    String? fotoPath = mek.fotoPath;

    await _mostrarFormulario(
      titulo: 'Editar mek',
      getFotoPath: () => fotoPath,
      setFotoPath: (path) {
        fotoPath = path;
      },
      onGuardar: () async {
        final nombre = _nombreController.text.trim();
        final apodo = _apodoController.text.trim();
        var respuestaApi = true;

        try {
          await ApiService.actualizarPost(
            id: mek.apiId ?? mek.id,
            userId: 1,
            title: nombre,
            body: apodo,
          );
        } catch (_) {
          respuestaApi = false;
        }

        await MekDatabase.instance.actualizarMek(
          id: mek.id,
          nombre: nombre,
          apodo: apodo,
          fotoPath: fotoPath,
          apiId: mek.apiId,
        );

        if (!mounted) return;
        await _cargarMeks();
        setState(() {
          _estado = respuestaApi
              ? 'PUT API + SQLite: mek actualizado'
              : 'SQLite: mek actualizado; API no persistio';
        });
        await _notificar(
          'Mek actualizado',
          respuestaApi
              ? 'Se edito el registro en la API y en SQLite'
              : 'Se edito en SQLite, pero la API no respondio',
        );
      },
    );
  }

  Future<void> _mostrarFormulario({
    required String titulo,
    required String? Function() getFotoPath,
    required void Function(String? path) setFotoPath,
    required Future<void> Function() onGuardar,
  }) async {
    await showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) {
        var guardando = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return CupertinoAlertDialog(
              title: Text(titulo),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    _FotoMek(fotoPath: getFotoPath()),
                    const SizedBox(height: 8),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: guardando
                          ? null
                          : () async {
                              final path = await _seleccionarFoto();
                              if (path == null) return;
                              setDialogState(() {
                                setFotoPath(path);
                              });
                            },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(getFotoPath() == null
                              ? CupertinoIcons.photo_on_rectangle
                              : CupertinoIcons.camera_rotate),
                          const SizedBox(width: 8),
                          Text(getFotoPath() == null
                              ? 'Elegir foto'
                              : 'Cambiar foto'),
                        ],
                      ),
                    ),
                    if (getFotoPath() != null && getFotoPath()!.isNotEmpty)
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: guardando
                            ? null
                            : () {
                                setDialogState(() {
                                  setFotoPath(null);
                                });
                              },
                        child: const Text('Quitar foto'),
                      ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: _nombreController,
                      placeholder: 'Nombre',
                    ),
                    const SizedBox(height: 10),
                    CupertinoTextField(
                      controller: _apodoController,
                      placeholder: 'Apodo',
                    ),
                  ],
                ),
              ),
              actions: [
                CupertinoDialogAction(
                  onPressed: guardando
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: guardando
                      ? null
                      : () async {
                          final nombre = _nombreController.text.trim();
                          final apodo = _apodoController.text.trim();

                          if (nombre.isEmpty || apodo.isEmpty) {
                            _mostrarAlerta('Completa nombre y apodo');
                            return;
                          }

                          setDialogState(() {
                            guardando = true;
                          });

                          try {
                            await onGuardar();
                            if (mounted) Navigator.pop(dialogContext);
                          } catch (e) {
                            if (!mounted) return;
                            setDialogState(() {
                              guardando = false;
                            });
                            _mostrarAlerta('No se pudo guardar: $e');
                          }
                        },
                  child: guardando
                      ? const CupertinoActivityIndicator()
                      : const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _eliminarMek(Mek mek) async {
    final confirmar = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Eliminar mek'),
        content: Text('Deseas eliminar a ${mek.nombre}?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    var respuestaApi = true;
    try {
      await ApiService.eliminarPost(mek.apiId ?? mek.id);
    } catch (_) {
      respuestaApi = false;
    }

    await MekDatabase.instance.eliminarMek(mek.id);
    if (!mounted) return;
    await _cargarMeks();
    setState(() {
      _estado = respuestaApi
          ? 'DELETE API + SQLite: mek eliminado'
          : 'SQLite: mek eliminado; API no persistio';
    });
    await _notificar(
      'Mek eliminado',
      respuestaApi
          ? 'Se elimino el registro en la API y en SQLite'
          : 'Se elimino de SQLite, pero la API no respondio',
    );
  }

  Future<void> _notificar(String titulo, String mensaje) {
    return NotificationService().mostrarNotificacion(
      context: context,
      titulo: titulo,
      mensaje: mensaje,
    );
  }

  void _mostrarAlerta(String mensaje) {
    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        content: Text(mensaje),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apodoController.dispose();
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
            CupertinoIcons.chevron_left,
            color: CupertinoColors.activeBlue,
          ),
        ),
        middle: const Text('Meks del salon'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _mostrarFormularioCrear,
          child: const Icon(
            CupertinoIcons.person_add,
            color: CupertinoColors.activeBlue,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CupertinoSlidingSegmentedControl<_OrdenMeks>(
                groupValue: _ordenActual,
                children: const {
                  _OrdenMeks.nombre: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('Orden: Nombre'),
                  ),
                  _OrdenMeks.apodo: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('Orden: Apodo'),
                  ),
                },
                onValueChanged: (valor) async {
                  if (valor == null) return;
                  setState(() {
                    _ordenActual = valor;
                    _cargando = true;
                  });
                  await _cargarMeks();
                },
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _estado,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      setState(() {
                        _cargando = true;
                      });
                      await _cargarMeks();
                    },
                    child: const Icon(CupertinoIcons.refresh),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _cargando
                  ? const Center(child: CupertinoActivityIndicator())
                  : _meks.isEmpty
                      ? const Center(child: Text('No hay meks guardados.'))
                      : ListView.separated(
                          itemCount: _meks.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final mek = _meks[index];
                            return CupertinoListTile(
                              leading: _FotoMek(fotoPath: mek.fotoPath),
                              title: Text(
                                mek.nombre,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                'Apodo: ${mek.apodo}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () =>
                                        _mostrarFormularioEditar(mek),
                                    child: const Icon(
                                      CupertinoIcons.pencil,
                                      color: CupertinoColors.activeGreen,
                                    ),
                                  ),
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () => _mostrarAlerta(
                                      'Nombre: ${mek.nombre}\nApodo: ${mek.apodo}',
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.info_circle,
                                      color: CupertinoColors.activeBlue,
                                    ),
                                  ),
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () => _eliminarMek(mek),
                                    child: const Icon(
                                      CupertinoIcons.delete,
                                      color: CupertinoColors.systemRed,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FotoMek extends StatelessWidget {
  const _FotoMek({required this.fotoPath});

  final String? fotoPath;

  @override
  Widget build(BuildContext context) {
    if (fotoPath == null || fotoPath!.isEmpty) {
      return _placeholder();
    }

    final file = File(fotoPath!);
    if (!file.existsSync()) {
      return _placeholder();
    }

    return ClipOval(
      child: Image.file(
        file,
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: CupertinoColors.systemGrey4,
      ),
      child: const Icon(
        CupertinoIcons.person_fill,
        color: CupertinoColors.white,
      ),
    );
  }
}

enum _OrdenMeks { nombre, apodo }
