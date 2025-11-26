import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../widgets/universal_image.dart';

class CommentsPage extends StatefulWidget {
  final String postId; // Precisamos saber qual post estamos comentando

  const CommentsPage({super.key, required this.postId});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final _commentController = TextEditingController();
  final FirestoreService _service = FirestoreService();

  void _sendComment() {
    if (_commentController.text.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    // Se for a Ana, usa dados fixos, senão pega do Auth
    final isAna = user?.email == 'ana@leitora.com';

    final username = isAna ? 'ana_leitora' : (user?.displayName ?? 'Usuário');
    final photoUrl = isAna
        ? 'https://i.pinimg.com/736x/c0/f0/45/c0f045ba3abb1d2a2ee294bbd3407b59.jpg'
        : (user?.photoURL ?? '');

    _service.addComment(widget.postId, _commentController.text.trim(),
        user!.uid, username, photoUrl);

    _commentController.clear(); // Limpa o campo
    FocusScope.of(context).unfocus(); // Fecha o teclado
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comentários', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // LISTA DE COMENTÁRIOS
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _service.getCommentsStream(widget.postId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(
                      child: Text('Seja o primeiro a comentar!',
                          style: TextStyle(color: Colors.grey)));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: ClipOval(
                        child: UniversalImage(
                          imageUrl: data['userImage'],
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              color: Colors.black, fontSize: 14),
                          children: [
                            TextSpan(
                                text: "${data['username']} ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            TextSpan(text: data['text']),
                          ],
                        ),
                      ),
                      // subtitle: Text(formatTimestamp(data['timestamp'])), // Opcional: formatar data
                    );
                  },
                );
              },
            ),
          ),

          // CAMPO DE TEXTO (RODAPÉ)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Adicione um comentário...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
