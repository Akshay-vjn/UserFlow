import 'dart:convert';
import 'package:http/http.dart' as http;

const String _reqresApiKey = String.fromEnvironment('REQRES_API_KEY', defaultValue: 'reqres-free-v1');

class ApiClient {
  String baseUrl = 'https://reqres.in/api';
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _defaultHeaders({bool json = false}) {
    final headers = <String, String>{
      'Accept': 'application/json',
      'x-api-key': _reqresApiKey,
    };
    if (json) headers['Content-Type'] = 'application/json';
    return headers;
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final response = await _client.get(uri, headers: _defaultHeaders());
    return _handleResponse(uri, response);
  }

  Future<Map<String, dynamic>> post(String path, dynamic body) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await _client.post(uri, headers: _defaultHeaders(json: true), body: jsonEncode(body));
    return _handleResponse(uri, response);
  }

  Future<Map<String, dynamic>> put(String path, dynamic body) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await _client.put(uri, headers: _defaultHeaders(json: true), body: jsonEncode(body));
    return _handleResponse(uri, response);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await _client.delete(uri, headers: _defaultHeaders());
    return _handleResponse(uri, response);
  }

  Map<String, dynamic> _handleResponse(Uri uri, http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return <String, dynamic>{};
      final decoded = jsonDecode(response.body);
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{'data': decoded};
    } else {
      final bodyPreview = response.body.length > 200 ? response.body.substring(0, 200) + '…' : response.body;
      throw Exception('HTTP ${response.statusCode} for ${uri.toString()}\nBody: $bodyPreview');
    }
  }
}
