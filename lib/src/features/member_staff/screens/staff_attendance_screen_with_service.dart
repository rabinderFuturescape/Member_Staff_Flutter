import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/attendance.dart';
import '../services/attendance_service.dart';

class StaffAttendanceScreen extends StatefulWidget {
  final AttendanceService? attendanceService;

  const StaffAttendanceScreen({Key? key, this.attendanceService}) : super(key: key);

  @override
  State<StaffAttendanceScreen> createState() => _StaffAttendanceScreenState();
}

class _StaffAttendanceScreenState extends State<StaffAttendanceScreen> {
  late final AttendanceService _attendanceService;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  Map<DateTime, DayAttendanceStatus> _attendanceData = {};
  List<StaffAttendance> _selectedDayStaff = [];
  Map<String, StaffAttendance> _updatedAttendances = {};

  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _attendanceService = widget.attendanceService ?? AttendanceService();
    _loadAttendanceData();
  }

  Future<void> _loadAttendanceData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final attendanceMap = await _attendanceService.getAttendanceData(_focusedDay);

      setState(() {
        _attendanceData = attendanceMap;
        _isLoading = false;
        _updateSelectedDayStaff();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load attendance data: $e')),
      );
    }
  }

  void _updateSelectedDayStaff() async {
    try {
      // Check if we have attendance data for the selected day
      final normalizedDay = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);

      if (_attendanceData.containsKey(normalizedDay)) {
        // Use existing attendance data
        final dayStatus = _attendanceData[normalizedDay]!;
        setState(() {
          _selectedDayStaff = dayStatus.staffAttendances.values.toList();
          _updatedAttendances = Map.from(dayStatus.staffAttendances);
        });
      } else {
        // Get mock staff data
        final mockStaff = await _attendanceService.getMockStaffData();

        setState(() {
          _selectedDayStaff = mockStaff;

          // Initialize updated attendances
          _updatedAttendances = {};
          for (final staff in _selectedDayStaff) {
            _updatedAttendances[staff.staffId] = staff;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load staff data: $e')),
      );
    }
  }

  Future<void> _saveAttendance() async {
    if (_updatedAttendances.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No attendance to save')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _attendanceService.saveAttendance(
        date: _selectedDay,
        attendances: _updatedAttendances.values.toList(),
      );

      // Update local data
      final normalizedDay = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
      _attendanceData[normalizedDay] = DayAttendanceStatus(
        date: normalizedDay,
        staffAttendances: Map.from(_updatedAttendances),
      );

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance saved successfully')),
      );
    } catch (e) {
      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save attendance: $e')),
      );
    }
  }

  Future<void> _takePicture(String staffId) async {
    final photoUrl = await _attendanceService.takePhoto();

    if (photoUrl != null) {
      setState(() {
        final staff = _updatedAttendances[staffId]!;
        _updatedAttendances[staffId] = staff.copyWith(photoUrl: photoUrl);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo captured successfully')),
      );
    }
  }

  void _updateAttendanceStatus(String staffId, String status) {
    setState(() {
      final staff = _updatedAttendances[staffId]!;
      _updatedAttendances[staffId] = staff.copyWith(status: status);
    });
  }

  void _addNote(String staffId) async {
    final TextEditingController noteController = TextEditingController();
    final staff = _updatedAttendances[staffId]!;

    if (staff.note != null) {
      noteController.text = staff.note!;
    }

    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Note'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            hintText: 'Enter note here',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, noteController.text),
            child: const Text('SAVE'),
          ),
        ],
      ),
    );

    if (note != null) {
      setState(() {
        _updatedAttendances[staffId] = staff.copyWith(note: note);
      });
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);

    if (_attendanceData.containsKey(normalizedDay)) {
      return [Event(_attendanceData[normalizedDay]!.overallStatus)];
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Attendance'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(8),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: TableCalendar<Event>(
                firstDay: DateTime.now().subtract(const Duration(days: 365)),
                lastDay: DateTime.now().add(const Duration(days: 30)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: _calendarFormat,
                eventLoader: _getEventsForDay,
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarStyle: CalendarStyle(
                  markersMaxCount: 3,
                  markerDecoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _updateSelectedDayStaff();
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

                  // Load data for the new month
                  if (_focusedDay.month != _selectedDay.month ||
                      _focusedDay.year != _selectedDay.year) {
                    _loadAttendanceData();
                  }
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isEmpty) return null;

                    final event = events.first as Event;
                    Color markerColor;

                    switch (event.title) {
                      case 'present':
                        markerColor = Colors.green;
                        break;
                      case 'absent':
                        markerColor = Colors.red;
                        break;
                      case 'mixed':
                        markerColor = Colors.orange;
                        break;
                      default:
                        return null;
                    }

                    return Positioned(
                      bottom: 1,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: markerColor,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Staff Attendance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(_selectedDay),
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _selectedDayStaff.isEmpty
                    ? const Center(
                        child: Text('No staff assigned for this day'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _selectedDayStaff.length,
                        itemBuilder: (context, index) {
                          final staffId = _selectedDayStaff[index].staffId;
                          final staff = _updatedAttendances[staffId]!;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundImage: staff.staffPhoto != null
                                            ? NetworkImage(staff.staffPhoto!)
                                            : null,
                                        child: staff.staffPhoto == null
                                            ? const Icon(Icons.person)
                                            : null,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              staff.staffName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              staff.staffCategory,
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (staff.status != 'not_marked')
                                        Icon(
                                          staff.statusIcon,
                                          color: staff.statusColor,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () => _updateAttendanceStatus(staffId, 'present'),
                                          icon: const Icon(Icons.check),
                                          label: const Text('Present'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: staff.status == 'present'
                                                ? Colors.green
                                                : Colors.grey.shade200,
                                            foregroundColor: staff.status == 'present'
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () => _updateAttendanceStatus(staffId, 'absent'),
                                          icon: const Icon(Icons.close),
                                          label: const Text('Absent'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: staff.status == 'absent'
                                                ? Colors.red
                                                : Colors.grey.shade200,
                                            foregroundColor: staff.status == 'absent'
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () => _addNote(staffId),
                                          icon: const Icon(Icons.note_add),
                                          label: Text(staff.note != null ? 'Edit Note' : 'Add Note'),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () => _takePicture(staffId),
                                          icon: const Icon(Icons.camera_alt),
                                          label: Text(staff.photoUrl != null ? 'Retake Photo' : 'Take Photo'),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (staff.note != null) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.note,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              staff.note!,
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  if (staff.photoUrl != null) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      height: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.grey.shade200,
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.photo,
                                          size: 48,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _isSaving ? null : _saveAttendance,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Save Attendance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}

class Event {
  final String title;

  const Event(this.title);
}
