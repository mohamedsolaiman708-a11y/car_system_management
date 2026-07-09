import 'package:flutter/material.dart';
import 'package:car_system_management/src/core/utils/app_theme.dart';

class BrandLogo extends StatelessWidget {
  final double scale;
  const BrandLogo({super.key, this.scale = 0.75}); // تصغير المقياس الافتراضي

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // رسمة السيارة بحجم أدق
          CustomPaint(
            size: const Size(180, 40), 
            painter: LuxuryCarPainter(color: AppColors.accentGold),
          ),
          const SizedBox(height: 4),
          const Text(
            'AL SAMI',
            style: TextStyle(
              fontSize: 32, // تصغير إضافي
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 10,
              height: 1,
              fontFamily: 'Cairo',
            ),
          ),
          const Text(
            'AUTO ERP',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.accentGold,
              letterSpacing: 6,
            ),
          ),
          const SizedBox(height: 6),
          // الخط الذهبي الرفيع
          Container(
            width: 120,
            height: 0.8,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, AppColors.accentGold.withOpacity(0.5), Colors.transparent],
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'معرض السامي للسيارات',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w200,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class LuxuryCarPainter extends CustomPainter {
  final Color color;
  LuxuryCarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.15, size.height * 0.85);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.6,
        size.width * 0.45, size.height * 0.25);
    path.quadraticBezierTo(size.width * 0.65, size.height * 0.05,
        size.width * 0.85, size.height * 0.4);
    path.quadraticBezierTo(
        size.width * 0.95, size.height * 0.65, size.width * 0.98, size.height * 0.85);

    path.moveTo(size.width * 0.8, size.height * 0.35);
    path.lineTo(size.width * 0.9, size.height * 0.38);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
