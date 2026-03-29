import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:autism_app/core/theme/app_theme.dart';

/// Wraps any page with an animated galaxy/aurora background.
class GalaxyBackground extends StatefulWidget {
  final Widget child;
  final bool isDark;

  const GalaxyBackground(
      {super.key, required this.child, required this.isDark});

  @override
  State<GalaxyBackground> createState() => _GalaxyBackgroundState();
}

class _GalaxyBackgroundState extends State<GalaxyBackground>
    with TickerProviderStateMixin {
  late final AnimationController _twinkle;
  late final AnimationController _drift;

  @override
  void initState() {
    super.initState();
    _twinkle = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _drift = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _twinkle.dispose();
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base gradient
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: GalaxyColors.nebulaGradient(widget.isDark),
              stops: const [0.0, 0.35, 0.65, 1.0],
            ),
          ),
        ),

        // Nebula blobs / aurora clouds
        AnimatedBuilder(
          animation: _drift,
          builder: (context, _) => CustomPaint(
            painter: _NebulaPainter(
              progress: _drift.value,
              isDark: widget.isDark,
            ),
          ),
        ),

        // Star field (dark only) / sparkle dots (light)
        AnimatedBuilder(
          animation: _twinkle,
          builder: (context, _) => CustomPaint(
            painter: _StarFieldPainter(
              twinkle: _twinkle.value,
              isDark: widget.isDark,
            ),
          ),
        ),

        // Content on top
        widget.child,
      ],
    );
  }
}

// ─── Nebula / Aurora cloud painter ──────────────────────────────────────────

class _NebulaPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _NebulaPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);

    // Define nebula orbs: [relX, relY, relRadius, colorIndex, baseOpacity]
    final orbs = isDark
        ? const [
            [0.15, 0.20, 0.40, 0, 0.18],
            [0.80, 0.10, 0.35, 1, 0.14],
            [0.50, 0.55, 0.50, 2, 0.12],
            [0.10, 0.75, 0.30, 3, 0.16],
            [0.90, 0.70, 0.38, 0, 0.10],
          ]
        : const [
            [0.15, 0.20, 0.45, 4, 0.30],
            [0.80, 0.10, 0.40, 5, 0.25],
            [0.55, 0.60, 0.55, 6, 0.20],
            [0.05, 0.80, 0.35, 4, 0.28],
            [0.92, 0.65, 0.42, 5, 0.22],
          ];

    final darkOrbColors = [
      const Color(0xFF4C1D95),
      const Color(0xFF1E3A8A),
      const Color(0xFF701A75),
      const Color(0xFF064E3B),
      const Color(0xFF7C3AED),
    ];
    final lightOrbColors = [
      const Color(0xFFDDD6FE),
      const Color(0xFFBFDBFE),
      const Color(0xFFA7F3D0),
      const Color(0xFFFCE7F3),
      const Color(0xFFFEF3C7),
      const Color(0xFFE0E7FF),
      const Color(0xFFCFFAFE),
    ];

    final colors = isDark ? darkOrbColors : lightOrbColors;

    for (int i = 0; i < orbs.length; i++) {
      final orb = orbs[i];
      final drift = math.sin((progress + i * 0.3) * math.pi) * 0.04;
      final cx = (orb[0] as num).toDouble() * size.width + drift * size.width;
      final cy = (orb[1] as num).toDouble() * size.height +
          math.cos((progress + i * 0.2) * math.pi) * 0.03 * size.height;
      final r = (orb[2] as num).toDouble() * size.width;
      final colorIdx = (orb[3] as num).toInt() % colors.length;
      final opacity = (orb[4] as num).toDouble();

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            colors[colorIdx].withOpacity(opacity),
            colors[colorIdx].withOpacity(0),
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));

      canvas.drawCircle(Offset(cx, cy), r, paint);
    }
  }

  @override
  bool shouldRepaint(_NebulaPainter old) =>
      old.progress != progress || old.isDark != isDark;
}

// ─── Star field / sparkle painter ───────────────────────────────────────────

class _StarFieldPainter extends CustomPainter {
  final double twinkle;
  final bool isDark;

  _StarFieldPainter({required this.twinkle, required this.isDark});

  // Pre-generate stable star positions
  static final _stars = _generateStars();

  static List<_Star> _generateStars() {
    final rng = math.Random(1337);
    return List.generate(isDarkStars ? 120 : 40, (i) {
      return _Star(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        size: rng.nextDouble() * 2.5 + 0.5,
        phase: rng.nextDouble(),
        colorIdx: rng.nextInt(GalaxyColors.starColors.length),
      );
    });
  }

  static bool isDarkStars = true; // will be updated

  @override
  void paint(Canvas canvas, Size size) {
    if (!isDark && twinkle < 0.3) return; // fewer sparkles in light mode

    final count = isDark ? 120 : 30;
    final rng = math.Random(1337);

    for (int i = 0; i < count; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final sz = rng.nextDouble() * 2.2 + 0.4;
      final phase = rng.nextDouble();
      final colorIdx = rng.nextInt(GalaxyColors.starColors.length);

      final flickerVal = math.sin((twinkle + phase) * math.pi);
      final opacity = isDark
          ? (0.3 + flickerVal.abs() * 0.7)
          : (0.15 + flickerVal.abs() * 0.35);

      final paint = Paint()
        ..color = GalaxyColors.starColors[colorIdx]
            .withOpacity(opacity.clamp(0.0, 1.0))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, sz * 0.8);

      canvas.drawCircle(Offset(x, y), sz, paint);

      // Cross sparkle on brighter stars in dark mode
      if (isDark && sz > 1.8 && opacity > 0.7) {
        final sparklePaint = Paint()
          ..color = Colors.white.withOpacity(opacity * 0.5)
          ..strokeWidth = 0.5
          ..style = PaintingStyle.stroke;
        final half = sz * 3;
        canvas.drawLine(Offset(x - half, y), Offset(x + half, y), sparklePaint);
        canvas.drawLine(Offset(x, y - half), Offset(x, y + half), sparklePaint);
      }
    }
  }

  @override
  bool shouldRepaint(_StarFieldPainter old) =>
      old.twinkle != twinkle || old.isDark != isDark;
}

class _Star {
  final double x, y, size, phase;
  final int colorIdx;
  const _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.phase,
    required this.colorIdx,
  });
}
