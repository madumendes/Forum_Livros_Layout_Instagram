import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  User? _user;

  // Getter para acessar o usuário
  User? get user => _user;

  // Setter para definir o usuário após o login
  void setUser(User user) {
    _user = user;
    notifyListeners(); // Avisa as telas que o usuário mudou
  }

  // Função de Logout
  void logout() {
    _user = null;
    notifyListeners();
  }
}
