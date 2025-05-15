import 'package:html/parser.dart' show parse;
import 'package:telegram_login_flutter/src/models/telegram_user.dart';
import 'package:telegram_login_flutter/src/session.dart';
import 'package:url_launcher/url_launcher.dart';

class TelegramAuth {
  final TelegramSession _session = TelegramSession();
  final String phoneNumber;
  final String botId;
  final String botDomain;
  final Duration timeout;

  TelegramUser? _user;

  TelegramAuth({
    required this.phoneNumber,
    required this.botId,
    required this.botDomain,
    this.timeout = const Duration(seconds: 60),
  });

  Future<void> launchTelegram() async {
    final Uri serviceChatUri = Uri.parse('tg://openmessage?user_id=777000');

    final Uri telegramAppUri = Uri.parse('tg://');

    final Uri webUri = Uri.parse('https://telegram.org');

    try {
      // Try to open Service Notifications chat
      bool launched = await launchUrl(
        serviceChatUri,
        mode: LaunchMode.externalApplication,
      );

      // If failed, try opening the main Telegram app
      if (!launched) {
        launched = await launchUrl(
          telegramAppUri,
          mode: LaunchMode.externalApplication,
        );
      }

      // If both app attempts failed, open website
      if (!launched) {
        if (!await launchUrl(webUri, mode: LaunchMode.externalApplication)) {
          throw Exception('Could not open Telegram');
        }
      }
    } catch (e) {
      // If any error occurs, try opening the website
      if (!await launchUrl(webUri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not open Telegram');
      }
    }
  }

  Future<bool> initiateLogin() async {
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'origin': 'https://oauth.telegram.org',
    };

    try {
      final cleanedPhone = phoneNumber
          .replaceAll(RegExp(r'\+'), '')
          .replaceAll(RegExp(r' '), '');

      final response = await _session.post(
        'https://oauth.telegram.org/auth/request?bot_id=$botId&origin=$botDomain&embed=1',
        headers,
        'phone=$cleanedPhone',
      );
      return response.trim().toLowerCase() == 'true';
    } catch (e) {
      throw Exception('Failed to initiate login: $e');
    }
  }

  Future<bool> checkLoginStatus() async {
    final headers = {
      'Content-length': '0',
      'Content-Type': 'application/x-www-form-urlencoded',
      'origin': 'https://oauth.telegram.org',
    };

    try {
      final response = await _session.post(
        'https://oauth.telegram.org/auth/login?bot_id=$botId&origin=$botDomain&embed=1',
        headers,
        '',
      );
      return response.trim().toLowerCase() == 'true';
    } catch (e) {
      throw Exception('Failed to check login status: $e');
    }
  }

  Future<TelegramUser?> getUserData() async {
    bool isLoggedIn = await checkLoginStatus();
    if (!isLoggedIn) {
      final loginSuccess = await initiateLogin();
      if (!loginSuccess) {
        throw Exception('Re-authentication failed');
      }
    }

    try {
      final response = await _session.get(
        'https://oauth.telegram.org/auth?bot_id=$botId&origin=$botDomain&embed=1',
        {},
      );

      if (response
          .contains('postMessage(JSON.stringify({event: \'auth_result\'')) {
        final regex = RegExp(r'result: ({.*}), origin');
        final match = regex.firstMatch(response);

        if (match == null) {
          throw Exception('Failed to extract JSON data');
        }

        final jsonString = match.group(1)!;
        final userData = _parseUserData(jsonString);
        _user = TelegramUser.fromJson(userData);
        return _user;
      }

      final confirmUrl = _extractConfirmUrl(response);
      if (confirmUrl == null) {
        throw Exception('Failed to extract confirm_url');
      }

      final confirmResponse = await _session.get(
        'https://oauth.telegram.org$confirmUrl',
        {},
      );

      final confirmRegex = RegExp(r'result: ({.*}), origin');
      final confirmMatch = confirmRegex.firstMatch(confirmResponse);

      if (confirmMatch == null) {
        throw Exception('Failed to extract JSON data after confirmation');
      }

      final confirmJsonString = confirmMatch.group(1)!;
      final userData = _parseUserData(confirmJsonString);
      _user = TelegramUser.fromJson(userData);
      return _user;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  Map<String, dynamic> _parseUserData(String jsonString) {
    final userData = <String, dynamic>{};

    final idMatch = RegExp(r'"id":\s*"?(\d+)"?').firstMatch(jsonString);
    final firstNameMatch =
        RegExp(r'"first_name":\s*"(.*?)"').firstMatch(jsonString);
    final lastNameMatch =
        RegExp(r'"last_name":\s*"(.*?)"').firstMatch(jsonString);
    final usernameMatch =
        RegExp(r'"username":\s*"(.*?)"').firstMatch(jsonString);
    final photoUrlMatch =
        RegExp(r'"photo_url":\s*"(.*?)"').firstMatch(jsonString);
    final authDateMatch =
        RegExp(r'"auth_date":\s*"?(\d+)"?').firstMatch(jsonString);
    final hashMatch = RegExp(r'"hash":\s*"(.*?)"').firstMatch(jsonString);

    userData['id'] = idMatch?.group(1) ?? '';
    userData['first_name'] = firstNameMatch?.group(1) ?? '';
    userData['last_name'] = lastNameMatch?.group(1) ?? '';
    userData['username'] = usernameMatch?.group(1) ?? '';
    userData['photo_url'] = photoUrlMatch?.group(1) ?? '';
    userData['auth_date'] = authDateMatch?.group(1) ?? '';
    userData['hash'] = hashMatch?.group(1) ?? '';
    userData['raw_json'] = jsonString;

    return userData;
  }

  String? _extractConfirmUrl(String htmlResponse) {
    final document = parse(htmlResponse);
    final scriptTags = document.getElementsByTagName('script');

    for (final script in scriptTags) {
      if (script.text.contains('function confirmRequest')) {
        final regex = RegExp(r"confirm_url\s*=\s*'([^']+)'");
        final match = regex.firstMatch(script.text);
        return match?.group(1);
      }
    }
    return null;
  }
}
