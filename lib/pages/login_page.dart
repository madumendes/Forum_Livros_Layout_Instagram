import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // O AuthGate no main.dart vai nos levar para a Home automaticamente
    } on FirebaseAuthException catch (e) {
      if (mounted) _showErrorDialog(e.message ?? 'Erro desconhecido');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erro no Login'),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Fórum de Livros',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Billabong', fontSize: 64)),
              const SizedBox(height: 48),
              TextField(
                  controller: _emailController,
                  decoration:
                      const InputDecoration(hintText: 'Email', filled: true)),
              const SizedBox(height: 12),
              TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration:
                      const InputDecoration(hintText: 'Senha', filled: true)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _signIn,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Entrar'),
              ),
              TextButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const RegisterPage())),
                child: const Text('Criar conta'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
