import 'package:flutter/material.dart';
import 'package:telegram_login_flutter/telegram_login_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Telegram Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  String _countryCode = '+1';
  bool _isLoading = false;
  TelegramUser? _user;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Telegram Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefix: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: DropdownButton<String>(
                    value: _countryCode,
                    items: const [
                      DropdownMenuItem(value: '+1', child: Text('+1 (US)')),
                      DropdownMenuItem(value: '+91', child: Text('+91 (IN)')),
                      DropdownMenuItem(value: '+44', child: Text('+44 (UK)')),
                      DropdownMenuItem(value: '+251', child: Text('+251 (ET)')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _countryCode = value!;
                      });
                    },
                    underline: const SizedBox(),
                  ),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0088CC),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Login with Telegram'),
            ),
            const SizedBox(height: 20),
            if (_user != null) _buildUserInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
  
    String? photoUrl = _user!.photoUrl.isNotEmpty 
        ? _user!.photoUrl.replaceAll(RegExp(r'(?<!:)/+'), '/')
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('User Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            if (photoUrl != null)
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(photoUrl),
                  onBackgroundImageError: (e, stack) {
                    // Fallback if image fails to load
                    return;
                  },
                ),
              ),
            const SizedBox(height: 16),
            _buildInfoRow('First Name', _user!.firstName),
            if (_user!.lastName.isNotEmpty) _buildInfoRow('Last Name', _user!.lastName),
            _buildInfoRow('Username', _user!.username.isNotEmpty ? '@${_user!.username}' : 'Not provided'),
            _buildInfoRow('User ID', _user!.id),
            _buildInfoRow('Auth Date', DateTime.fromMillisecondsSinceEpoch(int.parse(_user!.authDate)).toString()),
            _buildInfoRow('Hash', _user!.hash.substring(0, 12) + '...'), // Show partial hash
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _user = null;
    });

    try {
      final telegramAuth = TelegramAuth(
        botId: 'YOUR_BOT_ID',
        botDomain: 'yourdomain.com',
        phoneNumber: '$_countryCode${_phoneController.text.trim()}',
      );

      // Step 1: Initiate login
      final initiated = await telegramAuth.initiateLogin();
      if (!initiated) throw Exception('Failed to initiate login');

      bool isLoggedIn = false;
      final timeout = DateTime.now().add(const Duration(seconds: 60));

      while (!isLoggedIn && DateTime.now().isBefore(timeout)) {
        await Future.delayed(const Duration(seconds: 2));
        isLoggedIn = await telegramAuth.checkLoginStatus();
        if (isLoggedIn) {
          final user = await telegramAuth.getUserData();
          setState(() => _user = user);
        }
      }

      if (!isLoggedIn) {
        throw Exception('Login timeout - please try again');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}