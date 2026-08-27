import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);
  @override
  String toString() => message;
}

class ApiService {
  static const _tokenKey = 'access_token';

  Future<String?> getToken() async =>
      (await SharedPreferences.getInstance()).getString(_tokenKey);

  Future<void> saveToken(String token) async =>
      (await SharedPreferences.getInstance()).setString(_tokenKey, token);

  Future<void> logout() async =>
      (await SharedPreferences.getInstance()).remove(_tokenKey);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/auth/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': email, 'password': password},
    );
    final body = _map(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(body['detail']?.toString() ?? 'Login failed.', response.statusCode);
    }
    final token = body['access_token']?.toString();
    if (token == null || token.isEmpty) throw ApiException('No token returned.');
    await saveToken(token);
    return body;
  }

  Future<Map<String, dynamic>> scan(String direction, XFile image) async {
    final token = await _token();
    final req = http.MultipartRequest(
      'POST', Uri.parse('${AppConfig.apiBaseUrl}/parking/scan'),
    );
    req.headers['Authorization'] = 'Bearer $token';
    req.fields['direction'] = direction;
    req.files.add(await http.MultipartFile.fromPath('file', image.path));
    final response = await http.Response.fromStream(await req.send());
    final body = _map(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(body['detail']?.toString() ?? 'Scan failed.', response.statusCode);
    }
    return body;
  }

  Future<Map<String, dynamic>> manual(String direction, String plate) =>
      _post('/parking/manual', {'direction': direction, 'plate_number': plate});

  Future<List<dynamic>> active() => _getList('/parking/active');
  Future<List<dynamic>> history() => _getList('/parking/history?limit=100');
  Future<Map<String, dynamic>> summary() => _getMap('/parking/summary');

  Future<String> _token() async {
    final token = await getToken();
    if (token == null || token.isEmpty) throw ApiException('Not logged in.', 401);
    return token;
  }

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> payload) async {
    final token = await _token();
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}$path'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    final body = _map(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(body['detail']?.toString() ?? 'Request failed.', response.statusCode);
    }
    return body;
  }

  Future<Map<String, dynamic>> _getMap(String path) async {
    final token = await _token();
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}$path'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final body = _map(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(body['detail']?.toString() ?? 'Request failed.', response.statusCode);
    }
    return body;
  }

  Future<List<dynamic>> _getList(String path) async {
    final token = await _token();
    final response = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}$path'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final decoded = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final detail = decoded is Map ? decoded['detail']?.toString() : null;
      throw ApiException(detail ?? 'Request failed.', response.statusCode);
    }
    if (decoded is! List) throw ApiException('Expected a list from server.');
    return decoded;
  }

  Map<String, dynamic> _map(http.Response response) {
    if (response.body.isEmpty) return {};
    final decoded = jsonDecode(response.body);
    return decoded is Map<String, dynamic> ? decoded : {};
  }
}
