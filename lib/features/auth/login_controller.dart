class LoginController {
  final Map<String, String> _users = {
    "admin": "123",
    "chinta": "456",
  };

  int _attempts = 0;

  int get attempts => _attempts;

  bool validateEmpty(String username, String password) {
    return username.isNotEmpty && password.isNotEmpty;
  }

  bool login(String username, String password) {
    if (_users.containsKey(username) &&
        _users[username] == password) {
      _attempts = 0;
      return true;
    } else {
      _attempts++;
      return false;
    }
  }

  void resetAttempts() {
    _attempts = 0;
  }
}
