import 'package:flutter/material.dart';
import '../../../shared/database/database_helper.dart';
import '../../../shared/utils/session_manager.dart';

class AuthController extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  Future<bool> login(String username, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final providerData = await DatabaseHelper.instance.getProvider(username, password);
      if (providerData != null) {
        SessionManager().login(
          providerData['id'] as int,
          providerData['username'] as String,
        );
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        errorMessage = 'Credenciais inválidas.';
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = 'Erro ao fazer login: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String username, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      int result = await DatabaseHelper.instance.createProvider(username, password);
      isLoading = false;
      if (result != -1) {
        notifyListeners();
        return true;
      } else {
        errorMessage = 'Este usuário já existe.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = 'Erro ao registrar: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
