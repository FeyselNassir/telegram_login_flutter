# Telegram Login Flutter

[![Pub Version](https://img.shields.io/pub/v/telegram_login_flutter)](https://pub.dev/packages/telegram_login_flutter)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?logo=Flutter&logoColor=white)](https://flutter.dev)

A Flutter package for seamless Telegram login integration using Telegram OAuth. This package provides both a ready-to-use button widget and core authentication functionality for custom implementations.

![Telegram Login Demo]() 

## Features

- ✅ Pre-built login button widget with customizable UI
- ✅ Core authentication service for custom implementations
- ✅ Supports web and mobile platforms
- ✅ Proper error handling and validation
- ✅ Maintains session state during authentication flow
- ✅ Returns complete Telegram user profile data

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  telegram_login_flutter: ^1.0.0

```
  

### Usage Example
   ### 1. Basic Implementation

 ```dart

import 'package:telegram_login_flutter/telegram_login_flutter.dart';

TelegramLoginButton(
  botId: 'YOUR_BOT_ID', // Get this from @BotFather
  botDomain: 'YOUR_DOMAIN.com', // Must match Telegram widget domain
  phoneNumber: '+1234567890', // User's phone number
  onAuthSuccess: (user) {
    // Handle successful login
    print('User logged in: ${user.username}');
    print('Full user data: ${user.toJson()}');
  },
  onAuthError: (error) {
    // Handle errors
    print('Login error: $error');
  },
)
```
### 2. With Phone Input Field

 
 ```dart

 import 'package:country_code_picker/country_code_picker.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  String _countryDialCode = '+1';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            prefix: CountryCodePicker(
              onChanged: (code) => setState(() => _countryDialCode = code.dialCode!),
              initialSelection: _countryDialCode,
            ),
          ),
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: 20),
        TelegramLoginButton(
          botId: 'YOUR_BOT_ID',
          botDomain: 'YOUR_DOMAIN.com',
          phoneNumber: '$_countryDialCode${_phoneController.text}',
          onAuthSuccess: (user) {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => WelcomePage(user: user)
            ));
          },
        ),
      ],
    );
  }
}
```
### 3. Manual Authentication Flow

```dart
final telegramAuth = TelegramAuth(
  phoneNumber: '+1234567890',
  botId: 'YOUR_BOT_ID',
  botDomain: 'YOUR_DOMAIN.com',
);

// Step 1: Launch Telegram
await telegramAuth.launchTelegram();

// Step 2: Initiate login
final initiated = await telegramAuth.initiateLogin();
if (!initiated) throw Exception('Failed to initiate login');

// Step 3: Check status periodically
bool isLoggedIn = false;
TelegramUser? user;

while (!isLoggedIn) {
  await Future.delayed(Duration(seconds: 2));
  isLoggedIn = await telegramAuth.checkLoginStatus();
  if (isLoggedIn) {
    user = await telegramAuth.getUserData();
  }
}

// Use the user data
print(user?.toJson());

```

### Configuration

     + Telegram Bot Setup

 - Create a bot with @BotFather

 - Enable "Telegram Login" in bot settings

 - Add your domain to authorized domains

     + Required Parameters

Parameter	        Description
botId	            Your Telegram bot ID (from @BotFather)
botDomain	        Domain where your app is hosted (must match Telegram widget domain)
phoneNumber     	User's phone number in international format (e.g., +1234567890)

### Advanced Customization
### Custom Button Styling

```dart
TelegramLoginButton(
  // ... required parameters
  style: ElevatedButton.styleFrom(
    primary: Colors.blue,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.telegram),
      SizedBox(width: 8),
      Text('Sign in with Telegram'),
    ],
  ),
)

```
### Handling Different States

```dart 
TelegramLoginButton(
  // ... required parameters
  showLoading: false, // Hide default loading indicator
  builder: (context, onPressed, isLoading) {
    return isLoading 
      ? CircularProgressIndicator()
      : OutlinedButton(
          onPressed: onPressed,
          child: Text('Custom Login Button'),
        );
  },
)
```

### FAQ
Q: How do I get my bot ID?
A: Create a bot with @BotFather and send /mybots to see your bot's details.

Q: What domains are allowed?
A: You must use HTTPS and the domain must match exactly what you set in BotFather.

Q: Can I use this with Firebase Auth?
A: Yes! You can use the returned user data to create a custom token for Firebase.

### Troubleshooting
Error: "Bot domain not authorized"

Verify your domain in BotFather settings

Ensure you're using HTTPS

Error: "Phone number invalid"

Format must be +[country code][number] with no spaces

Example: +1234567890



### License
MIT © Feysel Nassir (SonexTech)