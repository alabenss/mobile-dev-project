import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:the_project/l10n/app_localizations.dart';

import '../../../widgets/activities/activity_shell.dart';
import '../../../themes/style_simple/colors.dart';

import '../../../../logic/activities/games/coloring_cubit.dart';
import '../../../../logic/activities/games/coloring_state.dart';

// helper that loads SVG templates
import 'svg_template_loader.dart';

class ColoringPage extends StatefulWidget {
  const ColoringPage({super.key});

  @override
  State<ColoringPage> createState() => _ColoringPageState();
}

class _ColoringPageState extends State<ColoringPage> {
  final GlobalKey _repaintKey = GlobalKey();

  Future<void> _saveToGallery(Color bgColor) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      // Permissions (Android 13+ uses photos/media; older Android may need storage)
      PermissionStatus status;
      if (Platform.isIOS) {
        status = await Permission.photosAddOnly.request();
      } else {
        status = await Permission.photos.request();
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
      }

      if (!status.isGranted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              (l10n as dynamic).coloringPermissionDenied ??
                  'Permission denied. Please allow gallery access.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Capture the RepaintBoundary safely
      final renderObject = _repaintKey.currentContext?.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              (l10n as dynamic).coloringSaveFailed ??
                  'Failed to capture coloring.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // 1) Capture widget
      final ui.Image captured = await renderObject.toImage(pixelRatio: 3.0);

      // 2) Flatten onto solid background (fixes black background in file viewers)
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final bgPaint = Paint()..color = bgColor;
      canvas.drawRect(
        Rect.fromLTWH(
          0,
          0,
          captured.width.toDouble(),
          captured.height.toDouble(),
        ),
        bgPaint,
      );

      canvas.drawImage(captured, Offset.zero, Paint());

      final picture = recorder.endRecording();
      final ui.Image finalImage =
          await picture.toImage(captured.width, captured.height);

      final ByteData? byteData =
          await finalImage.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              (l10n as dynamic).coloringSaveFailed ?? 'Failed to save image.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      await Gal.putImageBytes(
        pngBytes,
        album: 'Rise',
        name: "coloring_${DateTime.now().millisecondsSinceEpoch}.png",
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.coloringSaved),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (AppLocalizations.of(context) as dynamic).coloringSaveFailed ??
                'Failed to save image: $e',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ActivityShell(
      title: l10n.coloringTitle,
      child: BlocBuilder<ColoringCubit, ColoringState>(
        builder: (context, state) {
          final cubit = context.read<ColoringCubit>();
          final bg = _templateBg(state.template);

          return Column(
            children: [
              // Template chooser
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3EB),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(6, (i) {
                        return _TemplateChip(
                          label: _templateLabel(context, i),
                          emoji: _templateEmojis[i],
                          selected: state.template == i,
                          onTap: () => cubit.selectTemplate(i),
                        );
                      }),
                    ),
                  ),
                ),
              ),

              // Palette
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3EB),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (int i = 0; i < state.palette.length; i++)
                                _Swatch(
                                  color: state.palette[i],
                                  selected: state.currentColor.value ==
                                      state.palette[i].value,
                                  onTap: () =>
                                      cubit.selectColor(state.palette[i]),
                                  onLongPress: () async {
                                    final c = await showDialog<Color>(
                                      context: context,
                                      builder: (_) => _ColorPickerDialog(
                                        initial: state.palette[i],
                                      ),
                                    );
                                    if (c != null) {
                                      cubit.replacePaletteColor(i, c);
                                    }
                                  },
                                ),
                              _AddSwatch(
                                onTap: () async {
                                  final c = await showDialog<Color>(
                                    context: context,
                                    builder: (_) => _ColorPickerDialog(
                                      initial: state.currentColor,
                                    ),
                                  );
                                  if (c != null) {
                                    cubit.addNewColor(c);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.palette_rounded,
                        color: AppColors.accentPink,
                      ),
                    ],
                  ),
                ),
              ),

              // Tools
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Tool(icon: Icons.undo_rounded, onTap: cubit.undo),
                    const SizedBox(width: 12),
                    _Tool(icon: Icons.redo_rounded, onTap: cubit.redo),
                    const SizedBox(width: 12),
                    _Tool(
                      icon: Icons.cleaning_services_rounded,
                      onTap: cubit.clearCurrentTemplate,
                    ),
                    const SizedBox(width: 12),
                    _Tool(
                      icon: Icons.download_rounded,
                      onTap: () => _saveToGallery(bg),
                    ),
                  ],
                ),
              ),

              // Canvas
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      color: bg,
                      child: RepaintBoundary(
                        key: _repaintKey,
                        child: _ColoringCanvas(
                          template: state.template,
                          currentColor: state.currentColor,
                          history: state.history,
                          onFill: (idx, prev, next) =>
                              cubit.onFill(idx, prev, next),
                        ),
                      ),
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

