import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:las_app/core/theme/app_colors.dart'; 

class PortfolioFetchingOverlay extends StatefulWidget {
  const PortfolioFetchingOverlay({super.key});

  @override
  State<PortfolioFetchingOverlay> createState() =>
      _PortfolioFetchingOverlayState();
}

class _PortfolioFetchingOverlayState extends State<PortfolioFetchingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), 
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      decoration: const BoxDecoration(
        color: AppColors.white, 
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        children: [
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const Text(
                  'Almost there!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Fetching your Mutual Funds...',
                  textAlign: TextAlign.center, 
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.black, 
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24), 

          
          SizedBox(
            
            width: 240,
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [
                
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(240, 240), 
                      painter: _RupeeAnimationPainter(_controller.value),
                    );
                  },
                ),
                
                Container(
                  width: 60, 
                  height: 60,
                  decoration: const BoxDecoration(
                    color: AppColors.bPrimaryColor, 
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.flash_on, 
                    color: AppColors.white,
                    size: 35, 
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24), 
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: const Text(
              'Relax, this won\'t affect your CIBIL score.',
               textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.kIndicatorInactiveColor, 
              ),
            ),
          ),
          
        ],
      ),
    );
  }
}


class _RupeeAnimationPainter extends CustomPainter {
  final double animationValue;

  _RupeeAnimationPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    
    const double outerRadius = 110;
    const double middleRadius = 80;
    const double outerSymbolPathRadius = 95;
    const double innerSymbolPathRadius = 65;


    
    final outerPaint = Paint()
      ..color = AppColors.bPrimaryColor.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, outerRadius, outerPaint); 

    final middlePaint = Paint()
      ..color = AppColors.bPrimaryColor.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, middleRadius, middlePaint); 

    
    _drawRupeeSymbol(
      canvas,
      center,
      outerSymbolPathRadius, 
      animationValue * math.pi * 2,
      AppColors.bPrimaryColor,
    );
    _drawRupeeSymbol(
      canvas,
      center,
      innerSymbolPathRadius, 
      (animationValue + 0.5) * math.pi * 2,
      AppColors.bPrimaryColor,
    );
  }

  void _drawRupeeSymbol(
      Canvas canvas, Offset center, double radius, double angle, Color bgColor) {
    final x = center.dx + radius * math.cos(angle);
    final y = center.dy + radius * math.sin(angle);
    final symbolCenter = Offset(x, y);

    final backgroundPaint = Paint()..color = bgColor;
    canvas.drawCircle(symbolCenter, 15, backgroundPaint); 

    final textPainter = TextPainter(
      text: const TextSpan(
        text: '₹',
        style: TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas,
        symbolCenter - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _RupeeAnimationPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}