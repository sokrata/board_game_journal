import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'BoardGame.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _pageController = PageController();
  final Duration _slideDuration = const Duration(seconds: 3);
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<BoardGame> _games = [];
  int _currentIndex = 0;
  int _page = 0;
  bool _isLoadingMore = false;
  Timer? _timer;
  final ScrollController _scrollController = ScrollController();

  // Источник аудио задается здесь (единственное место!)
  // static const _audioSource = AssetSource('sounds/page_turn.mp3');

  @override
  void initState() {
    super.initState();
    _loadGames();
    _setupScrollController();
    _audioPlayer.setSource(AssetSource('sounds/page_turn.mp3'));
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
  }

  void _setupScrollController() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= 
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreGames();
      }
    });
  }

  Future<void> _loadGames({bool loadMore = false}) async {
    if (_isLoadingMore) return;
    
    setState(() => _isLoadingMore = true);
    
    try {
      final query = FirebaseFirestore.instance
          .collection('games')
          .orderBy('lastPlayed', descending: true)
          .limit(10);

      if (loadMore && _games.isNotEmpty) {
        query.startAfter([_games.last.lastPlayed]);
      }

      final snapshot = await query.get();

      final newGames = snapshot.docs.map((doc) => BoardGame.fromFirestore2(doc)).toList();

      setState(() {
        if (loadMore) {
          _games.addAll(newGames);
          _page++;
        } else {
          _games = newGames;
        }
        _isLoadingMore = false;
      });

      if (!loadMore) _startAutoSlide();
    } catch (e) {
      print('Error loading games: $e');
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _loadMoreGames() => _loadGames(loadMore: true);

  void _startAutoSlide() {
    _timer?.cancel();
    _timer = Timer.periodic(_slideDuration, (timer) {
      if (_currentIndex < _games.length - 1) {
        _navigateToPage(_currentIndex + 1);
      } else {
        _navigateToPage(0);
      }
    });
  }

  Future<void> _navigateToPage(int index) async {
    await _audioPlayer.seek(Duration.zero);
    await _audioPlayer.resume();
    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  void _handleSwipe(int index) {
    _currentIndex = index;
    _timer?.cancel();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildPageView(),
          _buildSkipButton(),
          if (_isLoadingMore) _buildLoadingIndicator(),
        ],
      ),
    );
  }

  Widget _buildPageView() {
    return PageView.builder(
      controller: _pageController,
      itemCount: _games.length + 1,
      onPageChanged: _handleSwipe,
      itemBuilder: (context, index) {
        if (index >= _games.length) {
          return _buildLoadingTile();
        }
        return _GameSlide(game: _games[index]);
      },
    );
  }

  Widget _buildSkipButton() {
    return Positioned(
      top: 40,
      right: 20,
      child: IconButton(
        icon: const Icon(Icons.close, color: Colors.white, size: 30),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
    ));
  }

  Widget _buildLoadingTile() {
    return const Center(child: CircularProgressIndicator());
  }
}

class _GameSlide extends StatelessWidget {
  final BoardGame game;

  const _GameSlide({required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade900, Colors.blue.shade400],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAnimatedImage(),
          const SizedBox(height: 30),
          _buildAnimatedTitle(),
          _buildAnimatedYear(),
        ],
      ),
    );
  }

  Widget _buildAnimatedImage() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: CachedNetworkImage(
        key: ValueKey(game.images.first),
        imageUrl: game.images.first,
        width: 300,
        height: 300,
        fit: BoxFit.cover,
        placeholder: (ctx, url) => Container(
          width: 300,
          height: 300,
          color: Colors.grey[300],
        ),
        errorWidget: (ctx, url, err) => const Icon(Icons.error),
        imageBuilder: (ctx, image) => DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(image: image, fit: BoxFit.cover),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTitle() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.5),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: Text(
        game.title,
        key: ValueKey(game.title),
        style: const TextStyle(
          fontSize: 32,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 10,
              color: Colors.black,
              offset: Offset(2, 2),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedYear() {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 500),
      child: Text(
        'Год выпуска: ${game.year}',
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white70,
        ),
      ),
    );
  }
}