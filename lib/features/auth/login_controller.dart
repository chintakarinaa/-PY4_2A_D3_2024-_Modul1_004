class LoginController {
  final Map<String, Map<String, String>> _users = {
    "admin": {
      "password": "123",
      "role": "Ketua",
      "teamId": "MEKTRA_KLP_01",
    },
    "yuyo": {
      "password": "456",
      "role": "Anggota",
      "teamId": "MEKTRA_KLP_01",
    },
    "chinta": {
      "password": "456",
      "role": "Anggota",
      "teamId": "MEKTRA_KLP_01",
    },
    "sadewa": {
      "password": "123",
      "role": "Ketua",
      "teamId": "MEKTRA_KLP_02",
    },
    "nakula": {
      "password": "456",
      "role": "Asisten",
      "teamId": "MEKTRA_KLP_02",
    },
    "arjuna": {
      "password": "456",
      "role": "Anggota",
      "teamId": "MEKTRA_KLP_02",
    },
  };

  int _attempts = 0;

  int get attempts => _attempts;

  bool validateEmpty(String username, String password) {
    return username.isNotEmpty && password.isNotEmpty;
  }

  Map<String, dynamic>? login(String username, String password) {
    if (_users.containsKey(username) &&
        _users[username]!["password"] == password) {
      _attempts = 0;

      return {
        "uid": username,
        "username": username,
        "role": _users[username]!["role"],
        "teamId": _users[username]!["teamId"],
      };
    } else {
      _attempts++;
      return null;
    }
  }

  void resetAttempts() {
    _attempts = 0;
  }
}