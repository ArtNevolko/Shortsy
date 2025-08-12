import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  const ApiClient(this.baseUrl);

  Future<dynamic> getJson(String path) async {
    final res = await http.get(Uri.parse('$baseUrl$path'));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    }
    throw Exception('GET $path failed: ${res.statusCode}');
  }

  Future<dynamic> postJson(String path, Map<String, dynamic> body) async {
    final res = await http.post(Uri.parse('$baseUrl$path'),
        headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    }
    throw Exception('POST $path failed: ${res.statusCode}');
  }
}
