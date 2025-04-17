import 'package:flutter/material.dart';
import '../utils/animation_constants.dart';

/// An animated card that expands when tapped
class ExpandableCard extends StatefulWidget {
  final Widget title;
  final Widget content;
  final bool initiallyExpanded;
  final Color? backgroundColor;
  final Color? expandedBackgroundColor;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  
  const ExpandableCard({
    Key? key,
    required this.title,
    required this.content,
    this.initiallyExpanded = false,
    this.backgroundColor,
    this.expandedBackgroundColor,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  }) : super(key: key);
  
  @override
  State<ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightFactor;
  late Animation<double> _iconRotation;
  late Animation<Color?> _colorAnimation;
  bool _isExpanded = false;
  
  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    
    _controller = AnimationController(
      vsync: this,
      duration: AnimationConstants.mediumDuration,
    );
    
    _heightFactor = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AnimationConstants.standardCurve,
      ),
    );
    
    _iconRotation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AnimationConstants.standardCurve,
      ),
    );
    
    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }
  
  @override
  void didUpdateWidget(ExpandableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.initiallyExpanded != oldWidget.initiallyExpanded) {
      setState(() {
        _isExpanded = widget.initiallyExpanded;
        if (_isExpanded) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      });
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.backgroundColor ?? theme.cardColor;
    final expandedBackgroundColor = widget.expandedBackgroundColor ?? theme.primaryColor.withOpacity(0.1);
    
    _colorAnimation = ColorTween(
      begin: backgroundColor,
      end: expandedBackgroundColor,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AnimationConstants.standardCurve,
      ),
    );
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Card(
          color: _colorAnimation.value,
          shape: RoundedRectangleBorder(
            borderRadius: widget.borderRadius,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: _toggleExpanded,
                borderRadius: BorderRadius.vertical(
                  top: widget.borderRadius.topLeft,
                  bottom: _isExpanded ? Radius.zero : widget.borderRadius.bottomLeft,
                ),
                child: Padding(
                  padding: widget.padding,
                  child: Row(
                    children: [
                      Expanded(child: widget.title),
                      RotationTransition(
                        turns: _iconRotation,
                        child: const Icon(Icons.keyboard_arrow_down),
                      ),
                    ],
                  ),
                ),
              ),
              ClipRect(
                child: Align(
                  heightFactor: _heightFactor.value,
                  child: Padding(
                    padding: widget.padding.copyWith(top: 0),
                    child: widget.content,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// An animated FAB that expands to show multiple options
class ExpandableFab extends StatefulWidget {
  final List<Widget> children;
  final Widget icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double distance;
  
  const ExpandableFab({
    Key? key,
    required this.children,
    this.icon = const Icon(Icons.add),
    this.backgroundColor,
    this.foregroundColor,
    this.distance = 100,
  }) : super(key: key);
  
  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isOpen = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationConstants.mediumDuration,
    );
    
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: AnimationConstants.standardCurve,
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }
  
  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 56,
      height: 56,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          child: InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.close,
                color: widget.foregroundColor ?? Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    final step = 90.0 / (count - 1);
    
    for (var i = 0; i < count; i++) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: 90 - (step * i),
          maxDistance: widget.distance,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    
    return children;
  }
  
  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _isOpen,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _isOpen ? 0.7 : 1.0,
          _isOpen ? 0.7 : 1.0,
          1.0,
        ),
        duration: AnimationConstants.mediumDuration,
        curve: AnimationConstants.standardCurve,
        child: AnimatedOpacity(
          opacity: _isOpen ? 0.0 : 1.0,
          duration: AnimationConstants.mediumDuration,
          curve: AnimationConstants.standardCurve,
          child: FloatingActionButton(
            onPressed: _toggle,
            backgroundColor: widget.backgroundColor,
            foregroundColor: widget.foregroundColor,
            child: widget.icon,
          ),
        ),
      ),
    );
  }
}

class _ExpandingActionButton extends StatelessWidget {
  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;
  
  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (3.14159 / 180),
          progress.value * maxDistance,
        );
        
        return Positioned(
          right: 4 + offset.dx,
          bottom: 4 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * 3.14159 / 2,
            child: Transform.scale(
              scale: progress.value,
              child: child,
            ),
          ),
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}

/// An animated badge that shows a count with a bounce animation
class AnimatedBadge extends StatefulWidget {
  final int count;
  final Color? backgroundColor;
  final Color? textColor;
  final double size;
  
  const AnimatedBadge({
    Key? key,
    required this.count,
    this.backgroundColor,
    this.textColor,
    this.size = 24,
  }) : super(key: key);
  
  @override
  State<AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<AnimatedBadge> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _previousCount = 0;
  
  @override
  void initState() {
    super.initState();
    _previousCount = widget.count;
    
    _controller = AnimationController(
      vsync: this,
      duration: AnimationConstants.shortDuration,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AnimationConstants.bounceCurve,
      ),
    );
  }
  
  @override
  void didUpdateWidget(AnimatedBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.count != oldWidget.count) {
      _previousCount = oldWidget.count;
      _controller.forward(from: 0.0);
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.backgroundColor ?? theme.primaryColor;
    final textColor = widget.textColor ?? Colors.white;
    
    if (widget.count == 0) {
      return const SizedBox.shrink();
    }
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                widget.count.toString(),
                style: TextStyle(
                  color: textColor,
                  fontSize: widget.size * 0.6,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
