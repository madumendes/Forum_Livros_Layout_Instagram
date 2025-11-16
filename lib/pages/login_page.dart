import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'register_page.dart'; // Cadastro do usuário firebase

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _showLoginPage = true;

  // Função para alternar entre Login e Cadastro
  void _togglePages() {
    setState(() {
      _showLoginPage = !_showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showLoginPage) {
      // Se true, mostra o Login e passa a função de alternar
      return LoginWidget(onRegisterTap: _togglePages);
    } else {
      // Se false, mostra o Cadastro e passa a função de alternar
      return RegisterPage(onLoginTap: _togglePages);
    }
  }
}

class LoginWidget extends StatefulWidget {
  final VoidCallback onRegisterTap; // Função para ir ao Cadastro
  const LoginWidget({super.key, required this.onRegisterTap});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    // Mostra um círculo de carregamento
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      // Tenta fazer o login com o Firebase Auth
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) Navigator.pop(context);

      // O AuthGate muda navegação para a MainPage.
    } on FirebaseAuthException catch (e) {
      // Se der erro (ex: usuário não encontrado, senha errada)
      if (mounted) Navigator.pop(context); // Fecha o carregamento
      _showErrorDialog(e.message ?? 'Erro desconhecido'); // Mostra o erro
    }
  }

  // Helper para mostrar um pop-up de erro
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erro no Login'),
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
                  'Fórum de Livros',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Billabong', fontSize: 64.0),
                ),
                const SizedBox(height: 48.0),

                // Campo de E-mail
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _buildInputDecoration('Email'),
                ),
                const SizedBox(height: 12.0),

                // Campo de Senha
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _buildInputDecoration('Senha'),
                ),
                const SizedBox(height: 24.0),

                // Botão de Entrar
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: _signIn, // Chama ologin
                  child: const Text(
                    'Entrar',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 12.0),

                TextButton(
                  onPressed: () {/* Para resetar senha, não implementado */},
                  child: const Text(
                    'Esqueceu a senha?',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),

                //Link para "Criar conta"
                TextButton(
                  onPressed: widget.onRegisterTap, // Chama a função para trocar
                  child: const Text(
                    'Não tem uma conta? Cadastre-se',
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
