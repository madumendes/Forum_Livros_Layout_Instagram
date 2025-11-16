import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback onLoginTap;
  const RegisterPage({super.key, required this.onLoginTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE CADASTRO ---
  Future<void> _signUp() async {
    // 1. Verifica se as senhas são iguais
    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      _showErrorDialog('As senhas não conferem.');
      return;
    }

    // 2. Mostra um círculo de carregamento
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
      barrierDismissible: false, // Impede o usuário de fechar
    );

    try {
      // 3. Tenta criar o usuário no Firebase Auth
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 4. Fecha o círculo de carregamento
      if (mounted) Navigator.pop(context);

      // Se o cadastro deu certo, o AuthGate (no main.dart)
      // vai automaticamente navegar para a MainPage.
    } on FirebaseAuthException catch (e) {
      // 5. Se der erro (ex: email já existe, senha fraca)
      if (mounted) Navigator.pop(context); // Fecha o carregamento
      _showErrorDialog(e.message ?? 'Erro desconhecido'); // Mostra o erro
    }
  }

  // Helper para mostrar um pop-up de erro
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erro no Cadastro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Criar Conta',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Billabong',
                    fontSize: 64.0,
                  ),
                ),
                const SizedBox(height: 48.0),

                // Campo de E-mail
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _buildInputDecoration('Email'),
                ),
                const SizedBox(height: 12.0),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _buildInputDecoration('Senha'),
                ),
                const SizedBox(height: 12.0),

                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: _buildInputDecoration('Confirmar Senha'),
                ),
                const SizedBox(height: 24.0),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: _signUp,
                  child: const Text(
                    'Cadastrar',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 12.0),

                TextButton(
                  onPressed: widget.onLoginTap,
                  child: const Text(
                    'Já tem uma conta? Entrar',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 12.0,
      ),
    );
  }
}
