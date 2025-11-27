class Book {
  // campos que vem do Java (não mais utlizados)
  final int? id;
  final String title;
  final String author;
  final String coverImageUrl;
  final bool available; // <--- Este é o campo que estava faltando

  // visual do instagram
  final String username;
  final String profileImageUrl;
  final String review;
  final int likeCount;
  final int commentCount;
  final String timeAgo;

  Book({
    this.id,
    required this.title,
    required this.author,
    required this.coverImageUrl,
    this.available = true, // <--- Adicionamos de volta no construtor

    // Valores padrão para a UI não quebrar
    this.username = 'Leitor(a) da Comunidade',
    this.profileImageUrl =
        'https://cdn-icons-png.flaticon.com/512/149/149071.png',
    this.review = '',
    this.likeCount = 0,
    this.commentCount = 0,
    this.timeAgo = 'agora',
  });

  // Converte JSON do Java -não mais usado
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      // 1. Dados Reais da API
      id: json['id'],
      title: json['title'] ?? 'Sem Título',
      author: json['author'] ?? 'Autor Desconhecido',
      coverImageUrl:
          json['coverImageUrl'] ?? 'https://via.placeholder.com/400x400',
      available: json['available'] ?? true, // Lê do JSON

      // 2. Adaptação Visual (POG "Provisório" para ficar bonito)
      review: "Estou lendo ${json['title']} escrito por ${json['author']}.",
    );
  }

  // Envia Modelo do App - não mais usado
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'coverImageUrl': coverImageUrl,
      'communityId': 1, // Valor fixo exigido pelo Java DTO
      'available': available, // Envia para o Java - não mais usado
    };
  }
}
