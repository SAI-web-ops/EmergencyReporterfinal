import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  final Map<String, String> defaultHeaders;
  String? _accessToken;

  ApiClient({required this.baseUrl, Map<String, String>? defaultHeaders})
      : defaultHeaders = defaultHeaders ?? const {'Content-Type': 'application/json'};

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    return Uri.parse('$baseUrl$path').replace(queryParameters: query?.map((k, v) => MapEntry(k, '$v')));
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query}) async {
    final res = await http.get(_uri(path, query), headers: _headers());
    _ensureOk(res);
    return json.decode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> post(String path, {Object? body}) async {
    final res = await http.post(_uri(path), headers: _headers(), body: body == null ? null : json.encode(body));
    _ensureOk(res, [200, 201]);
    return json.decode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> patch(String path, {Object? body}) async {
    final res = await http.patch(_uri(path), headers: _headers(), body: body == null ? null : json.encode(body));
    _ensureOk(res);
    return json.decode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> uploadFile(String path, File file, {String fieldName = 'file'}) async {
    final uri = _uri(path);
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
    // Copy non-JSON content-type headers except content-type
    _headers().forEach((k, v) {
      if (k.toLowerCase() != 'content-type') request.headers[k] = v;
    });
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    _ensureOk(res, [200, 201]);
    return json.decode(res.body) as Map<String, dynamic>;
  }

  void setAccessToken(String? token) {
    _accessToken = token;
  }

  Map<String, String> _headers() {
    final h = Map<String, String>.from(defaultHeaders);
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      h['Authorization'] = 'Bearer $_accessToken';
    }
    return h;
  }

  void _ensureOk(http.Response res, [List<int> ok = const [200]]) {
    if (!ok.contains(res.statusCode)) {
      throw ApiException('Request failed: ${res.statusCode} ${res.body}');
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => 'ApiException: $message';
}
