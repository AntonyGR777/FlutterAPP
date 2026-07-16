import 'package:flutter/cupertino.dart';
import 'package:bcrypt/bcrypt.dart';
import 'data/usuario_database.dart';
import 'inicio.dart';
import 'terminos.dart';
import 'services/notification_service.dart';
import 'services/session_service.dart';
//import 'package:flutter_test_app/home.dart';

const _KUsername = 'admin';
const _KPasswordHash = r'$2a$10$TN42UWKt23z.hjVIS5aJDePGmLsGJ5xQFVFw6d4IBRY/er3E9x4wu';

const _KAppGray = Color.fromARGB(255, 48, 48, 48);
const _KAppDarkGray = Color.fromARGB(255, 36, 36, 36);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar notificaciones
  await NotificationService().initialize();
  await UsuarioDatabase.instance.init();
  
  runApp(
    const CupertinoApp(home: HardcodedApp(), debugShowCheckedModeBanner: false),);
}

class HardcodedApp extends StatelessWidget {
  const HardcodedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MiApp();
  }
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: CupertinoColors.extraLightBackgroundGray,
        primaryContrastingColor: Color.fromARGB(255, 67, 0, 251),
        barBackgroundColor: _KAppDarkGray,
        scaffoldBackgroundColor: _KAppGray,
        selectionHandleColor: _KAppDarkGray,
      ),
      home: const _MiAppHome(),
    );
  }
}



class _MiAppHome extends StatefulWidget {
  const _MiAppHome();

  @override
  State<_MiAppHome> createState() => _MiAppHomeState();
}

class _MiAppHomeState extends State<_MiAppHome> {
  bool isDarkMode = false;
  // Controlador para leer el texto del campo de correo
  TextEditingController textController = TextEditingController();
  // Controlador para la contraseÃ±a
  TextEditingController passwordController = TextEditingController();
  final TextEditingController nuevoUsuarioController = TextEditingController();
  final TextEditingController nuevaPasswordController = TextEditingController();
  bool checkboxValue = false;
  // Indica si la Ãºltima validaciÃ³n fue invÃ¡lida para cambiar el texto del botÃ³n
  bool validationFailed = false;
  // Texto que se muestra arriba y cambia segÃºn la validaciÃ³n
  String displayText = 'Hola';
  final today = DateTime.now();

  // FunciÃ³n que valida si el texto ingresado tiene formato de correo electrÃ³nico
 // bool _isValidEmail(String value) {
   // final emailRegex = RegExp(r"^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$");
   // return emailRegex.hasMatch(value);
  //}

  // FunciÃ³n que valida si el usuario es 'admin'

  Future<bool> _validarLogin(String usuario, String password) async {
    if (usuario == _KUsername && BCrypt.checkpw(password, _KPasswordHash)) {
      return true;
    }

    final usuarios = await UsuarioDatabase.instance.listarUsuarios();
    for (final item in usuarios) {
      final nombre = item['nombre'] as String;
      final hash = item['passwordHash'] as String;
      if (nombre == usuario && BCrypt.checkpw(password, hash)) {
        return true;
      }
    }

    return false;
  }

  Future<void> _mostrarLoginExitoso() async {
    await showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('Login exitoso'),
          content: const Text('Bienvenido de nuevo.'),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _mostrarFormularioNuevoUsuario() async {
    nuevoUsuarioController.clear();
    nuevaPasswordController.clear();

    await showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('Nuevo usuario'),
          content: Column(
            children: [
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: nuevoUsuarioController,
                placeholder: 'Usuario',
              ),
              const SizedBox(height: 10),
              CupertinoTextField(
                controller: nuevaPasswordController,
                placeholder: 'ContraseÃ±a',
                obscureText: true,
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                final usuario = nuevoUsuarioController.text.trim();
                final password = nuevaPasswordController.text.trim();

                if (usuario.isEmpty || password.isEmpty) {
                  setState(() {
                    displayText = 'Completa usuario y contraseÃ±a';
                  });
                  return;
                }

                await UsuarioDatabase.instance.guardarUsuario(
                  nombre: usuario,
                  password: password,
                );

                if (!mounted) return;
                Navigator.pop(dialogContext);
                setState(() {
                  displayText = 'Usuario creado';
                  textController.text = usuario;
                  passwordController.clear();
                });
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    textController.dispose();
    passwordController.dispose();
    nuevoUsuarioController.dispose();
    nuevaPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: _KAppGray,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayText,
                    style: const TextStyle(
                      fontSize: 26,
                      color: CupertinoColors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  CupertinoTextField(
                    controller: textController,
                    placeholder: 'Usuario',
                    placeholderStyle: const TextStyle(color: CupertinoColors.systemGrey),
                    style: const TextStyle(color: CupertinoColors.white),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white.withOpacity(0.12),
                      border: Border.all(color: CupertinoColors.systemGrey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CupertinoTextField(
                    controller: passwordController,
                    placeholder: 'Contrasena',
                    placeholderStyle: const TextStyle(color: CupertinoColors.systemGrey),
                    style: const TextStyle(color: CupertinoColors.white),
                    obscureText: true,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white.withOpacity(0.12),
                      border: Border.all(color: CupertinoColors.systemGrey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CupertinoCheckbox(
                        value: checkboxValue,
                        onChanged: (v) {
                          if (v != null) {
                            setState(() {
                              checkboxValue = v;
                            });
                          }
                        },
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => TerceraPagina(),
                            ),
                          );
                        },
                        child: const Text(
                          'Terminos y condiciones',
                          style: TextStyle(
                            color: CupertinoColors.activeBlue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  

                  Row(
                    
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CupertinoButton.filled(
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          final usuario = textController.text.trim();
                          final contrasena = passwordController.text.trim();
                          final loginValido =
                              await _validarLogin(usuario, contrasena);

                          if (loginValido) {
                            SessionService.iniciarSesion(usuario);
                            setState(() {
                              displayText = 'Login exitoso';
                              validationFailed = false;
                            });
                            await _mostrarLoginExitoso();
                            if (!mounted) return;
                            navigator.push(
                              CupertinoPageRoute(
                                builder: (context) => const Inicio(),
                              ),
                            );
                          } else {
                            setState(() {
                              displayText = 'Usuario o contraseña incorrectos';
                              validationFailed = true;
                            });
                          }
                        },
                        child: const Text('Presionar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  CupertinoButton(
                    onPressed: _mostrarFormularioNuevoUsuario,
                    child: const Text('Agregar nuevo usuario'),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}
