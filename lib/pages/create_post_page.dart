import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http; // Necessário para a API
import '../services/firestore_service.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _titleController = TextEditingController();
  final _reviewController = TextEditingController();

  File? _selectedImage; // Foto manual
  String? _foundCoverUrl; // Capa da API
  String? _foundAuthor; // Autor da API

  bool _isLoading = false;
  bool _isSearching = false;

  // --- BUSCA NA GOOGLE BOOKS API ---
  Future<void> _searchBook(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _selectedImage = null; // Limpa a imagem manual se for buscar
      _foundCoverUrl = null;
    });

    try {
      final url = Uri.parse(
          'https://www.googleapis.com/books/v1/volumes?q=$query&maxResults=1');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['totalItems'] > 0) {
          final bookInfo = data['items'][0]['volumeInfo'];

          setState(() {
            // Tenta pegar a capa e força HTTPS
            String? thumb = bookInfo['imageLinks']?['thumbnail'];
            if (thumb != null) {
              _foundCoverUrl = thumb.replaceFirst('http:', 'https:');
            }

            // Tenta pegar o autor
            if (bookInfo['authors'] != null) {
              _foundAuthor = bookInfo['authors'][0];
            }

            // Atualiza o título com o nome oficial
            _titleController.text = bookInfo['title'];
          });

          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Livro encontrado!')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Livro não encontrado. Tente outro termo.')));
        }
      }
    } catch (e) {
      print('Erro na API: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Erro ao buscar livro.')));
    } finally {
      setState(() => _isSearching = false);
    }
  }

  // --- SELEÇÃO MANUAL (CÂMERA/GALERIA) ---
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: source, maxWidth: 600, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _foundCoverUrl =
            null; // Limpa a busca da API se o usuário escolher foto manual
      });
    }
  }

  void _showOpcoesFoto(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeria'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                }),
            ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Câmera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.pop(context);
                }),
          ],
        ),
      ),
    );
  }

  // --- ENVIAR POST ---
  void _post() async {
    // Validação: Tem título? Tem imagem (Manual OU API)? Tem resenha?
    if (_titleController.text.isEmpty ||
        (_selectedImage == null && _foundCoverUrl == null) ||
        _reviewController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Preencha título, imagem e resenha")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid ?? 'anonimo';

      // 1. Define a imagem final (Base64 ou URL)
      String finalImageString = '';
      if (_foundCoverUrl != null) {
        finalImageString = _foundCoverUrl!; // Usa a URL da API
      } else {
        List<int> imageBytes = await _selectedImage!.readAsBytes();
        finalImageString = base64Encode(imageBytes); // Usa o Base64 da Câmera
      }

      // 2. Lógica do Nome e Foto de Perfil
      String username = 'Leitor';
      String userProfileImage = '';

      if (user?.email == 'ana@leitora.com') {
        username = 'ana_leitora';
        userProfileImage =
            'https://i.pinimg.com/736x/c0/f0/45/c0f045ba3abb1d2a2ee294bbd3407b59.jpg';
      } else {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        if (userDoc.exists) {
          final data = userDoc.data()!;
          username = data['username'] ?? 'Leitor';
          userProfileImage = data['photoUrl'] ?? '';
        }
      }

      // 3. Salva no Firestore
      await FirestoreService().addPost(
          _titleController.text,
          _reviewController.text,
          finalImageString,
          username,
          userId,
          userProfileImage);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erro: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Novo Post', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: const IconThemeData(color: Colors.black)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- CAMPO TÍTULO + BUSCA ---
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                          hintText: 'Título do Livro', filled: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: _isSearching
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.search),
                    onPressed: () => _searchBook(_titleController.text),
                    tooltip: 'Buscar capa automaticamente',
                    style:
                        IconButton.styleFrom(backgroundColor: Colors.blue[50]),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- ÁREA DA IMAGEM (Preview) ---
              GestureDetector(
                onTap: () => _showOpcoesFoto(context),
                child: Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: _buildImagePreview(),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                  child: Text("Toque na imagem para trocar (Câmera/Galeria)",
                      style: TextStyle(color: Colors.grey, fontSize: 12))),

              const SizedBox(height: 16),

              // --- CAMPO RESENHA ---
              TextField(
                  controller: _reviewController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                      hintText: 'Escreva sua resenha aqui...', filled: true)),

              const SizedBox(height: 24),
              ElevatedButton(
                  onPressed: _isLoading ? null : _post,
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Publicar Resenha')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_foundCoverUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(_foundCoverUrl!, fit: BoxFit.contain),
      );
    } else if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(_selectedImage!, fit: BoxFit.cover),
      );
    } else {
      return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
            SizedBox(height: 8),
            Text("Nenhuma capa selecionada",
                style: TextStyle(color: Colors.grey))
          ]);
    }
  }
}
