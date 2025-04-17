import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/schedule.dart';
import '../../services/api_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/calendar_view.dart';
import '../../providers/notification_provider.dart';
import '../../utils/error_handler.dart';
import '../../utils/api_exception.dart';

/// Screen for viewing and managing a staff member's schedule.
class StaffScheduleScreen extends StatefulWidget {
  final String staffId;

  const StaffScheduleScreen({Key? key, required this.staffId}) : super(key: key);

  @override
  State<StaffScheduleScreen> createState() => _StaffScheduleScreenState();
}

class _StaffScheduleScreenState extends State<StaffScheduleScreen> {
  final ApiService _apiService = ApiService(baseUrl: 'https://api.example.com');
  bool _isLoading = true;
  Schedule? _schedule;
  DateTime _selectedDate = DateTime.now();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat _displayDateFormat = DateFormat('EEEE, MMMM d, yyyy');
  final DateFormat _timeFormat = DateFormat('HH:mm');

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final schedule = await _apiService.getStaffSchedule(widget.staffId);
      setState(() {
        _schedule = schedule;
      });
    } on ApiException catch (e) {
      if (mounted) {
        ErrorHandler.handleApiException(
          context,
          e,
          onRetry: _loadSchedule,
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.handleException(context, e);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _addTimeSlot() async {
    final TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (startTime == null) return;

    final TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: (startTime.hour + 1) % 24,
        minute: startTime.minute,
      ),
    );
    if (endTime == null) return;

    // Validate that end time is after start time
    final now = DateTime.now();
    final startDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      startTime.hour,
      startTime.minute,
    );
    final endDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      endTime.hour,
      endTime.minute,
    );

    if (endDateTime.isBefore(startDateTime)) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          'End time must be after start time',
        );
      }
      return;
    }

    final timeSlot = TimeSlot(
      date: _dateFormat.format(_selectedDate),
      startTime: _timeFormat.format(startDateTime),
      endTime: _timeFormat.format(endDateTime),
    );

    try {
      final success = await _apiService.addTimeSlotToSchedule(widget.staffId, timeSlot);
      if (success && mounted) {
        ErrorHandler.showSuccessSnackBar(
          context,
          'Time slot added successfully',
        );

        // Send notification
        final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
        await notificationProvider.notifyNewTimeSlot(
          staffName: 'Staff', // Ideally, you would pass the actual staff name here
          timeSlot: timeSlot,
        );

        _loadSchedule();
      }
    } on ApiException catch (e) {
      if (mounted) {
        ErrorHandler.handleApiException(
          context,
          e,
          onRetry: () => _addTimeSlot(),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.handleException(context, e);
      }
    }
  }

  Future<void> _removeTimeSlot(TimeSlot timeSlot) async {
    try {
      final success = await _apiService.removeTimeSlotFromSchedule(widget.staffId, timeSlot);
      if (success && mounted) {
        ErrorHandler.showSuccessSnackBar(
          context,
          'Time slot removed successfully',
        );

        // Send notification
        final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
        await notificationProvider.notifyRemovedTimeSlot(
          staffName: 'Staff', // Ideally, you would pass the actual staff name here
          timeSlot: timeSlot,
        );

        _loadSchedule();
      }
    } on ApiException catch (e) {
      if (mounted) {
        ErrorHandler.handleApiException(
          context,
          e,
          onRetry: () => _removeTimeSlot(timeSlot),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.handleException(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Schedule'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCalendarView(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTimeSlot,
        tooltip: 'Add Time Slot',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendarView() {
    return CalendarView(
      schedule: _schedule,
      selectedDay: _selectedDate,
      onDaySelected: (day) {
        setState(() {
          _selectedDate = day;
        });
      },
      onTimeSlotTap: (timeSlot) {
        _showTimeSlotOptions(timeSlot);
      },
    );
  }

  void _showTimeSlotOptions(TimeSlot timeSlot) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.access_time),
                title: Text('${timeSlot.startTime} - ${timeSlot.endTime}'),
                subtitle: Text('Date: ${timeSlot.date}'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Time Slot'),
                onTap: () {
                  Navigator.pop(context);
                  _removeTimeSlot(timeSlot);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Edit Time Slot'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement edit time slot
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit feature coming soon')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
