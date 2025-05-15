import 'package:http/http.dart' as http;

class TelegramSession {
  String _cookies = '';

  Future<String> get(String url, Map<String, String> headers) async {
    final uri = Uri.parse(url);
    headers['cookie'] = _cookies;
    final response = await http.get(uri, headers: headers);
    _updateCookies(response.headers['set-cookie']);
    return response.body;
  }

  Future<String> post(
      String url, Map<String, String> headers, String body) async {
    final uri = Uri.parse(url);
    headers['cookie'] = _cookies;
    final response = await http.post(uri, headers: headers, body: body);
    _updateCookies(response.headers['set-cookie']);
    return response.body;
  }

  void _updateCookies(String? setCookieHeader) {
    if (setCookieHeader != null) {
      final cookiesInfo = setCookieHeader.split(',');
      _cookies = _mergeCookies(_cookies, cookiesInfo);
    }
  }

  String _mergeCookies(String existingCookies, List<String> newCookies) {
    for (final cookie in newCookies) {
      if (cookie.split('=').length < 2) continue;

      final name = cookie.split('=')[0];
      if (!(name.contains('path') ||
          name.contains('samesite') ||
          name.contains('secure') ||
          name.contains('expires'))) {
        final cleanedCookie = cookie.replaceAll('HttpOnly,', '').trim();
        if (!cleanedCookie.contains('DELETED')) {
          existingCookies = '$existingCookies$cleanedCookie;';
        }
      }
    }
    return existingCookies;
  }
}
