import 'package:emergencyreporter/utils/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final ApiClient apiClient;
  AuthRepository(this.apiClient);

  Future<Map<String, dynamic>> signup(String email, String password, {String role = 'citizen'}) async {
    final res = await apiClient.post('/auth/signup', body: {
      'email': email,
      'password': password,
      'role': role,
    });
    return res['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await apiClient.post('/auth/login', body: {
      'email': email,
      'password': password,
    });
    return res['data'] as Map<String, dynamic>;
  }

  Future<String> refresh(String refreshToken) async {
    final res = await apiClient.post('/auth/refresh', body: {
      'refreshToken': refreshToken,
    });
    final data = res['data'] as Map<String, dynamic>;
    return data['accessToken'] as String;
  }

  static const _kAccess = 'access_token_v1';
  static const _kRefresh = 'refresh_token_v1';

  Future<void> saveTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccess, access);
    await prefs.setString(_kRefresh, refresh);
    apiClient.setAccessToken(access);
  }

  Future<String?> loadAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_kAccess);
    apiClient.setAccessToken(token);
    return token;
  }

  Future<String?> loadRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kRefresh);
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAccess);
    await prefs.remove(_kRefresh);
    apiClient.setAccessToken(null);
  }
}


