import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'data/usuario_database.dart';
import 'lectura_archivo.dart';
import 'gestion_posts.dart';
import 'tareas_asincronas.dart';

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  double tamanioTexto = 30;
  bool textoGrande = false;

  String sexoSeleccionado = 'Ninguno';

  final List<String> paises = [
    'México',
    'Estados Unidos',
    'Canadá',
    'España',
  ];

  int paisSeleccionado = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Icon(Icons.arrow_back, size: 25, color: Colors.blue),
        ),
          ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // TEXTO
                Text(
                  'Textoooooooo',
                  style: TextStyle(
                    fontSize:
                        textoGrande ? tamanioTexto + 20 : tamanioTexto,
                    color: CupertinoColors.activeBlue,
                  ),
                ),

                const SizedBox(height: 10),

                // SLIDER
                Text(
                  'Tamaño: ${tamanioTexto.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 18),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CupertinoSlider(
                    value: tamanioTexto,
                    min: 10,
                    max: 100,
                    onChanged: (value) {
                      setState(() {
                        tamanioTexto = value;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // TOGGLE
                const Text(
                  'Texto grande',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                CupertinoSwitch(
                  value: textoGrande,
                  onChanged: (value) {
                    setState(() {
                      textoGrande = value;
                    });
                  },
                ),

                Text(
                  textoGrande
                      ? 'Toggle Activado'
                      : 'Toggle Desactivado',
                  style: const TextStyle(fontSize: 18),
                ),

                const SizedBox(height: 20),

                const TarjetaMundialMexico(),

                const SizedBox(height: 20),

                // BOTONES
                SizedBox(
                  width: 260,
                  child: CupertinoButton.filled(
                    onPressed: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => const GestionPosts(),
                        ),
                      );
                    },
                    child: const Text(
                      'Meks',
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: 260,
                  child: CupertinoButton(
                    color: CupertinoColors.systemGrey,
                    onPressed: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => const LecturaArchivo(),
                        ),
                      );
                    },
                    child: const Text(
                      'Txt',
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: 260,
                  child: CupertinoButton(
                    color: CupertinoColors.systemIndigo,
                    onPressed: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => const TareasAsincronas(),
                        ),
                      );
                    },
                    child: const Text(
                      'Tareas',
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // RADIO BUTTONS
                const Text(
                  'Selecciona tu sexo:',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Material(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Radio<String>(
                            value: 'Masculino',
                            groupValue: sexoSeleccionado,
                            onChanged: (value) {
                              setState(() {
                                sexoSeleccionado = value!;
                              });
                            },
                          ),
                          const Text('Masculino'),
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Radio<String>(
                            value: 'Femenino',
                            groupValue: sexoSeleccionado,
                            onChanged: (value) {
                              setState(() {
                                sexoSeleccionado = value!;
                              });
                            },
                          ),
                          const Text('Femenino'),
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Radio<String>(
                            value: 'Otro',
                            groupValue: sexoSeleccionado,
                            onChanged: (value) {
                              setState(() {
                                sexoSeleccionado = value!;
                              });
                            },
                          ),
                          const Text('Otro'),
                        ],
                      ),
                    ],
                  ),
                ),

                Text(
                  'Sexo seleccionado: $sexoSeleccionado',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                // PICKER
                const Text(
                  'Selecciona tu país:',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(
                  height: 120,
                  child: CupertinoPicker(
                    itemExtent: 32,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        paisSeleccionado = index;
                      });
                    },
                    children: paises.map((pais) {
                      return Center(
                        child: Text(
                          pais,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                Text(
                  'País seleccionado: ${paises[paisSeleccionado]}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),
          
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SQLiteUsuariosPage extends StatefulWidget {
  const SQLiteUsuariosPage({super.key});

  @override
  State<SQLiteUsuariosPage> createState() => _SQLiteUsuariosPageState();
}

class _SQLiteUsuariosPageState extends State<SQLiteUsuariosPage> {
  late Future<List<Map<String, Object?>>> _usuariosFuture;

  @override
  void initState() {
    super.initState();
    _usuariosFuture = UsuarioDatabase.instance.init().then((_) {
      return UsuarioDatabase.instance.listarUsuarios();
    });
  }

  Future<void> _recargar() async {
    setState(() {
      _usuariosFuture = UsuarioDatabase.instance.listarUsuarios();
    });
    await _usuariosFuture;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('SQLite usuarios'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _recargar,
          child: const Icon(CupertinoIcons.refresh),
        ),
      ),
      child: SafeArea(
        child: FutureBuilder<List<Map<String, Object?>>>(
          future: _usuariosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CupertinoActivityIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error al leer SQLite: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              );
            }

            final usuarios = snapshot.data ?? const [];

            if (usuarios.isEmpty) {
              return const Center(
                child: Text('La tabla usuarios está vacía.'),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: usuarios.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final usuario = usuarios[index];
                final id = usuario['id'];
                final nombre = usuario['nombre'];
                final createdAt = usuario['createdAt'];
                final passwordHash = usuario['passwordHash'];

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: CupertinoColors.systemGrey4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: $id'),
                      const SizedBox(height: 4),
                      Text('Usuario: $nombre'),
                      const SizedBox(height: 4),
                      Text('Creado: $createdAt'),
                      const SizedBox(height: 4),
                      Text(
                        'Hash: $passwordHash',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class TarjetaMundialMexico extends StatelessWidget {
  const TarjetaMundialMexico({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 150,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF006847),
            Color(0xFFF7F7F7),
            Color(0xFFCE1126),
          ],
        ),
        border: Border.all(color: CupertinoColors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.30),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Text(
        'Y si si?',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: CupertinoColors.black,
          fontSize: 34,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
          shadows: [
            Shadow(
              color: CupertinoColors.white,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}
