class PlayerStats {
  final String name;
  final int wins;
  final double averageWins;

  PlayerStats({
    required this.name,
    required this.wins,
    required this.averageWins,
  });

  factory PlayerStats.fromMap(Map<String, dynamic> map) {
    return PlayerStats(
      name: map['name'] ?? 'Unknown',
      wins: map['wins'] ?? 0,
      averageWins: map['averageWins']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'wins': wins,
      'averageWins': averageWins,
    };
  }
}