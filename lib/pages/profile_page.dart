import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // gerenciar as abas
    return DefaultTabController(
      length: 3, // Número de abas (Resenhas, Salvos, Marcado)
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: const Text(
            'ana_leitora', // Nome do usuário
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_box_outlined, color: Colors.black),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {},
            ),
          ],
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // -- Seção 1: Foto de Perfil e Estatísticas --
                    _buildProfileHeader(),

                    // -- Seção 2: Biografia do Usuário --
                    _buildProfileBio(),

                    // -- Seção 3: Botões de Ação --
                    _buildActionButtons(),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ];
          },
          body: Column(
            children: [
              // -- Seção 4: Abas de Conteúdo --
              const TabBar(
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.black,
                tabs: [
                  Tab(icon: Icon(Icons.grid_on)),
                  Tab(icon: Icon(Icons.bookmark_border)),
                  Tab(icon: Icon(Icons.person_pin_outlined)),
                ],
              ),
              // -- Seção 5: Conteúdo das Abas --
              Expanded(
                child: TabBarView(
                  children: [
                    // Grid de Resenhas (posts)
                    _buildPostsGrid(),

                    // Conteúdo da Aba "Salvos"
                    const Center(child: Text('Livros salvos para ler depois.')),

                    // Conteúdo da Aba "Marcado"
                    const Center(
                      child: Text('Resenhas em que você foi marcado.'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para o cabeçalho com foto e estatísticas
  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const CircleAvatar(
            radius: 45,
            backgroundImage: NetworkImage(
              'https://i.pinimg.com/736x/c0/f0/45/c0f045ba3abb1d2a2ee294bbd3407b59.jpg',
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn('8', 'Resenhas'),
                _buildStatColumn('1.2K', 'Leitores'),
                _buildStatColumn('320', 'Seguindo'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget para a biografia
  Widget _buildProfileBio() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ana Clara',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 4),
          Text('Leitora Voraz', style: TextStyle(color: Colors.grey)),
          SizedBox(height: 8),
          Text(
            'Amante de fantasia e ficção científica. Sempre em busca da próxima grande aventura literária. 📚✨',
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  // Widget para os botões de "Editar Perfil", etc.
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                elevation: 0,
              ),
              child: const Text(
                'Editar Perfil',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  // Widget para a coluna de estatísticas (reutilizável)
  Widget _buildStatColumn(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  // Widget para o grid de posts (capas de livros)
  Widget _buildPostsGrid() {
    // Lista de URLs de capas de livros para o grid
    final List<String> bookCoverUrls = [
      'https://m.media-amazon.com/images/I/81XpG2iKTlL.jpg',
      'https://m.media-amazon.com/images/I/810fw8crP9L._UF1000,1000_QL80_.jpg',
      'https://m.media-amazon.com/images/I/61xHkoffp3L._UF1000,1000_QL80_.jpg',
      'https://i.pinimg.com/736x/76/55/e3/7655e334e78c7d77e72d1a5e613c8ebb.jpg',
      'https://m.media-amazon.com/images/I/81FH6q0EqYS.jpg',
      'https://m.media-amazon.com/images/I/61HgbCkcz4L._UF1000,1000_QL80_.jpg',
      'https://m.media-amazon.com/images/I/91P9MlJrA3L.jpg',
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: bookCoverUrls.length,
      itemBuilder: (context, index) {
        return Image.network(bookCoverUrls[index], fit: BoxFit.cover);
      },
    );
  }
}
