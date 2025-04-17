import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/schedule.dart';
import '../../services/api_service.dart';
import '../../widgets/app_button.dart';

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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading schedule: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End time must be after start time')),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Time slot added successfully')),
        );
        _loadSchedule();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding time slot: $e')),
        );
      }
    }
  }

  Future<void> _removeTimeSlot(TimeSlot timeSlot) async {
    try {
      final success = await _apiService.removeTimeSlotFromSchedule(widget.staffId, timeSlot);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Time slot removed successfully')),
        );
        _loadSchedule();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing time slot: $e')),
        );
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
          : Column(
              children: [
                _buildDateSelector(),
                Expanded(
                  child: _buildScheduleForDate(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTimeSlot,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
              });
            },
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _selectDate(context),
              child: Text(
                _displayDateFormat.format(_selectedDate),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.add(const Duration(days: 1));
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleForDate() {
    if (_schedule == null) {
      return const Center(
        child: Text('No schedule available'),
      );
    }

    final dateString = _dateFormat.format(_selectedDate);
    final slotsForDate = _schedule!.getBookedSlotsForDate(dateString);

    if (slotsForDate.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No time slots for this date',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'Add Time Slot',
              onPressed: _addTimeSlot,
              width: 200,
              icon: const Icon(Icons.add, color: Colors.white),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: slotsForDate.length,
      itemBuilder: (context, index) {
        final slot = slotsForDate[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: const Icon(Icons.access_time),
            title: Text('${slot.startTime} - ${slot.endTime}'),
            subtitle: Text('Date: ${slot.date}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeTimeSlot(slot),
            ),
          ),
        );
      },
    );
  }
}
