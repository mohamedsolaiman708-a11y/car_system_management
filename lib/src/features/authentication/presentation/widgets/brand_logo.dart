import 'package:flutter/material.dart';
import 'package:car_system_management/src/core/utils/app_theme.dart';

class BrandLogo extends StatelessWidget {
  final double scale;
  const BrandLogo({super.key, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // رسمة السيارة الانسيابية (Custom Silhouette)
          CustomPaint(
            size: const Size(280, 80),
            painter: LuxuryCarPainter(color: AppColors.accentGold),
          ),
          const SizedBox(height: 12),
          // اسم المعرض بخط ضخم ومتباعد للفخامة
          const Text(
            'AL SAMI',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 12,
              height: 1,
              fontFamily: 'Cairo',
            ),
          ),
          const Text(
            'AUTO ERP',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.accentGold,
              letterSpacing: 8,
            ),
          ),
          const SizedBox(height: 16),
          // الخط السفلي الرفيع
          Container(
            width: 200,
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.accentGold.withOpacity(0.5),
                  Colors.transparent
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'معرض السامي للسيارات',
            style: TextStyle(
              fontSize: 22,
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
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    // رسم السقف الانسيابي
    path.moveTo(size.width * 0.15, size.height * 0.75);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.65,
        size.width * 0.45, size.height * 0.35);
    path.quadraticBezierTo(size.width * 0.65, size.height * 0.15,
        size.width * 0.85, size.height * 0.45);
    path.quadraticBezierTo(
        size.width * 0.95, size.height * 0.6, size.width * 0.98, size.height * 0.75);

    // رسم الخط الجانبي الصغير (الجناح الخلفي)
    path.moveTo(size.width * 0.82, size.height * 0.4);
    path.lineTo(size.width * 0.92, size.height * 0.42);

    canvas.drawPath(path, paint);

    final linePaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(size.width * 0.3, size.height * 0.8),
        Offset(size.width * 0.7, size.height * 0.8), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
