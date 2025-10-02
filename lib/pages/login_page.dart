import 'package:flutter/material.dart';
import '../../main.dart'; 
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controladores para obter o texto dos campos de email e senha
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    // Limpa os controladores quando o widget é removido da árvore de widgets
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                // Logo "Instagram"
                const Text(
                  'Fórum de Livros',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily:
                        'Billabong', // Uma fonte comum para o logo do Instagram
                    fontSize: 64.0,
                  ),
                ),
                const SizedBox(height: 48.0),

                // Campo de texto para email/usuário
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Nome de usuário, email ou número',
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
                  ),
                ),
                const SizedBox(height: 12.0),

                // Campo de texto para senha
                TextField(
                  controller: _passwordController,
                  obscureText: true, // Esconde o texto da senha
                  decoration: InputDecoration(
                    hintText: 'Senha',
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
                  ),
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
                  onPressed: () {
                    // Aqui você pode adicionar a lógica de login
                    // Por enquanto, ele apenas navega para a página principal
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MainPage()),
                    );
                  },
                  child: const Text(
                    'Entrar',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 12.0),

                // Link "Esqueceu a senha?"
                TextButton(
                  onPressed: () {
                    // Lógica para recuperação de senha
                  },
                  child: const Text(
                    'Esqueceu a senha?',
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
}
