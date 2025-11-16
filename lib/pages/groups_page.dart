import 'package:flutter/material.dart';

class ForumPage extends StatelessWidget {
  final String bookName;
  const ForumPage({super.key, required this.bookName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(bookName)),
      body: Center(child: Text('Fórum sobre $bookName')),
    );
  }
}

// Modelo de Dados para cada chat de grupo de leitura
class ReadingGroupChat {
  final String bookTitle;
  final String bookCoverUrl;
  final String lastMessage;
  final String lastMessageBy;
  final String timestamp;
  final bool isUnread;

  ReadingGroupChat({
    required this.bookTitle,
    required this.bookCoverUrl,
    required this.lastMessage,
    required this.lastMessageBy,
    required this.timestamp,
    this.isUnread = false,
  });
}

//  Dados Fictícios para a lista de chats
final List<ReadingGroupChat> groups = [
  ReadingGroupChat(
    bookTitle: 'Clube do Livro: Dom Casmurro',
    bookCoverUrl: 'https://m.media-amazon.com/images/I/81XpG2iKTlL.jpg',
    lastMessage: 'Acho que a Capitu traiu, sim!',
    lastMessageBy: 'Carlos',
    timestamp: '5m',
    isUnread: true,
  ),
  ReadingGroupChat(
    bookTitle: 'Discussão: Matéria Escura',
    bookCoverUrl:
        'https://m.media-amazon.com/images/I/61xHkoffp3L._UF1000,1000_QL80_.jpg',
    lastMessage: 'Qual a parte favorita de vocês no livro?',
    lastMessageBy: 'Vanessa',
    timestamp: '2h',
  ),
  ReadingGroupChat(
    bookTitle: 'Teorias sobre Powerless',
    bookCoverUrl:
        'https://m.media-amazon.com/images/I/51J57kOMjwL._SY445_SX342_ControlCacheEqualizer_.jpg',
    lastMessage: 'Adorei sua resenha com a foto segurando o livro, Ana!',
    lastMessageBy: 'Marina',
    timestamp: '4h',
  ),
  ReadingGroupChat(
    bookTitle: 'Análise de 1984',
    bookCoverUrl:
        'https://m.media-amazon.com/images/I/91g5gcjTxsL._UF1000,1000_QL80_.jpg',
    lastMessage: 'É um final bem impactante mesmo.',
    lastMessageBy: 'Bia',
    timestamp: '2d',
    isUnread: true,
  ),
];

// A Tela Principal 
class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Grupos e Bate-papos',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () {
              /* Lógica para criar novo grupo/chat */
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // -- Barra de Busca --
          _buildSearchBar(),

          // -- Lista de Conversas --
          Expanded(
            child: ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(group.bookCoverUrl),
                  ),
                  title: Text(
                    group.bookTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: group.isUnread ? Colors.black : Colors.grey[800],
                    ),
                  ),
                  subtitle: Text(
                    '${group.lastMessageBy}: ${group.lastMessage}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: group.isUnread
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: group.isUnread ? Colors.black : Colors.grey[600],
                    ),
                  ),
                  trailing: Text(
                    group.timestamp,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ForumPage(bookName: group.bookTitle),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para a barra de busca
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Pesquisar',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
