import 'package:cloud_firestore/cloud_firestore.dart'; // Importante
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'widgets/universal_image.dart';
import 'services/notification_service.dart';

import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/groups_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().initNotifications();
  runApp(const BookForumApp());
}

class BookForumApp extends StatelessWidget {
  const BookForumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BookForum',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LoginPage();
        return const MainPage();
      },
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isAna = user?.email == 'ana@leitora.com';

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: StreamBuilder<DocumentSnapshot>(
        // Se for Ana, não precisa ouvir o banco. Se for usuário, ouve o documento dele.
        stream: isAna || user == null
            ? const Stream.empty()
            : FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .snapshots(),
        builder: (context, snapshot) {
          // Lógica da Foto
          String? photoUrl;

          if (isAna) {
            photoUrl =
                'https://i.pinimg.com/736x/c0/f0/45/c0f045ba3abb1d2a2ee294bbd3407b59.jpg';
          } else if (snapshot.hasData && snapshot.data!.data() != null) {
            // Pega a foto Base64 do banco
            photoUrl =
                (snapshot.data!.data() as Map<String, dynamic>)['photoUrl'];
          }

          final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;

          return BottomNavigationBar(
            showSelectedLabels: false,
            showUnselectedLabels: false,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.black54,
            type: BottomNavigationBarType.fixed,
            elevation: 1,
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                    _selectedIndex == 0 ? Icons.home : Icons.home_outlined),
                label: 'Início',
              ),
              BottomNavigationBarItem(
                icon: Icon(_selectedIndex == 1
                    ? Icons.chat_bubble
                    : Icons.chat_bubble_outline),
                label: 'Grupos',
              ),
              BottomNavigationBarItem(
                label: 'Perfil',
                icon: Container(
                  decoration: _selectedIndex == 2
                      ? BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 2))
                      : null,
                  child: ClipOval(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: hasPhoto
                          ? UniversalImage(
                              imageUrl: photoUrl, fit: BoxFit.cover)
                          : Icon(
                              _selectedIndex == 2
                                  ? Icons.person
                                  : Icons.person_outline,
                              size: 24,
                              color: Colors.black87),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
