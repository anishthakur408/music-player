import 'package:flutter/material.dart';
import 'dart:math' as math;

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;
  final StrokeCap strokeCap;

  CircularProgressPainter({
    required this.progress,
    this.backgroundColor = const Color(0x40FFFFFF),
    this.progressColor = const Color(0xFFE53935),
    this.strokeWidth = 8.0,
    this.strokeCap = StrokeCap.round,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2);

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = strokeCap;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = strokeCap;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is CircularProgressPainter &&
        oldDelegate.progress != progress;
  }
}

class RotatingDiscWidget extends StatefulWidget {
  final double size;
  final bool isRotating;
  final Widget child;
  final Color backgroundColor;
  final List<Widget>? decorativeElements;

  const RotatingDiscWidget({
    Key? key,
    required this.size,
    required this.isRotating,
    required this.child,
    this.backgroundColor = const Color(0xFF1565C0),
    this.decorativeElements,
  }) : super(key: key);

  @override
  _RotatingDiscWidgetState createState() => _RotatingDiscWidgetState();
}

class _RotatingDiscWidgetState extends State<RotatingDiscWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(RotatingDiscWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRotating && !oldWidget.isRotating) {
      _rotationController.repeat();
    } else if (!widget.isRotating && oldWidget.isRotating) {
      _rotationController.stop();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationController.value * 2 * math.pi,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Main content
                Center(
                  child: Container(
                    width: widget.size * 0.8,
                    height: widget.size * 0.8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Center(child: widget.child),
                  ),
                ),
                // Decorative elements
                if (widget.decorativeElements != null)
                  ...widget.decorativeElements!,
                // Default decorative dots if none provided
                if (widget.decorativeElements == null) ...[
                  Positioned(
                    top: widget.size * 0.2,
                    right: widget.size * 0.3,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: widget.size * 0.25,
                    left: widget.size * 0.35,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final Color color;
  final double strokeWidth;

  WaveformPainter({
    required this.waveformData,
    this.color = Colors.blue,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (waveformData.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final barWidth = size.width / waveformData.length;

    for (int i = 0; i < waveformData.length; i++) {
      final barHeight = waveformData[i] * size.height;
      final x = i * barWidth + barWidth / 2;

      canvas.drawLine(
        Offset(x, (size.height - barHeight) / 2),
        Offset(x, (size.height + barHeight) / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is WaveformPainter &&
        oldDelegate.waveformData != waveformData;
  }
}

class AnimatedProgressRing extends StatefulWidget {
  final double progress;
  final double size;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;
  final Duration animationDuration;

  const AnimatedProgressRing({
    Key? key,
    required this.progress,
    required this.size,
    this.backgroundColor = const Color(0x40FFFFFF),
    this.progressColor = const Color(0xFFE53935),
    this.strokeWidth = 8.0,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  _AnimatedProgressRingState createState() => _AnimatedProgressRingState();
}

class _AnimatedProgressRingState extends State<AnimatedProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _currentProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _currentProgress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        _currentProgress = _animation.value;
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: CircularProgressPainter(
            progress: _currentProgress,
            backgroundColor: widget.backgroundColor,
            progressColor: widget.progressColor,
            strokeWidth: widget.strokeWidth,
          ),
        );
      },
    );
  }
}