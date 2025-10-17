import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/app_theme.dart';

class ShimmerCard extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const ShimmerCard({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: OneSaveColors.surfaceVariant,
      highlightColor: OneSaveColors.surface,
      child: Container(
        width: width ?? double.infinity,
        height: height ?? 100,
        decoration: BoxDecoration(
          color: OneSaveColors.surfaceVariant,
          borderRadius: borderRadius ?? BorderRadius.circular(20),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .shimmer(duration: 1500.ms);
  }
}

class SkeletonList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsetsGeometry? padding;

  const SkeletonList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ShimmerCard(
            height: itemHeight,
            borderRadius: BorderRadius.circular(16),
          )
              .animate()
              .fadeIn(duration: 300.ms, delay: Duration(milliseconds: index * 100))
              .slideX(begin: -0.2, end: 0, duration: 400.ms, delay: Duration(milliseconds: index * 100)),
        );
      },
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingText;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingText,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: OneSaveColors.background.withOpacity(0.8),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(OneSaveColors.primary),
                    strokeWidth: 3,
                  )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        end: const Offset(1.0, 1.0),
                        duration: 300.ms,
                      ),
                  if (loadingText != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      loadingText!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: OneSaveColors.onBackground.withOpacity(0.7),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 300.ms, delay: 200.ms)
                        .slideY(begin: 0.2, end: 0, duration: 300.ms, delay: 200.ms),
                  ],
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 200.ms),
      ],
    );
  }
}

class AnimatedProgressIndicator extends StatefulWidget {
  final double progress;
  final Color? color;
  final double strokeWidth;
  final double size;

  const AnimatedProgressIndicator({
    super.key,
    required this.progress,
    this.color,
    this.strokeWidth = 4.0,
    this.size = 50.0,
  });

  @override
  State<AnimatedProgressIndicator> createState() => _AnimatedProgressIndicatorState();
}

class _AnimatedProgressIndicatorState extends State<AnimatedProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CircularProgressIndicator(
            value: _animation.value,
            strokeWidth: widget.strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.color ?? OneSaveColors.primary,
            ),
            backgroundColor: OneSaveColors.surfaceVariant,
          ),
        );
      },
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1.0, 1.0),
          duration: 300.ms,
        );
  }
}
