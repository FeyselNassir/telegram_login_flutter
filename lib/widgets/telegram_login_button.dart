import 'package:flutter/material.dart';
import 'package:telegram_login_flutter/src/models/telegram_user.dart';
import 'package:telegram_login_flutter/src/telegram_login.dart';

class TelegramLoginButton extends StatefulWidget {
  final String botId;
  final String botDomain;
  final String phoneNumber;
  final Duration timeout;
  final Function(TelegramUser)? onAuthSuccess;
  final Function(dynamic)? onAuthError;
  final Widget? child;
  final ButtonStyle? style;
  final bool showLoading;

  const TelegramLoginButton({
    super.key,
    required this.botId,
    required this.botDomain,
    required this.phoneNumber,
    this.timeout = const Duration(seconds: 60),
    this.onAuthSuccess,
    this.onAuthError,
    this.child,
    this.style,
    this.showLoading = true,
  });

  @override
  // ignore: library_private_types_in_public_api
  _TelegramLoginButtonState createState() => _TelegramLoginButtonState();
}

class _TelegramLoginButtonState extends State<TelegramLoginButton> {
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final telegramAuth = TelegramAuth(
        phoneNumber: widget.phoneNumber,
        botId: widget.botId,
        botDomain: widget.botDomain,
        timeout: widget.timeout,
      );

      await telegramAuth.launchTelegram();
      await telegramAuth.initiateLogin();

      final startTime = DateTime.now();
      bool isLoggedIn = false;
      TelegramUser? user;

      while (DateTime.now().difference(startTime) < widget.timeout) {
        isLoggedIn = await telegramAuth.checkLoginStatus();
        if (isLoggedIn) {
          user = await telegramAuth.getUserData();
          break;
        }
        await Future.delayed(const Duration(seconds: 2));
      }

      if (isLoggedIn && user != null) {
        if (widget.onAuthSuccess != null) {
          widget.onAuthSuccess!(user);
        }
      } else {
        throw Exception('Login timeout');
      }
    } catch (e) {
      if (widget.onAuthError != null) {
        widget.onAuthError!(e);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: widget.style ??
          ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
      onPressed: _isLoading ? null : _handleLogin,
      child: _isLoading && widget.showLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : widget.child ??
              const Text(
                'Login with Telegram',
                style: TextStyle(fontSize: 16),
              ),
    );
  }
}
