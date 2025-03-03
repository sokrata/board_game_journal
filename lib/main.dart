import 'package:board_game_journal/EditGameScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'GameDetailsScreen.dart';
import 'SplashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Board Game Stats',
      theme: ThemeData(primarySwatch: Colors.blue),
      routes: {
        '/': (context) => const GamesListScreen(),
        '/splash': (context) => const SplashScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/edit') {
          final gameId = settings.arguments as String?;
          return MaterialPageRoute(
            builder: (context) => EditGameScreen(gameId: gameId),
          );
        }
        return null;
      },
    );
  }
}

class GamesListScreen extends StatelessWidget {
  const GamesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Board Games'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/edit'),
          ),
          IconButton(
              // Новая кнопка для запуска заставки
              icon: const Icon(Icons.slideshow),
              onPressed: () => //Navigator.pushNamed(context, '/splash'),
                  // //Передача параметров в SplashScreen:
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => const SplashScreen(autoClose: true),
                  //   ),
                  // )
                  //Добавление анимации перехода
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const SplashScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                    ),
                  ))
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('games').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Text('Error');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final game = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(game['title']),
                subtitle: Text('Plays: ${game['totalPlays']}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameDetailsScreen(gameId: doc.id),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

// Остальной код из предыдущего примера (BoardGame, PlayerStats, GameDetailsScreen.dart)
// с модификацией для загрузки данных из Firestore