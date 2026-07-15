import 'package:http/http.dart' as http;
import 'dart:convert';
import 'post_model.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  // GET: Obtener todos los posts
  static Future<List<Post>> obtenerPosts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts'),
      ).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener posts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // GET: Obtener un post por ID
  static Future<Post> obtenerPostPorId(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts/$id'),
      ).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        return Post.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Post no encontrado');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // POST: Crear un nuevo post
  static Future<Post> crearPost({
    required int userId,
    required String title,
    required String body,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'title': title,
          'body': body,
        }),
      ).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 201) {
        return Post.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al crear post: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // PUT: Actualizar un post
  static Future<Post> actualizarPost({
    required int id,
    required int userId,
    required String title,
    required String body,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/posts/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': id,
          'userId': userId,
          'title': title,
          'body': body,
        }),
      ).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        return Post.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al actualizar post: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // DELETE: Eliminar un post
  static Future<bool> eliminarPost(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/posts/$id'),
      ).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Error al eliminar post: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
