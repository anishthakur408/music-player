import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double opacity;
  final double blur;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const GlassCard({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.borderRadius = 20,
    this.onTap,
    this.backgroundColor,
    this.opacity = 0.25,
    this.blur = 20,
    this.border,
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        padding: padding ?? EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white.withOpacity(opacity),
          borderRadius: BorderRadius.circular(borderRadius),
          border: border ?? Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: boxShadow ?? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: blur,
              spreadRadius: 0,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class GlassButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? backgroundColor;
  final bool isPressed;

  const GlassButton({
    Key? key,
    required this.child,
    this.onTap,
    this.width,
    this.height,
    this.padding,
    this.borderRadius = 15,
    this.backgroundColor,
    this.isPressed = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        width: width,
        height: height,
        padding: padding ?? EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isPressed
              ? Colors.white.withOpacity(0.4)
              : backgroundColor ?? Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isPressed ? 0.05 : 0.1),
              blurRadius: isPressed ? 10 : 20,
              spreadRadius: 0,
              offset: Offset(0, isPressed ? 5 : 10),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const GradientBackground({
    Key? key,
    required this.child,
    this.colors,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: colors ?? [
            Color(0xFFE3F2FD), // Light blue
            Color(0xFFBBDEFB), // Medium blue
            Color(0xFF90CAF9), // Darker blue
          ],
        ),
      ),
      child: child,
    );
  }
}

class CircularGlassContainer extends StatelessWidget {
  final Widget child;
  final double size;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final List<BoxShadow>? boxShadow;

  const CircularGlassContainer({
    Key? key,
    required this.child,
    required this.size,
    this.backgroundColor,
    this.onTap,
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white.withOpacity(0.25),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: boxShadow ?? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 0,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}

class GlassListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? contentPadding;

  const GlassListTile({
    Key? key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.margin,
    this.contentPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: margin ?? EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        contentPadding: contentPadding ?? EdgeInsets.all(15),
      ),
    );
  }
}

class AppColors {
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color secondary = Color(0xFF1976D2);
  static const Color accent = Color(0xFF2196F3);

  static const Color backgroundLight = Color(0xFFE3F2FD);
  static const Color backgroundMedium = Color(0xFFBBDEFB);
  static const Color backgroundDark = Color(0xFF90CAF9);

  static const Color textPrimary = Color(0xFF1565C0);
  static const Color textSecondary = Color(0xFF1976D2);
  static const Color textMuted = Color(0x801976D2);

  static const Color glassBackground = Color(0x40FFFFFF);
  static const Color glassBorder = Color(0x4DFFFFFF);

  static const Color red = Color(0xFFE53935);
  static const Color orange = Color(0xFFFF9800);
  static const Color green = Color(0xFF4CAF50);
}