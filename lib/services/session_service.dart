class SessionService {
  SessionService._();

  static String usuarioActual = 'Sin sesion';

  static void iniciarSesion(String usuario) {
    usuarioActual = usuario.trim().isEmpty ? 'Sin sesion' : usuario.trim();
  }

  static void cerrarSesion() {
    usuarioActual = 'Sin sesion';
  }
}
