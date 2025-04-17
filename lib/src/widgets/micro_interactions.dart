import 'package:flutter/material.dart';
import '../utils/animation_constants.dart';

/// A button with a ripple effect
class RippleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color? rippleColor;
  final BorderRadius? borderRadius;
  
  const RippleButton({
    Key? key,
    required this.child,
    required this.onTap,
    this.rippleColor,
    this.borderRadius,
  }) : super(key: key);
  
  @override
  State<RippleButton> createState() => _RippleButtonState();
}

class _RippleButtonState extends State<RippleButton> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationConstants.shortDuration,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AnimationConstants.standardCurve,
      ),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final rippleColor = widget.rippleColor ?? Theme.of(context).primaryColor.withOpacity(0.2);
    
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: ClipRRect(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              splashColor: rippleColor,
              highlightColor: rippleColor.withOpacity(0.5),
              borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// A widget that bounces when tapped
class BounceWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  
  const BounceWidget({
    Key? key,
    required this.child,
    this.onTap,
  }) : super(key: key);
  
  @override
  State<BounceWidget> createState() => _BounceWidgetState();
}

class _BounceWidgetState extends State<BounceWidget> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }
  
  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }
  
  void _onTapCancel() {
    _controller.reverse();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// A widget that pulses to draw attention
class PulseWidget extends StatefulWidget {
  final Widget child;
  final bool animate;
  final Duration duration;
  
  const PulseWidget({
    Key? key,
    required this.child,
    this.animate = true,
    this.duration = const Duration(milliseconds: 1500),
  }) : super(key: key);
  
  @override
  State<PulseWidget> createState() => _PulseWidgetState();
}

class _PulseWidgetState extends State<PulseWidget> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }
  
  @override
  void didUpdateWidget(PulseWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
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
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// A widget that shakes to indicate an error
class ShakeWidget extends StatefulWidget {
  final Widget child;
  final bool shake;
  final Axis direction;
  final double offset;
  final VoidCallback? onAnimationComplete;
  
  const ShakeWidget({
    Key? key,
    required this.child,
    this.shake = false,
    this.direction = Axis.horizontal,
    this.offset = 10.0,
    this.onAnimationComplete,
  }) : super(key: key);
  
  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticIn,
      ),
    );
    
    _controller.addStatusListener(_handleAnimationStatus);
  }
  
  @override
  void didUpdateWidget(ShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.shake && !oldWidget.shake) {
      _controller.forward(from: 0.0);
    }
  }
  
  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _controller.reset();
      widget.onAnimationComplete?.call();
    }
  }
  
  @override
  void dispose() {
    _controller.removeStatusListener(_handleAnimationStatus);
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final sineValue = sin(4 * 3.14159 * _animation.value);
        final offset = sineValue * widget.offset;
        
        return Transform.translate(
          offset: widget.direction == Axis.horizontal
              ? Offset(offset, 0)
              : Offset(0, offset),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
