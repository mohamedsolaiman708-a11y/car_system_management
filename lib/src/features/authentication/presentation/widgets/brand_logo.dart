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
          // رسمة السيارة الفاخرة (المنحنى الذهبي)
          CustomPaint(
            size: const Size(200, 50),
            painter: LuxuryCarPainter(color: AppColors.accentGold),
          ),
          const SizedBox(height: 8),
          const Text(
            'AL SAMI',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 8,
              height: 1,
              fontFamily: 'Cairo',
            ),
          ),
          const Text(
            'AUTO ERP',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.accentGold,
              letterSpacing: 6,
            ),
          ),
          const SizedBox(height: 10),
          // الخط التزييني الذهبي
          Container(
            width: 140,
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent, 
                  AppColors.accentGold.withOpacity(0.6), 
                  Colors.transparent
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'معرض السامي للسيارات',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.w300,
              letterSpacing: 1,
              fontFamily: 'Cairo',
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
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // رسم منحنى السيارة الانسيابي (Windshield -> Roof -> Spoiler)
    path.moveTo(size.width * 0.1, size.height * 0.85);
    
    // المقدمة والزجاج الأمامي
    path.quadraticBezierTo(
      size.width * 0.25, size.height * 0.65, 
      size.width * 0.45, size.height * 0.35
    );
    
    // السقف
    path.quadraticBezierTo(
      size.width * 0.65, size.height * 0.15, 
      size.width * 0.85, size.height * 0.4
    );
    
    // الخلفية والجناح (Spoiler)
    path.lineTo(size.width * 0.95, size.height * 0.45);
    path.quadraticBezierTo(
      size.width * 0.9, size.height * 0.55,
      size.width * 0.98, size.height * 0.85
    );

    // خط إضافي للإضاءة (Highlight line)
    path.moveTo(size.width * 0.75, size.height * 0.35);
    path.lineTo(size.width * 0.88, size.height * 0.38);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
