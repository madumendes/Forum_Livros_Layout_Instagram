import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../widgets/universal_image.dart';
import 'create_post_page.dart';
import 'login_page.dart'; 

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirestoreService _service = FirestoreService();
  final String _anaPhoto =
      'https://i.pinimg.com/736x/c0/f0/45/c0f045ba3abb1d2a2ee294bbd3407b59.jpg';

  @override
  void initState() {
    super.initState();
    _checkAndGenerateAnaPosts();
  }

  // verificação - se for o usuário da Ana (demo) gera posts automaticamente
  Future<void> _checkAndGenerateAnaPosts() async {
    final user = FirebaseAuth.instance.currentUser;
    // Verifica email ignorando maiúsculas/minúsculas
    if (user?.email?.toLowerCase().trim() != 'ana@leitora.com') return;

    // Verifica se a Ana já tem posts
    final snapshot = await _service.getUserPostsStream(user!.uid).first;

    if (snapshot.docs.isEmpty) {
      final posts = [
        {
          't': 'Dom Casmurro',
          'c': 'https://m.media-amazon.com/images/I/81XpG2iKTlL.jpg',
          'r': 'Traiu ou não traiu? Eis a questão.'
        },
        {
          't': '1984',
          'c':
              'https://m.media-amazon.com/images/I/91g5gcjTxsL._UF1000,1000_QL80_.jpg',
          'r': 'Uma distopia assustadoramente real.'
        },
        {
          't': 'O Hobbit',
          'c': 'https://m.media-amazon.com/images/I/91b0C2YNSrL.jpg',
          'r': 'Uma aventura inesquecível pela Terra Média.'
        },
        {
          't': 'Duna',
          'c': 'https://m.media-amazon.com/images/I/81ym3QUd3KL.jpg',
          'r': 'O tempero deve fluir!'
        },
      ];

      for (var p in posts) {
        await _service.addPost(
          p['t']!, // Título
          p['r']!, // Resenha (Correção: adicionei o texto da resenha)
          p['c']!, // Capa
          'ana_leitora', // Nome
          user.uid, // ID
          _anaPhoto, // FOTO DA ANA
        );
        await Future.delayed(const Duration(milliseconds: 100));
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Perfil da Ana configurado com sucesso!')));
      }
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    // Redireciona para login se necessário, mas o AuthGate já cuida disso
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isAnaLeitora = user?.email?.toLowerCase().trim() == 'ana@leitora.com';

    final displayName = isAnaLeitora
        ? 'ana_leitora'
        : (user?.displayName ?? user?.email?.split('@')[0] ?? 'Usuário');

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(displayName,
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_box_outlined, color: Colors.black),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CreatePostPage())),
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.black),
              onPressed: _signOut,
            ),
          ],
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: StreamBuilder<DocumentSnapshot>(
                stream: isAnaLeitora
                    ? const Stream.empty()
                    : _service.getUserStream(user!.uid),
                builder: (context, snapshot) {
                  String photoUrl = '';
                  String bio = 'Olá! Este é meu perfil de leituras.';

                  if (isAnaLeitora) {
                    photoUrl = _anaPhoto;
                    bio =
                        'Leitora Voraz\nAmante de fantasia e ficção científica. 📚✨';
                  } else if (snapshot.hasData &&
                      snapshot.data!.data() != null) {
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    photoUrl = data['photoUrl'] ?? '';
                    bio = data['bio'] ?? bio;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(photoUrl, isAnaLeitora),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(displayName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(bio),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[200],
                                foregroundColor: Colors.black,
                                elevation: 0),
                            child: const Text('Editar Perfil'),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
          body: Column(
            children: [
              const TabBar(
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.black,
                tabs: [
                  Tab(icon: Icon(Icons.grid_on)),
                  Tab(icon: Icon(Icons.bookmark_border)),
                  Tab(icon: Icon(Icons.person_pin_outlined))
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildRealUserGrid(user!.uid),
                    const Center(child: Text('Salvos')),
                    const Center(child: Text('Marcados')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String photoUrl, bool isAna) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          ClipOval(
            child: UniversalImage(
              imageUrl: photoUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _statColumn(isAna ? '4' : '0', 'Resenhas'),
                _statColumn(isAna ? '1.2K' : '0', 'Leitores'),
                _statColumn(isAna ? '320' : '0', 'Seguindo'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statColumn(String value, String label) {
    return Column(children: [
      Text(value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      Text(label, style: const TextStyle(color: Colors.grey))
    ]);
  }

  Widget _buildRealUserGrid(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: _service.getUserPostsStream(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('Sem posts.', style: TextStyle(color: Colors.grey)),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(2),
          itemCount: docs.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
          itemBuilder: (ctx, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            return UniversalImage(
                imageUrl: data['bookCoverUrl'], fit: BoxFit.cover);
          },
        );
      },
    );
  }
}