class _TemplateChip extends StatelessWidget {
  final String label;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;
  const _TemplateChip({
    required this.label,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.white.withOpacity(.6),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  const _Swatch({
    required this.color,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          width: 46,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? Colors.white : Colors.black26,
              width: selected ? 3 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.12),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddSwatch extends StatelessWidget {
  final VoidCallback onTap;
  const _AddSwatch({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Ink(
          width: 46,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black26),
          ),
          child:
              const Icon(Icons.add, size: 20, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _Tool extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _Tool({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

/// ---------------- SVG-based canvas ----------------

class _Region {
  Path Function(Size) pathBuilder;
  Color color;
  _Region(this.pathBuilder, this.color);
}

class _ColoringCanvas extends StatefulWidget {
  final int template; // 0..5
  final Color currentColor;
  final List<ColoringFillAction> history;
  final void Function(int regionIndex, Color previous, Color next) onFill;

  const _ColoringCanvas({
    required this.template,
    required this.currentColor,
    required this.history,
    required this.onFill,
  });

  @override
  State<_ColoringCanvas> createState() => _ColoringCanvasState();
}

class _ColoringCanvasState extends State<_ColoringCanvas> {
  late List<_Region> _regions;
  SvgTemplate? _svgTemplate;
  String? _loadingError;

  static const _templateAssets = [
    'assets/coloring/space.svg',
    'assets/coloring/garden.svg',
    'assets/coloring/fish.svg',
    'assets/coloring/butterfly.svg',
    'assets/coloring/house.svg',
    'assets/coloring/mandala.svg',
  ];

  @override
  void initState() {
    super.initState();
    _loadTemplate();
  }

  @override
  void didUpdateWidget(covariant _ColoringCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.template != widget.template) {
      _loadTemplate();
    } else if (oldWidget.history != widget.history) {
      _rebuildRegions();
      setState(() {});
    }
  }

  Future<void> _loadTemplate() async {
    setState(() {
      _loadingError = null;
      _svgTemplate = null;
    });

    final assetPath = _templateAssets[widget.template];

    try {
      final tpl = await SvgTemplateCache.instance.load(assetPath);
      if (!mounted) return;

      _svgTemplate = tpl;
      _rebuildRegions();
      setState(() {});
    } catch (e, st) {
      // ignore: avoid_print
      print('Error loading SVG template $assetPath: $e\n$st');

      if (!mounted) return;
      setState(() {
        _loadingError = e.toString();
      });
    }
  }

  void _rebuildRegions() {
    if (_svgTemplate == null) return;
    final tpl = _svgTemplate!;

    final initial = <_Region>[];

    for (final path in tpl.paths) {
      initial.add(
        _Region(
          (size) => scaleSvgPath(path, size, tpl),
          Colors.transparent,
        ),
      );
    }

    for (final a in widget.history.where(
      (a) => a.template == widget.template,
    )) {
      if (a.regionIndex < 0 || a.regionIndex >= initial.length) continue;
      initial[a.regionIndex].color = a.next;
    }

    _regions = initial;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_loadingError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.coloringLoadError(_loadingError!),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (_svgTemplate == null) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return GestureDetector(
          onTapDown: (details) {
            final tapPos = details.localPosition;

            for (int i = _regions.length - 1; i >= 0; i--) {
              final region = _regions[i];
              final path = region.pathBuilder(size);
              if (path.contains(tapPos)) {
                final before = region.color;
                final after = widget.currentColor;
                if (before.value != after.value) {
                  widget.onFill(i, before, after);
                  setState(() {
                    _regions[i].color = after;
                  });
                }
                break;
              }
            }
          },
          child: CustomPaint(
            painter: _ScenePainter(_regions),
            size: size,
          ),
        );
      },
    );
  }
}

class _ScenePainter extends CustomPainter {
  final List<_Region> regions;
  _ScenePainter(this.regions);

  @override
  void paint(Canvas canvas, Size size) {
    for (final r in regions) {
      final path = r.pathBuilder(size);

      final fill = Paint()..color = r.color;
      canvas.drawPath(path, fill);

      final stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = Colors.black.withOpacity(.75)
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _ScenePainter oldDelegate) =>
      oldDelegate.regions != regions;
}

/// ---------- Color picker (no packages) ----------

class _ColorPickerDialog extends StatefulWidget {
  final Color initial;
  const _ColorPickerDialog({required this.initial});

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late double h;
  late double s;
  late double v;
  late double a;

  @override
  void initState() {
    super.initState();
    final hsv = HSVColor.fromColor(widget.initial);
    h = hsv.hue;
    s = hsv.saturation;
    v = hsv.value;
    a = widget.initial.opacity;
  }

  Color get color => HSVColor.fromAHSV(a, h, s, v).toColor();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      insetPadding: const EdgeInsets.all(18),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.coloringPickColorTitle,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _Preview(color: color),
            const SizedBox(height: 12),
            _LabeledSlider(
              label: l10n.coloringHue,
              value: h,
              min: 0,
              max: 360,
              onChanged: (x) => setState(() => h = x),
            ),
            _LabeledSlider(
              label: l10n.coloringSaturation,
              value: s,
              min: 0,
              max: 1,
              onChanged: (x) => setState(() => s = x),
            ),
            _LabeledSlider(
              label: l10n.coloringBrightness,
              value: v,
              min: 0,
              max: 1,
              onChanged: (x) => setState(() => v = x),
            ),
            _LabeledSlider(
              label: l10n.coloringOpacity,
              value: a,
              min: 0,
              max: 1,
              onChanged: (x) => setState(() => a = x),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text(l10n.cancel),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentPink,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(l10n.coloringUseColor),
                  onPressed: () => Navigator.pop(context, color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  final Color color;
  const _Preview({required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
    );
  }
}

class _LabeledSlider extends StatelessWidget {
  final String label;
  final double value, min, max;
  final ValueChanged<double> onChanged;
  const _LabeledSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 88, child: Text(label)),
        Expanded(
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
        SizedBox(
          width: 56,
          child: Text(
            value.toStringAsFixed(min == 0 && max == 360 ? 0 : 2),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

const _templateEmojis = ['🪐', '🌼', '🐟', '🦋', '🏠', '🌀'];

Color _templateBg(int t) {
  switch (t) {
    case 0:
      return const Color(0xFFE8F5E9);
    case 1:
      return const Color(0xFFE8F5E9);
    case 2:
      return const Color(0xFFE8F5E9);
    case 3:
      return const Color(0xFFE8F5E9);
    case 4:
      return const Color(0xFFE8F5E9);
    case 5:
      return const Color(0xFFE8F5E9);
    default:
      return Colors.white;
  }
}

String _templateLabel(BuildContext context, int index) {
  final l10n = AppLocalizations.of(context)!;
  switch (index) {
    case 0:
      return l10n.coloringTemplateSpace;
    case 1:
      return l10n.coloringTemplateGarden;
    case 2:
      return l10n.coloringTemplateFish;
    case 3:
      return l10n.coloringTemplateButterfly;
    case 4:
      return l10n.coloringTemplateHouse;
    case 5:
      return l10n.coloringTemplateMandala;
    default:
      return '';
  }
}
