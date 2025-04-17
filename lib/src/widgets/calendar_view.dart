import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/schedule.dart';
import '../utils/animation_constants.dart';
import '../widgets/animated_calendar_day.dart';
import '../widgets/animated_time_slot_list.dart';
import '../widgets/micro_interactions.dart';

/// A calendar widget for displaying and managing staff schedules.
class CalendarView extends StatefulWidget {
  final Schedule? schedule;
  final Function(DateTime) onDaySelected;
  final Function(TimeSlot)? onTimeSlotTap;
  final DateTime selectedDay;

  const CalendarView({
    Key? key,
    required this.schedule,
    required this.onDaySelected,
    this.onTimeSlotTap,
    required this.selectedDay,
  }) : super(key: key);

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> with SingleTickerProviderStateMixin {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = widget.selectedDay;
    _selectedDay = widget.selectedDay;

    // Initialize animation controllers
    _animationController = AnimationController(
      vsync: this,
      duration: AnimationConstants.mediumDuration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: AnimationConstants.entranceCurve,
    );

    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AnimationConstants.entranceCurve,
    ));

    // Start the animation
    _animationController.forward();
  }

  @override
  void didUpdateWidget(CalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDay != widget.selectedDay) {
      setState(() {
        _selectedDay = widget.selectedDay;
        _focusedDay = widget.selectedDay;
      });

      // Animate when the selected day changes
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
      animation: _animationController,
      builder: (context, child) {
        return Column(
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: _buildCalendar(),
              ),
            ),
            const SizedBox(height: 16),
            // We don't need to build time slots here anymore as they're handled in the parent widget
          ],
        );
      },
    );
  }

  Widget _buildCalendar() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TableCalendar(
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            widget.onDaySelected(selectedDay);
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
            });
          },
          eventLoader: (day) {
            if (widget.schedule == null) return [];

            final dateString = _dateFormat.format(day);
            final slotsForDate = widget.schedule!.getBookedSlotsForDate(dateString);

            return slotsForDate.isNotEmpty ? [slotsForDate] : [];
          },
          calendarStyle: CalendarStyle(
            markersMaxCount: 3,
            markerDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            weekendTextStyle: const TextStyle(color: Colors.red),
            outsideDaysVisible: false,
          ),
          headerStyle: HeaderStyle(
            formatButtonShowsNext: false,
            titleCentered: true,
            formatButtonVisible: true,
            titleTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
            headerPadding: const EdgeInsets.symmetric(vertical: 12),
            formatButtonDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            formatButtonTextStyle: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: Theme.of(context).primaryColor,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: Theme.of(context).primaryColor,
            ),
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isEmpty) return null;

              return Positioned(
                bottom: 1,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
            selectedBuilder: (context, date, _) {
              return BounceWidget(
                child: Container(
                  margin: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
            todayBuilder: (context, date, _) {
              return PulseWidget(
                child: Container(
                  margin: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // We don't need this method anymore as the time slots are handled by AnimatedTimeSlotList in the parent widget
}
