import 'package:flutter/cupertino.dart';
import 'package:wedding_reservation_app/utils/colors.dart';

class ButtonNotch extends CustomPainter {
  final bool isDark;
  
  ButtonNotch({required this.isDark});
  
  @override
  void paint(Canvas canvas, Size size) {
    var centerX = size.width / 2;
    var lineY = 2.0;
    
    // Draw smooth gradient rays using a path with gradient shader
    var rayPath = Path();
    rayPath.moveTo(centerX - 15, lineY);
    rayPath.lineTo(centerX - 25, lineY + 30);
    rayPath.lineTo(centerX + 25, lineY + 30);
    rayPath.lineTo(centerX + 15, lineY);
    rayPath.close();

    // Create gradient shader for the glow effect
    var rayPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          (isDark ? AppColors.primary : AppColors.primaryLight).withOpacity(0.3),
          (isDark ? AppColors.primary : AppColors.primaryLight).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(centerX - 25, lineY, 50, 30))
      ..style = PaintingStyle.fill;

    canvas.drawPath(rayPath, rayPaint);

    // Draw the main horizontal line at the top
    var linePaint = Paint()
      ..color = isDark ? AppColors.primary : AppColors.primaryLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    var startPoint = Offset(centerX - 15, lineY);
    var endPoint = Offset(centerX + 15, lineY);
    canvas.drawLine(startPoint, endPoint, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}