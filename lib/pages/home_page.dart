import 'package:flutter/material.dart';

// Modelo de Dados (para simular os dados de um post)
class BookPost {
  final String username;
  final String profileImageUrl;
  final String bookCoverUrl;
  final String bookTitle;
  final String review;
  final int likeCount;
  final int commentCount;
  final String timeAgo;

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
}

// 2. Dados Fictícios (Mock Data) para preencher nosso feed
final List<BookPost> posts = [
  const BookPost(
    username: 'ana_leitora',
    profileImageUrl:
        'https://i.pinimg.com/736x/c0/f0/45/c0f045ba3abb1d2a2ee294bbd3407b59.jpg',
    bookCoverUrl:
        'https://m.media-amazon.com/images/I/81XpG2iKTlL.jpg', // Dom Casmurro
    bookTitle: 'Dom Casmurro',
    review:
        'Terminei de reler essa obra-prima! A dúvida sobre a traição de Capitu continua me assombrando. O que vocês acham?',
    likeCount: 182,
    commentCount: 47,
    timeAgo: 'HÁ 2 HORAS',
  ),
  const BookPost(
    username: 'V.E Schwab',
    profileImageUrl:
        'https://cdn.record.com.br/wp-content/uploads/2019/06/25200749/v-e-schwab.jpg',
    bookCoverUrl:
        'https://m.media-amazon.com/images/I/81zW6OSYdHL._SL1500_.jpg', // Dom Casmurro
    bookTitle: 'Enterre nossos ossos à meia noite',
    review:
        'Meu novo livro já está disponível! Uma história sombria e envolvente sobre segredos e redenção. Espero que gostem!',
    likeCount: 18000,
    commentCount: 5900,
    timeAgo: 'HÁ 1 HORAS',
  ),
  const BookPost(
    username: 'carlos_santos',
    profileImageUrl:
        'https://marketplace.canva.com/ultEA/MAEzUIultEA/1/tl/canva-headshot-profile-picture-young-businessman-sit-in-kitchen-webcam-view-MAEzUIultEA.jpg',
    bookCoverUrl:
        'https://m.media-amazon.com/images/I/91g5gcjTxsL._UF1000,1000_QL80_.jpg', // 1984
    bookTitle: '1984',
    review:
        'Um livro que continua mais atual do que nunca. A vigilância constante e a manipulação da verdade são temas que dão o que pensar.',
    likeCount: 320,
    commentCount: 98,
    timeAgo: 'HÁ 5 HORAS',
  ),
];

// Tela Principal do Feed (HomePage)
class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
            fontFamily: 'Billabong', // Mesma fonte do logo anterior
            fontSize: 32.0,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: Colors.black),
            onPressed: () {
              /* Navegar para a tela de criar post */
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {
              /* Ver notificações */
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return BookPostCard(post: post);
        },
      ),
    );
  }
}

// 4. Widget Reutilizável para o Card de Postagem
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
                  backgroundImage: NetworkImage(post.profileImageUrl),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
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
            post.bookCoverUrl,
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
                  '${post.likeCount} curtidas',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4.0),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                    children: [
                      TextSpan(
                        text: post.username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(text: post.review),
                    ],
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Ver todos os ${post.commentCount} comentários',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 4.0),
                Text(
                  post.timeAgo,
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
