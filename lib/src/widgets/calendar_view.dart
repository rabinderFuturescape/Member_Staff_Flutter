import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/schedule.dart';

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

class _CalendarViewState extends State<CalendarView> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = widget.selectedDay;
    _selectedDay = widget.selectedDay;
  }

  @override
  void didUpdateWidget(CalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDay != widget.selectedDay) {
      _selectedDay = widget.selectedDay;
      _focusedDay = widget.selectedDay;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCalendar(),
        const SizedBox(height: 16),
        _buildTimeSlots(),
      ],
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
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
        _focusedDay = focusedDay;
      },
      eventLoader: (day) {
        if (widget.schedule == null) return [];
        
        final dateString = _dateFormat.format(day);
        final slotsForDate = widget.schedule!.getBookedSlotsForDate(dateString);
        
        return slotsForDate.isNotEmpty ? [slotsForDate] : [];
      },
      calendarStyle: CalendarStyle(
        markersMaxCount: 3,
        markerDecoration: const BoxDecoration(
          color: Colors.blue,
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
      ),
      headerStyle: const HeaderStyle(
        formatButtonShowsNext: false,
        titleCentered: true,
        formatButtonVisible: true,
      ),
    );
  }

  Widget _buildTimeSlots() {
    if (widget.schedule == null) {
      return const Center(
        child: Text('No schedule available'),
      );
    }

    final dateString = _dateFormat.format(_selectedDay);
    final slotsForDate = widget.schedule!.getBookedSlotsForDate(dateString);

    if (slotsForDate.isEmpty) {
      return const Center(
        child: Text(
          'No time slots for this date',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Time Slots for ${DateFormat('EEEE, MMMM d, yyyy').format(_selectedDay)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: slotsForDate.length,
          itemBuilder: (context, index) {
            final slot = slotsForDate[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: const Icon(Icons.access_time),
                title: Text('${slot.startTime} - ${slot.endTime}'),
                onTap: widget.onTimeSlotTap != null
                    ? () => widget.onTimeSlotTap!(slot)
                    : null,
              ),
            );
          },
        ),
      ],
    );
  }
}
