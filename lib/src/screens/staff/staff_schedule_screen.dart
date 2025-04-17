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
import '../../utils/date_time_utils.dart';
import '../../utils/animation_constants.dart';
import '../../utils/animation_preferences.dart';
import '../../widgets/loading_animations.dart';
import '../../widgets/animated_time_slot_list.dart';
import '../../widgets/animated_form_fields.dart';
import '../../widgets/micro_interactions.dart';
import '../../widgets/hero_widgets.dart';

/// Screen for viewing and managing a staff member's schedule.
class StaffScheduleScreen extends StatefulWidget {
  final String staffId;
  final String? staffName; // Optional staff name parameter

  const StaffScheduleScreen({
    Key? key,
    required this.staffId,
    this.staffName,
  }) : super(key: key);

  @override
  State<StaffScheduleScreen> createState() => _StaffScheduleScreenState();
}

class _StaffScheduleScreenState extends State<StaffScheduleScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService(baseUrl: 'https://api.example.com');
  bool _isLoading = true;
  Schedule? _schedule;
  DateTime _selectedDate = DateTime.now();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat _displayDateFormat = DateFormat('EEEE, MMMM d, yyyy');
  final DateFormat _timeFormat = DateFormat('HH:mm');
  String? _staffName;

  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _staffName = widget.staffName;

    // Initialize animation controllers
    _fadeController = AnimationController(
      vsync: this,
      duration: AnimationConstants.mediumDuration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: AnimationConstants.entranceCurve,
    );

    _loadSchedule();
    if (_staffName == null) {
      _loadStaffInfo();
    }

    // Start the fade-in animation
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadStaffInfo() async {
    try {
      // Fetch staff information to get the name
      final response = await _apiService.getStaffById(widget.staffId);
      if (mounted) {
        setState(() {
          _staffName = response.name;
        });
      }
    } catch (e) {
      // If we can't get the staff name, we'll use a default
      print('Error loading staff info: $e');
    }
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
          staffName: _staffName ?? 'Staff',
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
          staffName: _staffName ?? 'Staff',
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
        title: Text(
          _staffName != null ? '$_staffName\'s Schedule' : 'Staff Schedule',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: PulsatingLoadingIndicator())
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildCalendarView(),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: _isLoading
          ? null
          : ScaleTransition(
              scale: _fadeAnimation,
              child: FloatingActionButton(
                onPressed: _addTimeSlot,
                tooltip: 'Add Time Slot',
                child: const Icon(Icons.add),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            if (_staffName != null)
              StaffAvatarHero(
                staffId: widget.staffId,
                staffName: _staffName!,
                radius: 24,
              ),
            if (_staffName != null)
              const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _displayDateFormat.format(_selectedDate),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap on a day to view schedule',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            BounceWidget(
              onTap: () => _selectDate(context),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView() {
    return Column(
      children: [
        CalendarView(
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
        ),
        const SizedBox(height: 24),
        _buildTimeSlotsList(),
      ],
    );
  }

  Widget _buildTimeSlotsList() {
    if (_schedule == null) {
      return const SizedBox.shrink();
    }

    final slotsForDate = _schedule!.getBookedSlotsForDate(
      _dateFormat.format(_selectedDate),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Time Slots',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            AnimatedButton(
              text: 'Add Slot',
              onPressed: _addTimeSlot,
              isOutlined: true,
              icon: const Icon(Icons.add, size: 16),
              width: 120,
              height: 40,
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedTimeSlotList(
          timeSlots: slotsForDate,
          onTimeSlotTap: _showTimeSlotOptions,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  void _showTimeSlotOptions(TimeSlot timeSlot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 1.0, end: 0.0),
          duration: AnimationConstants.mediumDuration,
          curve: AnimationConstants.entranceCurve,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 100 * value),
              child: Opacity(
                opacity: 1 - value,
                child: child,
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Date: ${timeSlot.formattedDate}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: AnimatedButton(
                        text: 'Edit',
                        icon: const Icon(Icons.edit, size: 16),
                        onPressed: () {
                          Navigator.pop(context);
                          _editTimeSlot(timeSlot);
                        },
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AnimatedButton(
                        text: 'Remove',
                        icon: const Icon(Icons.delete, size: 16),
                        onPressed: () {
                          Navigator.pop(context);
                          _removeTimeSlot(timeSlot);
                        },
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AnimatedButton(
                  text: 'Cancel',
                  onPressed: () => Navigator.pop(context),
                  isOutlined: true,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _editTimeSlot(TimeSlot oldSlot) async {
    // Parse the old slot's date and time
    final oldDate = DateTimeUtils.parseDate(oldSlot.date);
    final oldStartTime = DateTimeUtils.parseTime(oldSlot.startTime);
    final oldEndTime = DateTimeUtils.parseTime(oldSlot.endTime);

    // Initialize with the old values
    DateTime selectedDate = oldDate;
    TimeOfDay selectedStartTime = TimeOfDay(hour: oldStartTime.hour, minute: oldStartTime.minute);
    TimeOfDay selectedEndTime = TimeOfDay(hour: oldEndTime.hour, minute: oldEndTime.minute);

    // Show date picker
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select Date',
    );

    if (pickedDate == null) return; // User canceled
    selectedDate = pickedDate;

    // Show start time picker
    final TimeOfDay? pickedStartTime = await showTimePicker(
      context: context,
      initialTime: selectedStartTime,
      helpText: 'Select Start Time',
    );

    if (pickedStartTime == null) return; // User canceled
    selectedStartTime = pickedStartTime;

    // Show end time picker
    final TimeOfDay? pickedEndTime = await showTimePicker(
      context: context,
      initialTime: selectedEndTime,
      helpText: 'Select End Time',
    );

    if (pickedEndTime == null) return; // User canceled
    selectedEndTime = pickedEndTime;

    // Validate that end time is after start time
    final now = DateTime.now();
    final startDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      selectedStartTime.hour,
      selectedStartTime.minute,
    );
    final endDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      selectedEndTime.hour,
      selectedEndTime.minute,
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

    // Create the new time slot
    final newSlot = TimeSlot(
      date: DateTimeUtils.formatDate(selectedDate),
      startTime: DateTimeUtils.formatTime(startDateTime),
      endTime: DateTimeUtils.formatTime(endDateTime),
      isBooked: oldSlot.isBooked,
    );

    try {
      final success = await _apiService.updateTimeSlotInSchedule(widget.staffId, oldSlot, newSlot);
      if (success && mounted) {
        ErrorHandler.showSuccessSnackBar(
          context,
          'Time slot updated successfully',
        );

        // Send notification
        final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
        await notificationProvider.notifyNewTimeSlot(
          staffName: _staffName ?? 'Staff',
          timeSlot: newSlot,
        );

        _loadSchedule();
      }
    } on ApiException catch (e) {
      if (mounted) {
        ErrorHandler.handleApiException(
          context,
          e,
          onRetry: () => _editTimeSlot(oldSlot),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.handleException(context, e);
      }
    }
  }
}
