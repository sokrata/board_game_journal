import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'PlayerStats.dart';

class EditGameScreen extends StatefulWidget {
  const EditGameScreen({this.gameId, super.key});
  final String? gameId;

  @override
  State<EditGameScreen> createState() => _EditGameScreenState();
}

class _EditGameScreenState extends State<EditGameScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _playsController = TextEditingController();
  DateTime? _lastPlayed;
  final List<TextEditingController> _imageControllers = [];
  final List<PlayerStats> _players = [];

  @override
  void initState() {
    super.initState();
    if (widget.gameId != null) {
      _loadGameData();
    } else {
      _initializeControllers();
    }
  }

  Future<void> _loadGameData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('games')
          .doc(widget.gameId)
          .get();

      if (!doc.exists) {
        return;
      }

      final data = doc.data()!;

      // Явное преобразование типов
      _titleController.text = data['title']?.toString() ?? '';
      _yearController.text = data['year']?.toString() ?? '';
      _playsController.text = data['totalPlays']?.toString() ?? '';
      _lastPlayed = (data['lastPlayed'] as Timestamp).toDate();

      _imageControllers.clear();
      _imageControllers.addAll(
        (data['images'] as List<dynamic>).map((url) => TextEditingController(text: url.toString())),
      );

      _players.clear();
      _players.addAll(
        (data['winners'] as List<dynamic>).map((p) => PlayerStats.fromMap(p as Map<String, dynamic>)),
      );

      setState(() {});
    } catch (e) {
      print('Error loading game: $e');
    }
  }

  void _initializeControllers() {
    _imageControllers.add(TextEditingController());
  }

  Future<void> _saveGame() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final gameData = {
        'title': _titleController.text,
        'year': int.tryParse(_yearController.text) ?? 0,
        'totalPlays': int.tryParse(_playsController.text) ?? 0,
        'lastPlayed': _lastPlayed ?? DateTime.now(),
        'images': _imageControllers.where((c) => c.text.isNotEmpty).map((c) => c.text).toList(),
        'winners': _players.map((p) => p.toMap()).toList(),
      };

      if (widget.gameId == null) {
        await FirebaseFirestore.instance.collection('games'). add(gameData);
      } else {
        await FirebaseFirestore.instance
            .collection('games')
            .doc(widget.gameId)
            .update(gameData); // Используем update вместо set
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving data: $e')),
      );
    }
  }


  // @override
  // Widget build(BuildContext context) {
  //   if (widget.gameId != null && _titleController.text.isEmpty) {
  //     return const Center(child: CircularProgressIndicator());
  //   }
  //
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text(widget.gameId == null ? 'New Game' : 'Edit Game'),
  //       actions: [IconButton(icon: const Icon(Icons.save), onPressed: _saveGame)],
  //     ),
  //     body: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Form(
  //         key: _formKey,
  //         child: ListView(
  //           children: [
  //             TextFormField(
  //               controller: _titleController,
  //               decoration: const InputDecoration(labelText: 'Game Title'),
  //               keyboardType: TextInputType.text,
  //               validator: (value) => value!.isEmpty ? 'Required' : null,
  //             ),
  //             TextFormField(
  //               controller: _yearController,
  //               decoration: const InputDecoration(labelText: 'Year'),
  //               keyboardType: TextInputType.number,
  //               inputFormatters: [FilteringTextInputFormatter.digitsOnly],
  //               validator: (value) => value!.isEmpty ? 'Required' : null,
  //             ),
  //             TextFormField(
  //               controller: _playsController,
  //               decoration: const InputDecoration(labelText: 'Total Plays'),
  //               keyboardType: TextInputType.number,
  //               inputFormatters: [FilteringTextInputFormatter.digitsOnly],
  //               validator: (value) => value!.isEmpty ? 'Required' : null,
  //             ),
  //             ListTile(
  //               title: Text(_lastPlayed == null
  //                   ? 'Select Last Play Date'
  //                   : DateFormat.yMMMd().format(_lastPlayed!)),
  //               trailing: const Icon(Icons.calendar_today),
  //               onTap: () async {
  //                 final date = await showDatePicker(
  //                   context: context,
  //                   initialDate: DateTime.now(),
  //                   firstDate: DateTime(1900),
  //                   lastDate: DateTime.now(),
  //                 );
  //                 if (date != null) setState(() => _lastPlayed = date);
  //               },
  //             ),
  //             const Divider(),
  //             ..._buildImageFields(),
  //             IconButton(
  //               icon: const Icon(Icons.add_a_photo),
  //               onPressed: () => setState(() => _imageControllers.add(TextEditingController())),
  //             ),
  //             const Divider(),
  //             ..._buildPlayerFields(),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // List<Widget> _buildImageFields() {
  //   return [
  //     SizedBox(
  //       height: 200, // Set a fixed height for the image display area
  //       child: Stack(
  //         children: _imageControllers.asMap().entries.map((entry) {
  //           final index = entry.key;
  //           final controller = entry.value;
  //           return Positioned(
  //             left: index * 20.0, // Adjust the left position for overlap
  //             child: SizedBox(
  //               width: 100, // Set a fixed width for each image
  //               child: TextFormField(
  //                 controller: controller,
  //                 decoration: InputDecoration(
  //                   labelText: 'Image URL ${index + 1}',
  //                   suffixIcon: IconButton(
  //                     icon: const Icon(Icons.close),
  //                     onPressed: () => setState(() => _imageControllers.removeAt(index)),
  //                   ),
  //                 ),
  //                 validator: (value) => value!.isEmpty ? 'Required' : null,
  //               ),
  //             ),
  //           );
  //         }).toList(),
  //       ),
  //     ),
  //     IconButton(
  //       icon: const Icon(Icons.add_a_photo),
  //       onPressed: () => setState(() => _imageControllers.add(TextEditingController())),
  //     ),
  //   ];
  // }

  Widget _buildImageFields() {
    return Column(
      children: _imageControllers.asMap().entries.map((entry) {
        final index = entry.key;
        final controller = entry.value;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Image URL ${index + 1}',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _imageControllers.removeAt(index)),
                    ),
                  ),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _buildPlayerFields() {
    return [
      const Text('Players:', style: TextStyle(fontSize: 18)),
      ..._players.asMap().entries.map((entry) {
        final index = entry.key;
        final player = entry.value;
        return ListTile(
          title: Text(player.name),
          subtitle: Text('Wins: ${player.wins} (Avg: ${player.averageWins.toStringAsFixed(1)})'),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editPlayerStats(index),
          ),
        );
      }),
      TextButton(
        child: const Text('Add Player'),
        onPressed: () => _editPlayerStats(null),
      ),
    ];
  }

  void _editPlayerStats(int? index) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index == null ? 'New Player' : 'Edit Player'),
        content: TextFormField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Player Name'),
        ),
        actions: [
          TextButton(
            child: const Text('Save'),
            onPressed: () {
              if (controller.text.isEmpty) return;
              final player = PlayerStats(
                name: controller.text,
                wins: 0,
                averageWins: 0,
              );
              if (index == null) {
                setState(() => _players.add(player));
              } else {
                setState(() => _players[index] = player);
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _lastPlayed ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _lastPlayed) {
      setState(() {
        _lastPlayed = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gameId == null ? 'New Game' : 'Edit Game'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _saveGame)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Game Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(
                  labelText: 'Year',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _playsController,
                decoration: const InputDecoration(
                  labelText: 'Total Plays',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(_lastPlayed == null
                    ? 'Select Last Play Date'
                    : DateFormat.yMMMd().format(_lastPlayed!)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
                tileColor: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Images:', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              _buildImageFields(),
              IconButton(
                icon: const Icon(Icons.add_a_photo),
                onPressed: () => setState(() => _imageControllers.add(TextEditingController())),
              ),
              // OutlinedButton(
              //   onPressed: () => setState(() => _imageControllers.add(TextEditingController())),
              //   child: const Text('Add Image URL'),
              // ),
              const SizedBox(height: 24),
              const Divider(),
              ..._buildPlayerFields(),
            ],
          ),
        ),
      ),
    );
  }

}
