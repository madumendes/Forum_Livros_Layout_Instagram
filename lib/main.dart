import 'package:flutter/material.dart';

// Imports das suas páginas (mantidos)
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/groups_page.dart';
import 'pages/profile_page.dart';

void main() {
  runApp(const BookForumApp());
}

class BookForumApp extends StatelessWidget {
  const BookForumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BookForum',
      // Um tema mais neutro para combinar com o estilo do Instagram
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    GroupsPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const String userProfileImageUrl =
        'https://i.pinimg.com/736x/c0/f0/45/c0f045ba3abb1d2a2ee294bbd3407b59.jpg';

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        // --- Principais Mudanças Aqui ---

        // 1. Remove os rótulos de texto
        showSelectedLabels: false,
        showUnselectedLabels: false,

        // 2. Define as cores dos ícones e o fundo
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,

        // 3. Mantém o tipo como 'fixed' para um visual estável
        type: BottomNavigationBarType.fixed,
        elevation: 1,

        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          // 4. Ícones que mudam com a seleção (preenchido vs. contorno)
          BottomNavigationBarItem(
            icon: Icon(_selectedIndex == 0 ? Icons.home : Icons.home_outlined),
            label: 'Início', // O label ainda é necessário para acessibilidade
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _selectedIndex == 1
                  ? Icons.chat_bubble
                  : Icons.chat_bubble_outline,
            ),
            label: 'Grupos',
          ),
          // 5. Ícone de perfil customizado com a foto do usuário
          BottomNavigationBarItem(
            label: 'Perfil',
            icon: CircleAvatar(
              radius: 14,
              backgroundImage: const NetworkImage(userProfileImageUrl),
              // Adiciona uma borda se o item estiver selecionado
              child: _selectedIndex == 2
                  ? Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
