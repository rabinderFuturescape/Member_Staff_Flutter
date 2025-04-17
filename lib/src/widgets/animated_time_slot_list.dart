import 'package:flutter/material.dart';
import '../models/schedule.dart';
import '../utils/animation_constants.dart';
import 'loading_animations.dart';

/// An animated list of time slots
class AnimatedTimeSlotList extends StatefulWidget {
  final List<TimeSlot> timeSlots;
  final Function(TimeSlot)? onTimeSlotTap;
  final bool isLoading;
  
  const AnimatedTimeSlotList({
    Key? key,
    required this.timeSlots,
    this.onTimeSlotTap,
    this.isLoading = false,
  }) : super(key: key);
  
  @override
  State<AnimatedTimeSlotList> createState() => _AnimatedTimeSlotListState();
}

class _AnimatedTimeSlotListState extends State<AnimatedTimeSlotList> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AnimationConstants.longDuration,
    );
    
    // Start the animation when the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  void didUpdateWidget(AnimatedTimeSlotList oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // If the time slots changed, restart the animation
    if (widget.timeSlots != oldWidget.timeSlots) {
      _animationController.reset();
      _animationController.forward();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return _buildLoadingList();
    }
    
    if (widget.timeSlots.isEmpty) {
      return _buildEmptyState();
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.timeSlots.length,
      itemBuilder: (context, index) {
        final timeSlot = widget.timeSlots[index];
        
        // Calculate the delay based on the index
        final delay = index * AnimationConstants.staggerInterval;
        
        // Create a delayed animation for this item
        final animation = CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            delay, delay + 0.5,
            curve: AnimationConstants.entranceCurve,
          ),
        );
        
        return AnimatedTimeSlotItem(
          timeSlot: timeSlot,
          animation: animation,
          onTap: widget.onTimeSlotTap != null 
              ? () => widget.onTimeSlotTap!(timeSlot) 
              : null,
        );
      },
    );
  }
  
  Widget _buildLoadingList() {
    return Column(
      children: List.generate(
        5,
        (index) => const TimeSlotSkeleton(),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return AnimatedOpacity(
      opacity: _animationController.value,
      duration: AnimationConstants.mediumDuration,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_busy,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No time slots for this date',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// An animated time slot item
class AnimatedTimeSlotItem extends StatelessWidget {
  final TimeSlot timeSlot;
  final Animation<double> animation;
  final VoidCallback? onTap;
  
  const AnimatedTimeSlotItem({
    Key? key,
    required this.timeSlot,
    required this.animation,
    this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Create slide and fade animations
    final slideAnimation = Tween<Offset>(
      begin: AnimationConstants.slideInRightOffset,
      end: Offset.zero,
    ).animate(animation);
    
    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(animation);
    
    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 50,
                    decoration: BoxDecoration(
                      color: timeSlot.isBooked ? Colors.red : Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          timeSlot.formattedTimeRange,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeSlot.formattedDate,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
