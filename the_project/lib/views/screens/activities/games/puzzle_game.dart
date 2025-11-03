import 'dart:math';
import 'package:flutter/material.dart';
import '../../../widgets/activities/activity_shell.dart';

class PuzzleGame extends StatefulWidget {
  const PuzzleGame({super.key});

  @override
  State<PuzzleGame> createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGame> {
  static const int _n = 3; // 3x3 sliding puzzle
  late List<int> _tiles;   // values 1..8 and 0 for empty
  bool _showSolvedBanner = false;

  @override
  void initState() {
    super.initState();
    _reset(shuffle: true);
  }

  void _reset({bool shuffle = false}) {
    _showSolvedBanner = false;
    _tiles = List<int>.generate(_n * _n, (i) => (i + 1) % (_n * _n)); // [1..8,0]
    if (shuffle) _shuffleToSolvable();
    setState(() {});
  }

  void _shuffleToSolvable() {
    final rand = Random();
    do {
      _tiles.shuffle(rand);
    } while (!_isSolvable(_tiles) || _isSolved());
  }

  bool _isSolvable(List<int> list) {
    // For odd grids (3x3), solvable when inversion count is even
    int inv = 0;
    final nums = list.where((x) => x != 0).toList();
    for (int i = 0; i < nums.length; i++) {
      for (int j = i + 1; j < nums.length; j++) {
        if (nums[i] > nums[j]) inv++;
      }
    }
    return inv.isEven;
  }

  bool _isSolved() {
    for (int i = 0; i < _tiles.length - 1; i++) {
      if (_tiles[i] != i + 1) return false;
    }
    return _tiles.last == 0;
  }

  void _onTileTap(int idx) {
    final empty = _tiles.indexOf(0);
    final canSwap = _isNeighbor(idx, empty);
    if (!canSwap) return;

    setState(() {
      final t = _tiles[idx];
      _tiles[idx] = 0;
      _tiles[empty] = t;
      if (_isSolved()) _showSolvedBanner = true;
    });
  }

  bool _isNeighbor(int a, int b) {
    final ax = a ~/ _n, ay = a % _n;
    final bx = b ~/ _n, by = b % _n;
    return (ax == bx && (ay - by).abs() == 1) ||
           (ay == by && (ax - bx).abs() == 1);
  }

  @override
  Widget build(BuildContext context) {
    return ActivityShell(
      title: 'Puzzle',
      child: Column(
        children: [
          // Top instruction + actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3EB),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 3))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Slide the tiles to re-create the correct order.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, height: 1.35, color: Color(0xFF2B2B2B)),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _reset(shuffle: true),
                        icon: const Icon(Icons.shuffle_rounded, size: 18),
                        label: const Text('Shuffle'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _reset(shuffle: false),
                        icon: const Icon(Icons.restart_alt_rounded, size: 18),
                        label: const Text('Reset'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Board
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: LayoutBuilder(
                builder: (context, c) {
                  final size = min(c.maxWidth, c.maxHeight);
                  return Center(
                    child: Stack(
                      children: [
                        Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 8)],
                          ),
                          padding: const EdgeInsets.all(10),
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: _n,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                            ),
                            itemCount: _tiles.length,
                            itemBuilder: (_, i) {
                              final v = _tiles[i];
                              if (v == 0) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF6F6F6),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                );
                              }
                              return InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () => _onTileTap(i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFB8C9FF), Color(0xFF8EA8FF)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: const [
                                      BoxShadow(color: Color(0x1F000000), blurRadius: 6, offset: Offset(0, 3))
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$v',
                                      style: const TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Solved banner
                        if (_showSolvedBanner)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2DBE7B),
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: const Text(
                                    'Solved! 🎉',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
