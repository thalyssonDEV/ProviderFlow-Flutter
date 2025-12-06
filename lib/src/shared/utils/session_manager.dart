class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  
  factory SessionManager() {
    return _instance;
  }

  SessionManager._internal();

  int? loggedProviderId;
  String? loggedProviderName;

  void login(int id, String name) {
    loggedProviderId = id;
    loggedProviderName = name;
  }

  void logout() {
    loggedProviderId = null;
    loggedProviderName = null;
  }
}