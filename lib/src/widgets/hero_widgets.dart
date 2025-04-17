import 'package:flutter/material.dart';

/// A hero widget for staff avatars
class StaffAvatarHero extends StatelessWidget {
  final String staffId;
  final String staffName;
  final double radius;
  final Color? backgroundColor;
  
  const StaffAvatarHero({
    Key? key,
    required this.staffId,
    required this.staffName,
    this.radius = 40,
    this.backgroundColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Theme.of(context).primaryColor;
    final initial = staffName.isNotEmpty ? staffName.substring(0, 1).toUpperCase() : '?';
    
    return Hero(
      tag: 'staff-avatar-$staffId',
      child: CircleAvatar(
        radius: radius,
        backgroundColor: bgColor,
        child: Text(
          initial,
          style: TextStyle(
            fontSize: radius * 0.8,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// A hero widget for staff names
class StaffNameHero extends StatelessWidget {
  final String staffId;
  final String staffName;
  final TextStyle? style;
  
  const StaffNameHero({
    Key? key,
    required this.staffId,
    required this.staffName,
    this.style,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final defaultStyle = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).textTheme.bodyLarge?.color,
    );
    
    return Hero(
      tag: 'staff-name-$staffId',
      child: Material(
        color: Colors.transparent,
        child: Text(
          staffName,
          style: style ?? defaultStyle,
        ),
      ),
    );
  }
}

/// A hero widget for time slot cards
class TimeSlotCardHero extends StatelessWidget {
  final String timeSlotId;
  final Widget child;
  
  const TimeSlotCardHero({
    Key? key,
    required this.timeSlotId,
    required this.child,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'time-slot-$timeSlotId',
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
    );
  }
}

/// A hero widget for calendar day cells
class CalendarDayHero extends StatelessWidget {
  final String date;
  final Widget child;
  
  const CalendarDayHero({
    Key? key,
    required this.date,
    required this.child,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'calendar-day-$date',
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
    );
  }
}
