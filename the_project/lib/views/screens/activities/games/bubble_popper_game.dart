import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../widgets/activity_shell.dart';

class BubblePopperGame extends StatefulWidget {
  const BubblePopperGame({super.key});

  @override
  State<BubblePopperGame> createState() => _BubblePopperGameState();
}

class _BubblePopperGameState extends State<BubblePopperGame> {
  static const int _rows = 7;
  static const int _cols = 4;

  // popped state
  late List<List<bool>> _popped;

  // low-latency audio (preloaded)
  late final AudioPlayer _player;

  // row strip colors (match your reference)
  static const List<Color> _rowColors = [
    Color(0xFF7027B9), // deep purple
    Color(0xFF3D57B7), // indigo/blue
    Color(0xFFCFE6FA), // light blue
    Color(0xFF0C7A68), // teal
    Color(0xFFA9E076), // light green
    Color(0xFFFF8E42), // orange
    Color(0xFFFF72AE), // pink
  ];

  @override
  void initState() {
    super.initState();
    _popped = List.generate(_rows, (_) => List.generate(_cols, (_) => false));

    _player = AudioPlayer(playerId: 'pop');
    _player.setReleaseMode(ReleaseMode.stop);
    _player.setVolume(1.0);
    _player.setSourceAsset('sounds/pop.mp3'); // ensure in pubspec.yaml
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playPop() async {
    try {
      await _player.seek(Duration.zero);
      await _player.resume();
    } catch (_) {
      // ignore device-specific audio errors
    }
  }

  void _toggle(int r, int c) {
    setState(() => _popped[r][c] = !_popped[r][c]);
    HapticFeedback.lightImpact();
    _playPop();
  }

  @override
  Widget build(BuildContext context) {
    return ActivityShell(
      title: 'Pop It',
      child: Column(
        children: [
          // Instruction card (fixed intrinsic height)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3EB),
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                'Find calm and focus as you pop away stress, one bubble at a time.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.3,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ),
          ),

          // Board fills the remaining space (no scrolling)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3EB),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: _Board(
                  rows: _rows,
                  cols: _cols,
                  rowColors: _rowColors,
                  popped: _popped,
                  onToggle: _toggle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The board computes bubble size from available width **and** height,
/// ensuring the whole grid fits with no need to scroll.
class _Board extends StatelessWidget {
  const _Board({
    required this.rows,
    required this.cols,
    required this.rowColors,
    required this.popped,
    required this.onToggle,
  });

  final int rows;
  final int cols;
  final List<Color> rowColors;
  final List<List<bool>> popped;
  final void Function(int r, int c) onToggle;

  @override
  Widget build(BuildContext context) {
    const outerPad = EdgeInsets.fromLTRB(16, 16, 16, 16);
    const innerPad = EdgeInsets.fromLTRB(16, 16, 16, 16);
    const double bandGap = 12.0;
    const double bandPadV = 10.0; // vertical padding inside each color band

    return LayoutBuilder(
      builder: (context, constraints) {
        final double boardMaxW = constraints.maxWidth;
        final double boardMaxH = constraints.maxHeight;

        final double usableW = boardMaxW - outerPad.horizontal - innerPad.horizontal;
        final double usableH = boardMaxH - outerPad.vertical - innerPad.vertical;

        // width-based bubble size
        final double sizeByW = (usableW - bandGap * (cols - 1)) / cols;

        // height-based bubble size (subtract row paddings & gaps)
        final double sizeByH =
            (usableH - (rows * (bandPadV * 2)) - bandGap * (rows - 1)) / rows;

        final double bubbleSize = sizeByW < sizeByH ? sizeByW : sizeByH;

        return Padding(
          padding: outerPad,
          child: Container(
            padding: innerPad,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(rows, (r) {
                final band = rowColors[r % rowColors.length];
                return Container(
                  margin: EdgeInsets.only(bottom: r == rows - 1 ? 0 : bandGap),
                  decoration: BoxDecoration(
                    color: band,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: bandPadV),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(cols, (c) {
                      final isDown = popped[r][c];
                      return _Bubble(
                        size: bubbleSize,
                        band: band,
                        down: isDown,
                        onPressed: () => onToggle(r, c),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}

/// Single bubble with fast tap reaction, soft animation, and glossy ring.
class _Bubble extends StatelessWidget {
  final double size;
  final Color band;
  final bool down;
  final VoidCallback onPressed;

  const _Bubble({
    required this.size,
    required this.band,
    required this.down,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        type: MaterialType.transparency,
        child: InkResponse(
          onTap: onPressed,
          radius: size / 2 + 6,
          containedInkWell: true,
          customBorder: const CircleBorder(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 90),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: down ? band.withOpacity(0.68) : band,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: down
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(.28),
                        offset: const Offset(2, 3),
                        blurRadius: 6,
                      ),
                    ]
                  : [
                      const BoxShadow(
                        color: Colors.white38,
                        offset: Offset(-2, -2),
                        blurRadius: 3,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(.25),
                        offset: const Offset(3, 4),
                        blurRadius: 6,
                      ),
                    ],
            ),
            child: Stack(
              children: [
                if (!down)
                  Align(
                    alignment: const Alignment(-0.45, -0.45),
                    child: Container(
                      width: size * .38,
                      height: size * .38,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white24,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
