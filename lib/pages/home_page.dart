import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'create_post_page.dart';
import '../widgets/universal_image.dart';
import 'comments_page.dart'; // <--- IMPORTANTE: Importe a página de comentários

// --- MODELO ATUALIZADO ---
class BookPost {
  final String id;
  final String username;
  final String profileImageUrl;
  final String bookCoverUrl;
  final String bookTitle;
  final String review;
  final String timeAgo;
  final int likeCount;
  final int commentCount; // Adicionado contador de comentários
  final List<dynamic> likedBy;

  BookPost.fromDoc(DocumentSnapshot doc)
      : id = doc.id,
        username = doc['username'] ?? 'Anônimo',
        profileImageUrl = doc['profileImageUrl'] ?? '',
        bookCoverUrl = doc['bookCoverUrl'] ?? '',
        bookTitle = doc['bookTitle'] ?? '',
        review = doc['review'] ?? '',
        timeAgo = 'HÁ 1 HORA',
        likeCount = doc['likeCount'] ?? 0,
        commentCount = doc['commentCount'] ?? 0, // Lê do banco
        likedBy = doc['likedBy'] ?? [];
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('Feed',
            style: TextStyle(
                fontFamily: 'Billabong', fontSize: 32, color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: Colors.black),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CreatePostPage())),
          ),
          IconButton(
              icon: const Icon(Icons.favorite_border, color: Colors.black),
              onPressed: () {}),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getPostsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('O feed está vazio.',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final post = BookPost.fromDoc(docs[index]);
              return BookPostCard(post: post);
            },
          );
        },
      ),
    );
  }
}

// --- CARD DE POSTAGEM ---
class BookPostCard extends StatelessWidget {
  final BookPost post;

  const BookPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isLiked = post.likedBy.contains(currentUser?.uid);

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            leading: ClipOval(
              child: UniversalImage(
                  imageUrl: post.profileImageUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover),
            ),
            title: Text(post.username,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            trailing: PopupMenuButton(
              icon: const Icon(Icons.more_horiz),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Editar')),
                const PopupMenuItem(
                    value: 'delete',
                    child:
                        Text('Excluir', style: TextStyle(color: Colors.red))),
              ],
              onSelected: (value) {
                if (value == 'delete') {
                  FirestoreService().deletePost(post.id);
                } else if (value == 'edit') {
                  _showEditDialog(context);
                }
              },
            ),
          ),

          // Imagem
          UniversalImage(
              imageUrl: post.bookCoverUrl,
              height: 400,
              width: double.infinity,
              fit: BoxFit.cover),

          // AÇÕES (LIKE, COMMENT, SAVE)
          Row(
            children: [
              // Botão Like
              IconButton(
                icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.black),
                onPressed: () {
                  if (currentUser != null) {
                    FirestoreService().toggleLike(post.id, currentUser.uid);
                  }
                },
              ),
              // Botão Comentário (CONECTADO!)
              IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: () {
                    // Navega para a tela de comentários passando o ID do post
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommentsPage(postId: post.id),
                      ),
                    );
                  }),
              IconButton(
                  icon: const Icon(Icons.send_outlined), onPressed: () {}),
              const Spacer(),
              // Botão Save
              IconButton(
                icon: const Icon(Icons.bookmark_border),
                onPressed: () {
                  if (currentUser != null) {
                    FirestoreService().toggleSave(post.id, currentUser.uid);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Salvo/Removido!'),
                        duration: Duration(milliseconds: 500)));
                  }
                },
              ),
            ],
          ),

          // Legenda e Comentários
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.likeCount > 0)
                  Text('${post.likeCount} curtidas',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                RichText(
                    text: TextSpan(
                        style: const TextStyle(color: Colors.black),
                        children: [
                      TextSpan(
                          text: post.username,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: ' '),
                      TextSpan(text: post.review),
                    ])),
                // Link para ver comentários
                if (post.commentCount > 0)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CommentsPage(postId: post.id),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        'Ver todos os ${post.commentCount} comentários',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                Text(post.timeAgo,
                    style: const TextStyle(color: Colors.grey, fontSize: 10)),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: post.review);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Resenha'),
        content: TextField(controller: controller, maxLines: 3),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              FirestoreService().updatePost(post.id, controller.text);
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
