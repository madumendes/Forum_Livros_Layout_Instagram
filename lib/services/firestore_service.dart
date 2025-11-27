import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference posts =
      FirebaseFirestore.instance.collection('posts');
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference groups =
      FirebaseFirestore.instance.collection('groups');

  // posts

  Future<void> addPost(String title, String review, String coverBase64,
      String author, String userId, String profileImage) {
    return posts.add({
      'bookTitle': title,
      'bookCoverUrl': coverBase64,
      'username': author,
      'userId': userId,
      'profileImageUrl': profileImage,
      'review': review, // <--- Agora salva o texto real!
      'likeCount': 0,
      'likedBy': [],
      'commentCount': 0,
      'timeAgo': 'agora',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getPostsStream() {
    return posts.orderBy('timestamp', descending: true).snapshots();
  }

  Stream<QuerySnapshot> getUserPostsStream(String userId) {
    return posts.where('userId', isEqualTo: userId).snapshots();
  }

  Future<void> deletePost(String docId) {
    return posts.doc(docId).delete();
  }

  Future<void> updatePost(String docId, String newReview) {
    return posts.doc(docId).update({'review': newReview});
  }

  // interações
  Future<void> toggleLike(String postId, String userId) async {
    final docRef = posts.doc(postId);
    final doc = await docRef.get();
    if (doc.exists) {
      final List likedBy = (doc.data() as Map)['likedBy'] ?? [];
      if (likedBy.contains(userId)) {
        await docRef.update({
          'likedBy': FieldValue.arrayRemove([userId]),
          'likeCount': FieldValue.increment(-1)
        });
      } else {
        await docRef.update({
          'likedBy': FieldValue.arrayUnion([userId]),
          'likeCount': FieldValue.increment(1)
        });
      }
    }
  }

  Future<void> toggleSave(String postId, String userId) async {
    final userRef = users.doc(userId);
    final doc = await userRef.get();
    if (doc.exists) {
      final List saved = (doc.data() as Map)['savedPosts'] ?? [];
      if (saved.contains(postId)) {
        await userRef.update({
          'savedPosts': FieldValue.arrayRemove([postId])
        });
      } else {
        await userRef.update({
          'savedPosts': FieldValue.arrayUnion([postId])
        });
      }
    }
  }

  // comments
  Future<void> addComment(String postId, String text, String uid,
      String username, String photoUrl) {
    return posts.doc(postId).collection('comments').add({
      'text': text,
      'userId': uid,
      'username': username,
      'userImage': photoUrl,
      'timestamp': FieldValue.serverTimestamp(),
    }).then((_) {
      posts.doc(postId).update({'commentCount': FieldValue.increment(1)});
    });
  }

  Stream<QuerySnapshot> getCommentsStream(String postId) {
    return posts
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // usuários
  Future<void> saveUser(
      String uid, String username, String email, String? photoBase64) {
    return users.doc(uid).set({
      'username': username,
      'email': email,
      'photoUrl': photoBase64 ?? '',
      'savedPosts': [],
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot> getUserStream(String uid) {
    return users.doc(uid).snapshots();
  }

  // grupos
  Future<void> createGroup(String name, String description, String ownerId) {
    return groups.add({
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'imageUrl': 'https://cdn-icons-png.flaticon.com/512/33/33308.png',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getGroupsStream() {
    return groups.orderBy('timestamp', descending: true).snapshots();
  }

  Future<void> updateGroup(String docId, String newName, String newDesc) {
    return groups.doc(docId).update({'name': newName, 'description': newDesc});
  }

  Future<void> deleteGroup(String docId) {
    return groups.doc(docId).delete();
  }
}
