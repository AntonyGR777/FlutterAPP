# Proyecto Flutter - Proyecto1

Aplicacion Flutter con interfaz estilo Cupertino. El proyecto incluye login,
menu principal, lectura de archivo TXT, SQLite, consumo de API REST, CRUD,
tareas asincronas y notificaciones locales en Windows mediante canal nativo.

## Funcionalidades agregadas

- Login con usuario fijo `admin` y validacion de password con `bcrypt`.
- Registro de nuevos usuarios guardados en SQLite.
- Menu principal tipo action sheet desde la pantalla `Inicio`.
- Lectura simple del archivo `assets/datos.txt`.
- CRUD de "Meks" con SQLite local.
- Consumo de API REST con JSONPlaceholder.
- Crear, editar y eliminar registros usando API + SQLite.
- Notificaciones al crear, editar o eliminar registros.
- Notificaciones nativas en Windows usando `MethodChannel`.
- Pantalla de pruebas de notificaciones.
- Pantalla de tareas asincronas:
  - `FutureBuilder`
  - `async/await`
  - `Isolate.run`
  - `Timer.periodic`
- Diagrama de clases en `docs/uml.md`.
- Version PlantUML del diagrama en `docs/diagrama_clases.puml`.

## Credenciales de prueba

```text
Usuario: admin
Password: admin123
```

Tambien se pueden crear nuevos usuarios desde la pantalla de login.

## Menu de la app

La pantalla principal tiene un boton de menu en la esquina superior derecha.
Desde ese menu se puede abrir:

- Meks
- Archivo TXT
- Tareas asincronas
- Notificaciones
- Usuarios SQLite

## Estructura principal

```text
lib/
  main.dart
  inicio.dart
  gestion_posts.dart
  lectura_archivo.dart
  pantalla_notificaciones.dart
  tareas_asincronas.dart
  terminos.dart
  data/
    api_service.dart
    mek_database.dart
    post_model.dart
    usuario_database.dart
  services/
    notification_service.dart

assets/
  datos.txt

docs/
  uml.md
  diagrama_clases.puml
  uml_diagrama.svg
```

## Pantallas

### Login

Archivo: `lib/main.dart`

Permite iniciar sesion con el usuario `admin` o con usuarios creados en SQLite.
Tambien incluye acceso a terminos y condiciones.

### Inicio

Archivo: `lib/inicio.dart`

Pantalla principal de la app. Tiene controles como slider, switch, radio
buttons, picker y el menu principal.

### Meks

Archivo: `lib/gestion_posts.dart`

Permite agregar, editar, listar y eliminar registros. Cada accion se guarda en
SQLite y tambien intenta sincronizar con la API de JSONPlaceholder.

Cuando se crea, edita o elimina un registro, la app muestra una notificacion.

### Archivo TXT

Archivo: `lib/lectura_archivo.dart`

Lee el archivo:

```text
assets/datos.txt
```

La lectura se hace de forma simple con:

```dart
rootBundle.loadString('assets/datos.txt');
```

### Tareas asincronas

Archivo: `lib/tareas_asincronas.dart`

Muestra ejemplos de programacion asincrona en Flutter:

- Carga con `FutureBuilder`.
- Ejecucion con `async/await`.
- Trabajo en segundo plano con `Isolate.run`.
- Contador con `Timer.periodic`.

### Notificaciones

Archivo: `lib/pantalla_notificaciones.dart`

Permite probar diferentes notificaciones desde botones.

Servicio:

```text
lib/services/notification_service.dart
```

En Windows se usa un canal nativo:

```text
proyecto1/notificaciones
```

La implementacion nativa esta en:

```text
windows/runner/flutter_window.cpp
```

## Base de datos SQLite

El proyecto usa SQLite con `sqflite_common_ffi`.

Archivos importantes:

- `lib/data/usuario_database.dart`
- `lib/data/mek_database.dart`

Tablas principales:

- `usuarios`
- `meks`

## API REST

Archivo:

```text
lib/data/api_service.dart
```

API usada:

```text
https://jsonplaceholder.typicode.com
```

Metodos incluidos:

- `obtenerPosts`
- `obtenerPostPorId`
- `crearPost`
- `actualizarPost`
- `eliminarPost`

Nota: JSONPlaceholder simula las operaciones, pero los cambios no quedan
guardados permanentemente en el servidor.

## Dependencias principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  get: ^4.6.6
  bcrypt: ^1.1.3
  path: ^1.9.1
  sqflite_common_ffi: ^2.4.0+3
  http: ^1.6.0
  image_picker: ^1.1.2
  path_provider: ^2.1.5
```

## Ejecutar el proyecto

Instalar dependencias:

```bash
flutter pub get
```

Ejecutar:

```bash
flutter run
```

Ejecutar en Windows:

```bash
flutter run -d windows
```

Compilar para Windows:

```bash
flutter build windows
```

## Diagrama de clases

El diagrama esta en:

```text
docs/uml.md
```

GitHub puede mostrar el diagrama Mermaid directamente al abrir ese archivo.

Tambien existe una version PlantUML:

```text
docs/diagrama_clases.puml
```

## Subir cambios a GitHub

Desde la carpeta del repositorio:

```bash
git status
git add .
git commit -m "Actualizar proyecto Flutter"
git push origin main
```

Si GitHub tiene cambios que no estan en tu computadora:

```bash
git pull origin main --allow-unrelated-histories
git push origin main
```

## Nota sobre iPhone

El proyecto se puede subir a GitHub desde Windows, pero para probarlo en un
iPhone se necesita una Mac con Xcode o un servicio de compilacion iOS en la
nube. Desde Windows no se puede compilar directamente para iOS.

## Version

```text
0.1.0+1
```
