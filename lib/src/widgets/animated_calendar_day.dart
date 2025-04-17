import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../utils/animation_constants.dart';

/// An animated calendar day cell for the table calendar
class AnimatedCalendarDay extends StatelessWidget {
  final DateTime day;
  final DateTime focusedDay;
  final bool isSelected;
  final bool isToday;
  final bool isOutside;
  final bool isHoliday;
  final bool isWeekend;
  final List<dynamic>? events;
  final CalendarBuilders calendarBuilders;
  final BoxDecoration? defaultDecoration;
  final BoxDecoration? selectedDecoration;
  final BoxDecoration? todayDecoration;
  final BoxDecoration? holidayDecoration;
  final BoxDecoration? outsideDecoration;
  final BoxDecoration? weekendDecoration;
  final BoxDecoration? rangeStartDecoration;
  final BoxDecoration? rangeEndDecoration;
  final BoxDecoration? withinRangeDecoration;
  final BoxDecoration? defaultTextStyle;
  final BoxDecoration? selectedTextStyle;
  final BoxDecoration? todayTextStyle;
  final BoxDecoration? holidayTextStyle;
  final BoxDecoration? outsideTextStyle;
  final BoxDecoration? weekendTextStyle;
  final BoxDecoration? rangeStartTextStyle;
  final BoxDecoration? rangeEndTextStyle;
  final BoxDecoration? withinRangeTextStyle;
  final bool isTodayHighlighted;
  final bool isRangeStart;
  final bool isRangeEnd;
  final bool isWithinRange;
  final bool isEventDay;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Function(bool)? onHover;
  
  const AnimatedCalendarDay({
    Key? key,
    required this.day,
    required this.focusedDay,
    required this.isSelected,
    required this.isToday,
    required this.isOutside,
    required this.isHoliday,
    required this.isWeekend,
    this.events,
    required this.calendarBuilders,
    this.defaultDecoration,
    this.selectedDecoration,
    this.todayDecoration,
    this.holidayDecoration,
    this.outsideDecoration,
    this.weekendDecoration,
    this.rangeStartDecoration,
    this.rangeEndDecoration,
    this.withinRangeDecoration,
    this.defaultTextStyle,
    this.selectedTextStyle,
    this.todayTextStyle,
    this.holidayTextStyle,
    this.outsideTextStyle,
    this.weekendTextStyle,
    this.rangeStartTextStyle,
    this.rangeEndTextStyle,
    this.withinRangeTextStyle,
    required this.isTodayHighlighted,
    required this.isRangeStart,
    required this.isRangeEnd,
    required this.isWithinRange,
    required this.isEventDay,
    this.onTap,
    this.onLongPress,
    this.onHover,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    
    final dayWidget = calendarBuilders.prioritizedBuilder?.call(
      context,
      day,
      focusedDay,
    );
    
    if (dayWidget != null) {
      children.add(dayWidget);
    } else {
      Widget? dayWidget;
      
      if (isSelected && calendarBuilders.selectedBuilder != null) {
        dayWidget = calendarBuilders.selectedBuilder!(
          context,
          day,
          focusedDay,
        );
      } else if (isTodayHighlighted && isToday && calendarBuilders.todayBuilder != null) {
        dayWidget = calendarBuilders.todayBuilder!(
          context,
          day,
          focusedDay,
        );
      } else if (isRangeStart && calendarBuilders.rangeStartBuilder != null) {
        dayWidget = calendarBuilders.rangeStartBuilder!(
          context,
          day,
          focusedDay,
        );
      } else if (isRangeEnd && calendarBuilders.rangeEndBuilder != null) {
        dayWidget = calendarBuilders.rangeEndBuilder!(
          context,
          day,
          focusedDay,
        );
      } else if (isWithinRange && calendarBuilders.withinRangeBuilder != null) {
        dayWidget = calendarBuilders.withinRangeBuilder!(
          context,
          day,
          focusedDay,
        );
      } else if (isHoliday && calendarBuilders.holidayBuilder != null) {
        dayWidget = calendarBuilders.holidayBuilder!(
          context,
          day,
          focusedDay,
        );
      } else if (isOutside && calendarBuilders.outsideBuilder != null) {
        dayWidget = calendarBuilders.outsideBuilder!(
          context,
          day,
          focusedDay,
        );
      } else if (isWeekend && calendarBuilders.weekendBuilder != null) {
        dayWidget = calendarBuilders.weekendBuilder!(
          context,
          day,
          focusedDay,
        );
      } else if (calendarBuilders.defaultBuilder != null) {
        dayWidget = calendarBuilders.defaultBuilder!(
          context,
          day,
          focusedDay,
        );
      } else {
        dayWidget = _DefaultCalendarDayWidget(
          text: day.day.toString(),
          isSelected: isSelected,
          isToday: isToday,
          isOutside: isOutside,
          isEventDay: isEventDay,
        );
      }
      
      children.add(dayWidget);
    }
    
    if (events != null && events!.isNotEmpty && calendarBuilders.markerBuilder != null) {
      final markerWidget = calendarBuilders.markerBuilder!(
        context,
        day,
        events!,
      );
      
      if (markerWidget != null) {
        children.add(markerWidget);
      }
    }
    
    return AnimatedContainer(
      duration: AnimationConstants.mediumDuration,
      curve: AnimationConstants.standardCurve,
      decoration: _getDecoration(),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        onHover: onHover != null ? (value) => onHover!(value) : null,
        child: Stack(
          alignment: Alignment.center,
          children: children,
        ),
      ),
    );
  }
  
  BoxDecoration? _getDecoration() {
    if (isSelected) {
      return selectedDecoration;
    } else if (isTodayHighlighted && isToday) {
      return todayDecoration;
    } else if (isRangeStart) {
      return rangeStartDecoration;
    } else if (isRangeEnd) {
      return rangeEndDecoration;
    } else if (isWithinRange) {
      return withinRangeDecoration;
    } else if (isHoliday) {
      return holidayDecoration;
    } else if (isOutside) {
      return outsideDecoration;
    } else if (isWeekend) {
      return weekendDecoration;
    } else {
      return defaultDecoration;
    }
  }
}

/// Default calendar day widget with animations
class _DefaultCalendarDayWidget extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isToday;
  final bool isOutside;
  final bool isEventDay;
  
  const _DefaultCalendarDayWidget({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.isToday,
    required this.isOutside,
    required this.isEventDay,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedContainer(
      duration: AnimationConstants.mediumDuration,
      curve: AnimationConstants.standardCurve,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected
            ? theme.primaryColor
            : isToday
                ? theme.primaryColor.withOpacity(0.3)
                : Colors.transparent,
      ),
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: AnimationConstants.mediumDuration,
          curve: AnimationConstants.standardCurve,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : isToday
                    ? theme.primaryColor
                    : isOutside
                        ? Colors.grey
                        : theme.colorScheme.onSurface,
            fontSize: isSelected || isToday ? 16 : 14,
            fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
          ),
          child: Text(text),
        ),
      ),
    );
  }
}
