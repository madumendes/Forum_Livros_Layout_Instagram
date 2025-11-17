import 'package:cloud_firestore/cloud_firestore.dart';
import '../pages/home_page.dart'; // Importe seu modelo BookPost

class FirestoreService {
  // 1. Obter a coleção de 'posts'
  final CollectionReference postsCollection =
      FirebaseFirestore.instance.collection('posts');

  // 2. READ: Obter o stream de posts
  // Usamos um Stream para que o feed se atualize em tempo real
  Stream<QuerySnapshot> getPostsStream() {
    // Ordena os posts pelo mais recente
    return postsCollection.orderBy('timestamp', descending: true).snapshots();
  }

  // 3. CREATE: Adicionar um novo post (Vamos usar isso no próximo passo)
  Future<void> addPost(BookPost post) {
    // Converte o objeto BookPost para um JSON para salvar no Firestore
    return postsCollection.add({
      'username': post.username,
      'profileImageUrl': post.profileImageUrl,
      'bookCoverUrl': post.bookCoverUrl,
      'bookTitle': post.bookTitle,
      'review': post.review,
      'likeCount': post.likeCount,
      'commentCount': post.commentCount,
      'timeAgo': post.timeAgo, // Considere usar um 'timestamp' real
      'timestamp': FieldValue.serverTimestamp(), // Para ordenação
    });
  }

  // TODO: Adicionar métodos de Update e Delete
}
