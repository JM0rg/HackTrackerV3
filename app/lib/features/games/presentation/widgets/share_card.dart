import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/features/scoring/presentation/widgets/field_style.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// The line, and nothing else. Square, dark, ready to post.
class ShareCard extends StatelessWidget {
  const ShareCard({
    super.key,
    required this.eyebrow,
    required this.headline,
    required this.tags,
    required this.line,
    required this.who,
    required this.sub,
  });

  final String eyebrow;
  final String headline;
  final List<String> tags;
  final String line;
  final String who;
  final String sub;

  @override
  Widget build(BuildContext context) {
    final field = context.colors.field;
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: RadialGradient(
            center: const Alignment(0, -1),
            radius: 1.2,
            colors: [field.glow, field.bg],
            stops: const [0, 0.65],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              bottom: -40,
              child: Opacity(
                opacity: 0.16,
                child: CustomPaint(size: const Size(200, 200), painter: _DiamondPainter(field.accent)),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  style: context.text.labelSmall?.copyWith(
                    color: field.muted,
                    letterSpacing: 2.2,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    headline,
                    style: context.text.displaySmall?.copyWith(
                      color: field.on,
                      fontSize: 52,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -2.3,
                      height: 1,
                      fontFeatures: tabularFigures,
                    ),
                  ),
                ),
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    children: [
                      for (final t in tags)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: t == 'HR' ? field.accent : field.lineStrong,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            t,
                            style: context.text.labelSmall?.copyWith(
                              color: field.accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Text(line, style: context.text.bodyMedium?.copyWith(color: field.muted)),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(who, style: context.text.labelLarge?.copyWith(color: field.on)),
                          Text(sub, style: context.text.bodySmall?.copyWith(color: field.muted)),
                        ],
                      ),
                    ),
                    Text(
                      'HACKTRACKER',
                      style: context.text.labelSmall?.copyWith(
                        color: field.muted,
                        letterSpacing: 1.8,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DiamondPainter extends CustomPainter {
  _DiamondPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final path = Path()
      ..moveTo(w * .5, w * .92)
      ..lineTo(w * .88, w * .5)
      ..lineTo(w * .5, w * .08)
      ..lineTo(w * .12, w * .5)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_DiamondPainter old) => old.color != color;
}

/// Renders whatever sits under [boundaryKey] to a PNG and opens the share
/// sheet with it. The text rides along for apps that only take text.
Future<void> shareBoundaryAsImage(
  GlobalKey boundaryKey, {
  required String text,
  String fileName = 'hacktracker-line.png',
}) async {
  final object = boundaryKey.currentContext?.findRenderObject();
  if (object is! RenderRepaintBoundary) return;
  final image = await object.toImage(pixelRatio: 3);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  if (bytes == null) return;
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(bytes.buffer.asUint8List());
  await SharePlus.instance.share(
    ShareParams(files: [XFile(file.path)], text: text),
  );
}
