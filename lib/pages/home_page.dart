import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart'; // 1. Importe o serviço

// --- SEU MODELO BOOKPOST ---
// (A lista de dados fictícios foi removida)
class BookPost {
  final String username;
  final String profileImageUrl;
  final String bookCoverUrl;
  final String bookTitle;
  final String review;
  final int likeCount;
  final int commentCount;
  final String timeAgo;
  // (Opcional) Você pode querer adicionar um ID
  // final String id;

  const BookPost({
    required this.username,
    required this.profileImageUrl,
    required this.bookCoverUrl,
    required this.bookTitle,
    required this.review,
    required this.likeCount,
    required this.commentCount,
    required this.timeAgo,
  });

  // Construtor para converter um Documento do Firestore em um objeto BookPost
  factory BookPost.fromFirestore(DocumentSnapshot doc) {
    // Pega os dados do documento como um Mapa
    Map data = doc.data() as Map<String, dynamic>;

    // Retorna um objeto BookPost, usando valores padrão caso um campo não exista
    return BookPost(
      username: data['username'] ?? 'Usuário Anônimo',
      profileImageUrl: data['profileImageUrl'] ?? '', // URL de imagem padrão?
      bookCoverUrl: data['bookCoverUrl'] ?? '', // URL de imagem padrão?
      bookTitle: data['bookTitle'] ?? 'Livro Desconhecido',
      review: data['review'] ?? 'Sem resenha.',
      likeCount: data['likeCount'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
      timeAgo: data['timeAgo'] ?? 'agora', // Você pode querer calcular isso
    );
  }
}

// --- TELA PRINCIPAL DO FEED ---
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 2. Crie uma instância do serviço
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: const Text(
          'Feed',
          style: TextStyle(
            fontFamily: 'Billabong',
            fontSize: 32.0,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: Colors.black),
            onPressed: () {
              // TODO: Navegar para a tela de criar post
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {/* Ver notificações */},
          ),
        ],
      ),
      // 3. Substitua o ListView.builder por um StreamBuilder
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getPostsStream(), // "Ouve" o stream de posts
        builder: (context, snapshot) {
          // Se estiver carregando dados
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Se ocorrer um erro
          if (snapshot.hasError) {
            return Center(
                child: Text('Erro ao carregar posts: ${snapshot.error}'));
          }

          // Se a coleção estiver vazia (sem dados)
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma resenha ainda.\nSeja o primeiro a postar!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // Se tiver dados, construa a lista
          return ListView.builder(
            itemCount: snapshot.data!.docs.length, // O número de posts
            itemBuilder: (context, index) {
              // Pega o documento individual
              DocumentSnapshot doc = snapshot.data!.docs[index];

              // Converte o documento (dados do Firestore) para um objeto BookPost
              final post = BookPost.fromFirestore(doc);

              // Retorna o widget do card com os dados do post
              return BookPostCard(post: post);
            },
          );
        },
      ),
    );
  }
}

// --- WIDGET REUTILIZÁVEL PARA O CARD DE POSTAGEM ---
// (Nenhuma mudança foi necessária neste widget)
class BookPostCard extends StatelessWidget {
  final BookPost post;

  const BookPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -- Cabeçalho do Post --
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  // Usa a imagem de perfil do post
                  backgroundImage: NetworkImage(post.profileImageUrl),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    // Usa o nome de usuário do post
                    post.username,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // -- Imagem da Capa do Livro --
          Image.network(
            post.bookCoverUrl, // Usa a capa do livro do post
            fit: BoxFit.cover,
            height: 400,
            width: double.infinity,
          ),

          // -- Barra de Ações (Like, Comment, Share) --
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.send_outlined),
                  onPressed: () {},
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // -- Seção de Curtidas, Legenda e Comentários --
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${post.likeCount} curtidas', // Usa as curtidas do post
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4.0),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                    children: [
                      TextSpan(
                        text: post.username, // Usa o usuário do post
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(text: post.review), // Usa a resenha do post
                    ],
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Ver todos os ${post.commentCount} comentários', // Usa os comentários do post
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 4.0),
                Text(
                  post.timeAgo, // Usa o tempo do post
                  style: TextStyle(color: Colors.grey[600], fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12.0),
        ],
      ),
    );
  }
}
