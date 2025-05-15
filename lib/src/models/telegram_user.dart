class TelegramUser {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String photoUrl;
  final String authDate;
  final String hash;
  final String rawJson;

  TelegramUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.photoUrl,
    required this.authDate,
    required this.hash,
    required this.rawJson,
  });

  factory TelegramUser.fromJson(Map<String, dynamic> json) {
    return TelegramUser(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      photoUrl: json['photo_url']?.toString() ?? '',
      authDate: json['auth_date']?.toString() ?? '',
      hash: json['hash']?.toString() ?? '',
      rawJson: json['raw_json']?.toString() ?? json.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'photo_url': photoUrl,
      'auth_date': authDate,
      'hash': hash,
      'raw_json': rawJson,
    };
  }
}
