import 'dart:ui';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_drawing/path_drawing.dart';
import 'package:xml/xml.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

/// Holds the original SVG paths and their combined bounds.
class SvgTemplate {
  final List<Path> paths;
  final Rect bounds;

  SvgTemplate({
    required this.paths,
    required this.bounds,
  });
}

/// Simple in-memory cache so each asset SVG is only parsed once.
class SvgTemplateCache {
  SvgTemplateCache._();
  static final SvgTemplateCache instance = SvgTemplateCache._();

  final Map<String, SvgTemplate> _cache = {};

  Future<SvgTemplate> load(String assetPath) async {
    if (_cache.containsKey(assetPath)) return _cache[assetPath]!;

    // Load file as string
    final svgString = await rootBundle.loadString(assetPath);

    // Parse XML
    final document = XmlDocument.parse(svgString);
    final svg = document.rootElement;

    final paths = <Path>[];

    // Walk all descendants, pick <path> elements
    for (final node in svg.descendants.whereType<XmlElement>()) {
      if (node.name.local != 'path') continue;
      final d = node.getAttribute('d');
      if (d == null || d.trim().isEmpty) continue;

      final path = parseSvgPathData(d);
      paths.add(path);
    }

    // Compute combined bounds of all paths (real drawing area)
    Rect bounds;
    if (paths.isEmpty) {
      bounds = Rect.zero;
    } else {
      final combined = Path();
      for (final p in paths) {
        combined.addPath(p, Offset.zero);
      }
      bounds = combined.getBounds();
    }

    final tpl = SvgTemplate(
      paths: paths,
      bounds: bounds,
    );

    _cache[assetPath] = tpl;
    return tpl;
  }
}

/// Scale + center an original SVG path to fit [size] using the real bounds.
Path scaleSvgPath(Path original, Size size, SvgTemplate tpl) {
  // 1) Move the drawing so bounds start at (0,0)
  final Rect b = tpl.bounds;
  Path p = original.shift(-b.topLeft);

  if (b.width == 0 || b.height == 0) {
    return p;
  }

  // 2) Compute uniform scale
  final scaleX = size.width / b.width;
  final scaleY = size.height / b.height;
  final scale = scaleX < scaleY ? scaleX : scaleY;

  // 3) Apply vertical flip (mirror)
  //    Then scale normally.
  final matrix = vm.Matrix4.identity()
    ..scale(1.0, -1.0, 1.0)        // flip vertically
    ..scale(scale, scale, 1.0);    // apply uniform scaling

  p = p.transform(matrix.storage);

  // 4) After flipping, the drawing is upside down at negative Y.
  //    Move it back down by its height * scale.
  final flippedHeight = b.height * scale;

  p = p.shift(Offset(
    (size.width - b.width * scale) / 2,
    (size.height - flippedHeight) / 2 + flippedHeight,
  ));

  return p;
}