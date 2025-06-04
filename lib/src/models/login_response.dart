class LoginResponse {
  final LoginStatus result;
  final String? error;

  LoginResponse({
    required this.result,
    this.error
  });

  factory LoginResponse.success() {
    return LoginResponse(
      result: LoginStatus.success
    );
  }

  factory LoginResponse.failure(String error) {
    return LoginResponse(
      result: LoginStatus.failure,
      error: error
    );
  }

  factory LoginResponse.loading() {
    return LoginResponse(
      result: LoginStatus.loading
    );
  }
}

enum LoginStatus {
  success,
  failure,
  loading,
}