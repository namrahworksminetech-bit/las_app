import 'dart:math';
import 'package:flutter/material.dart';

class FundFetchingOrbitAnimation extends StatefulWidget {
  const FundFetchingOrbitAnimation({super.key});

  @override
  State<FundFetchingOrbitAnimation> createState() => _FundAnimationState();
}

class _FundAnimationState extends State<FundFetchingOrbitAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12), // slow movement
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const size = 300.0;
    const center = Offset(size / 2, size / 2);

    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final angle = _controller.value * 2 * pi;

          return Stack(
            children: [
              /// 0️⃣ BACKGROUND PARTICLES
              ..._buildParticles(center),

              /// 1️⃣ DRAW INNER + OUTER CIRCLES
              Positioned(
                left: 0,
                top: 0,
                child: CustomPaint(
                  size: const Size(size, size),
                  painter: _CirclePainter(),
                ),
              ),

              /// 2️⃣ OUTER RING — 3 COINS — CLOCKWISE
              ..._buildOrbitCoins(
                count: 3,
                radius: 145,
                angle: angle * 0.8,        // clockwise
                center: center,
                asset: "assets/images/coin.png",
                size: 38,
              ),

              /// 3️⃣ INNER RING — 3 COINS — ANTI CLOCKWISE
              ..._buildOrbitCoins(
                count: 3,
                radius: 95,
                angle: -angle * 1.1,        // anti-clockwise
                center: center,
                asset: "assets/images/coin.png",
                size: 34,
              ),

              /// 4️⃣ CENTER LOGO
              Positioned(
                left: center.dx - 45,
                top: center.dy - 45,
                child: Image.asset(
                  "assets/images/logo_circle.png",
                  width: 90,
                  height: 90,
                ),
              ),
            ],
          );
        },
      ),
    );
  }


  // --------------------------------------------
  //        ORBITING COINS — PARAMETERIZED
  // --------------------------------------------


  List<Widget> _buildOrbitCoins({
    required int count,
    required double radius,
    required double angle,
    required Offset center,
    required String asset,
    required double size,
  }) {
    return List.generate(count, (i) {
      final step = (2 * pi / count) * i;
      final x = center.dx + radius * cos(angle + step);
      final y = center.dy + radius * sin(angle + step);

      return Positioned(
        left: x - size / 2,
        top: y - size / 2,
        child: Image.asset(asset, width: size, height: size),
      );
    });
  }

  // --------------------------------------------
  //       PULSING BACKGROUND PARTICLES
  // --------------------------------------------
  List<Widget> _buildParticles(Offset center) {
    final random = Random(30);

    return List.generate(12, (i) {
      final dx = random.nextInt(260) - 130;
      final dy = random.nextInt(260) - 130;

      final opacity = (sin((_controller.value * 2 * pi) + i) + 1) / 2;

      return Positioned(
        left: center.dx + dx,
        top: center.dy + dy,
        child: Opacity(
          opacity: opacity * 0.6,
          child: Container(
            width: random.nextInt(6) + 4,
            height: random.nextInt(6) + 4,
            decoration: const BoxDecoration(
              color: Color(0xFFFF7A00),
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    });
  }
}

//
// ------------------------------------------------------------
//      FIGMA-ACCURATE CIRCLE PAINTER (INNER + OUTER RINGS)
// ------------------------------------------------------------
//
class _CirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    const stroke = Color(0xFFFF7A00);
    final fillOuter = stroke.withOpacity(0.15);
    final fillInner = stroke.withOpacity(0.22);

    // OUTER filled circle
    canvas.drawCircle(center, 145, Paint()..color = fillOuter);

    // OUTER stroke
    canvas.drawCircle(
      center,
      145,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // INNER filled circle
    canvas.drawCircle(center, 95, Paint()..color = fillInner);

    // INNER stroke
    canvas.drawCircle(
      center,
      95,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
