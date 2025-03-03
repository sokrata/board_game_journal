import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'BoardGame.dart';
import 'PlayerStats.dart';

class GameDetailsScreen extends StatefulWidget {
  final String gameId; // Добавляем параметр если используется

  const GameDetailsScreen({super.key, required this.gameId});

  @override
  State<GameDetailsScreen> createState() => _GameDetailsScreenState();
}

class _GameDetailsScreenState extends State<GameDetailsScreen>
    with SingleTickerProviderStateMixin {
  // Добавляем недостающие переменные
  // late BoardGame _gameData;
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  final double _imageSize = 150.0;
  final double _imageSpacing = 10.0;

  @override
  void initState() {
    super.initState();
    // Инициализация данных (пример)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  // // Добавляем обязательный метод build
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: Text(_gameData.title)),
  //     body: SingleChildScrollView(
  //       child: Column(
  //         children: [
  //           _buildImageCollage(),
  //           // Остальные элементы интерфейса
  //         ],
  //       ),
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.pushNamed(
              context,
              '/edit',
              arguments: widget.gameId,
            ),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('games')
            .doc(widget.gameId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Game not found'));
          }

          final gameData = snapshot.data!.data() as Map<String, dynamic>;
          final boardGame = BoardGame.fromFirestore(gameData);
           return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageCollage(boardGame),
                const SizedBox(height: 20),
                _buildGameInfo(boardGame),
                const SizedBox(height: 20),
                _buildWinnersList(boardGame.winners),
              ],
            ),
          );
        },
      ),
    );
  }

  
  Widget _buildGameInfo(BoardGame game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${game.title} (${game.year})',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoRow('Last Played',
          DateFormat.yMMMd().add_Hms().format(game.lastPlayed)),
        _buildInfoRow('Total Plays', game.totalPlays.toString()),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinnersList(List<PlayerStats> winners) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Players',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
          ),
        ),
        const SizedBox(height: 12),
        ...winners.map((player) => _buildPlayerTile(player)),
      ],
    );
  }

  Widget _buildPlayerTile(PlayerStats player) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const Icon(Icons.person, size: 32),
        title: Text(
          player.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'Wins: ${player.wins} | Avg: ${player.averageWins.toStringAsFixed(1)}',
        ),
        trailing: Chip(
          label: Text('#${player.wins}'),
          backgroundColor: Colors.amber.shade100,
        ),
      ),
    );
  }

  // Остальные методы (_buildImageCollage, _calculatePosition и т.д.)
  // ... (как в предыдущих примерах)
  Widget _buildImageCollage(BoardGame gameData) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final imagesCount = gameData.images.length;
        final itemsPerRow = (maxWidth / (_imageSize + _imageSpacing)).floor();
        final overlapStart = itemsPerRow > 0 ? itemsPerRow : 0;

        return SizedBox(
          height: _imageSize * 1.2,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                children: gameData.images.asMap().entries.map((entry) {
                  final index = entry.key;
                  final image = entry.value;
                  final position = _calculatePosition(index, maxWidth);

                  return Positioned(
                    left: position.dx,
                    top: position.dy,
                    child: Opacity(
                      opacity: _opacityAnimation.value,
                      child: Transform.scale(
                        scale: position.scale,
                        child: Container(
                          width: _imageSize,
                          height: _imageSize,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: NetworkImage(image),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        );
      },
    );
  }

  _ImagePosition _calculatePosition(int index, double maxWidth) {
    final itemsPerRow = (maxWidth / (_imageSize + _imageSpacing)).floor();
    final isOverlapping = index >= itemsPerRow && itemsPerRow > 0;
    final row = isOverlapping ? (index - itemsPerRow) ~/ 3 : 0;
    final column = isOverlapping ? (index - itemsPerRow) % 3 : index;

    double leftPosition;
    double topPosition;
    double scale;

    if (!isOverlapping && itemsPerRow > 0) {
      final availableSpace = maxWidth - (itemsPerRow * _imageSize);
      final spacing = availableSpace / (itemsPerRow + 1);
      leftPosition = spacing + (column * (_imageSize + spacing));
      topPosition = 0.0;
      scale = 1.0;
    } else {
      leftPosition = maxWidth - _imageSize - (column * 20);
      topPosition = row * 30.0;
      scale = 1.0 - (row * 0.05);
    }

    final animationOffset =
        isOverlapping ? const Offset(50.0, -50.0) : const Offset(-50.0, 0.0);

    final currentOffset = Offset(
      leftPosition + animationOffset.dx * (1 - _opacityAnimation.value),
      topPosition + animationOffset.dy * (1 - _opacityAnimation.value),
    );

    return _ImagePosition(
      dx: currentOffset.dx,
      dy: currentOffset.dy,
      scale: scale * _opacityAnimation.value,
    );
  }
}

class _ImagePosition {
  final double dx;
  final double dy;
  final double scale;

  _ImagePosition({
    required this.dx,
    required this.dy,
    required this.scale,
  });
}

/*
class GameDetailsScreen extends StatefulWidget {
  final String gameId;

   const GameDetailsScreen({required this.gameId, super.key});

  @override
  State<GameDetailsScreen> createState() => _GameDetailsScreenState();
}

class _GameDetailsScreenState extends State<GameDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutQuad,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.pushNamed(
              context,
              '/edit',
              arguments: widget.gameId,
            ),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('games')
            .doc(widget.gameId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Game not found'));
          }

          final gameData = snapshot.data!.data() as Map<String, dynamic>;
          final boardGame = BoardGame.fromFirestore(gameData);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageCollage(boardGame.images),
                const SizedBox(height: 20),
                _buildGameInfo(boardGame),
                const SizedBox(height: 20),
                _buildWinnersList(boardGame.winners),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageCollage(List<String> images) {
    return SizedBox(
      height: 250,
      child: Stack(
        children: images.asMap().entries.map((entry) {
          final index = entry.key;
          final imageUrl = entry.value;
          return Positioned(
            left: index * 40.0,
            top: index * 20.0,
            child: ScaleTransition(
              scale: _animation,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGameInfo(BoardGame game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${game.title} (${game.year})',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoRow('Last Played',
          DateFormat.yMMMd().add_Hms().format(game.lastPlayed)),
        _buildInfoRow('Total Plays', game.totalPlays.toString()),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinnersList(List<PlayerStats> winners) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Players',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
          ),
        ),
        const SizedBox(height: 12),
        ...winners.map((player) => _buildPlayerTile(player)),
      ],
    );
  }

  Widget _buildPlayerTile(PlayerStats player) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const Icon(Icons.person, size: 32),
        title: Text(
          player.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'Wins: ${player.wins} | Avg: ${player.averageWins.toStringAsFixed(1)}',
        ),
        trailing: Chip(
          label: Text('#${player.wins}'),
          backgroundColor: Colors.amber.shade100,
        ),
      ),
    );
  }
}
*/