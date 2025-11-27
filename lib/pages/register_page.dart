import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/firestore_service.dart'; 

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    // Reduz qualidade para caber no banco
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery, maxWidth: 400, imageQuality: 40);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _signUp() async {
    if (_usernameController.text.trim().isEmpty) return;
    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Senhas não conferem')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Cria a conta no Auth
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String? base64Image;

      // Converte imagem
      if (_selectedImage != null) {
        List<int> imageBytes = await _selectedImage!.readAsBytes();
        base64Image = base64Encode(imageBytes);
      }

      // Salva o nome no Auth (A foto vai pro banco)
      await userCredential.user
          ?.updateDisplayName(_usernameController.text.trim());

      // Salva no Firestore
      await FirestoreService().saveUser(
          userCredential.user!.uid,
          _usernameController.text.trim(),
          _emailController.text.trim(),
          base64Image // Aqui não tem limite de tamanho!
          );

      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message ?? 'Erro')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.black)),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text('Criar Conta',
                  style: TextStyle(fontFamily: 'Billabong', fontSize: 48)),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : null,
                  child: _selectedImage == null
                      ? const Icon(Icons.add_a_photo,
                          size: 40, color: Colors.grey)
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Adicionar Foto',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                      hintText: 'Nome de Usuário', filled: true)),
              const SizedBox(height: 12),
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
              const SizedBox(height: 12),
              TextField(
                  controller: _confirmController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      hintText: 'Confirmar Senha', filled: true)),
              const SizedBox(height: 24),
              ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  child: const Text('Cadastrar')),
            ],
          ),
        ),
      ),
    );
  }
}
