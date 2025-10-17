import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../theme/app_theme.dart';

class AnimatedCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool useGlassmorphism;
  final Duration animationDelay;
  final double? width;
  final double? height;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.useGlassmorphism = false,
    this.animationDelay = Duration.zero,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      width: width,
      height: height,
      margin: margin,
      child: useGlassmorphism
          ? GlassmorphicContainer(
              width: width ?? double.infinity,
              height: height ?? 200,
              borderRadius: 20,
              blur: 20,
              alignment: Alignment.bottomCenter,
              border: 2,
              linearGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: OneSaveColors.glassGradient,
              ),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  OneSaveColors.glassBorder,
                  OneSaveColors.glassBorder.withOpacity(0.1),
                ],
              ),
              child: Container(
                padding: padding ?? const EdgeInsets.all(16),
                child: child,
              ),
            )
          : Card(
              child: Container(
                padding: padding ?? const EdgeInsets.all(16),
                child: child,
              ),
            ),
    );

    if (onTap != null) {
      cardContent = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: cardContent,
      );
    }

    return cardContent
        .animate()
        .fadeIn(duration: 600.ms, delay: animationDelay)
        .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: animationDelay)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1.0, 1.0),
          duration: 600.ms,
          delay: animationDelay,
        );
  }
}

class AnimatedListCard extends StatelessWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final bool useGlassmorphism;

  const AnimatedListCard({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 100),
    this.useGlassmorphism = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        return AnimatedCard(
          useGlassmorphism: useGlassmorphism,
          animationDelay: staggerDelay * index,
          child: child,
        );
      }).toList(),
    );
  }
}
