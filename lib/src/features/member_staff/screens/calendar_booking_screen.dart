import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../api/member_staff_booking_api.dart';
import '../models/booking.dart';
import '../widgets/reschedule_modal.dart';
import '../widgets/cancel_confirmation_dialog.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/auth_service.dart';

class CalendarBookingScreen extends StatefulWidget {
  final String? staffId;
  final String? staffName;

  const CalendarBookingScreen({
    Key? key,
    this.staffId,
    this.staffName,
  }) : super(key: key);

  @override
  State<CalendarBookingScreen> createState() => _CalendarBookingScreenState();
}

class _CalendarBookingScreenState extends State<CalendarBookingScreen> {
  final MemberStaffBookingApi _bookingApi = MemberStaffBookingApi(
    apiClient: ApiClient(),
  );
  final AuthService _authService = AuthService();
  
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  
  Map<DateTime, List<BookingSlotView>> _bookingsByDay = {};
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadBookings();
  }
  
  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final member = await _authService.getCurrentMember();
      final bookings = await _bookingApi.getMemberBookings(member.id);
      
      // Group bookings by day
      final Map<DateTime, List<BookingSlotView>> groupedBookings = {};
      for (final booking in bookings) {
        final date = DateTime(
          booking.date.year,
          booking.date.month,
          booking.date.day,
        );
        
        if (!groupedBookings.containsKey(date)) {
          groupedBookings[date] = [];
        }
        
        groupedBookings[date]!.add(booking);
      }
      
      setState(() {
        _bookingsByDay = groupedBookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load bookings: $e')),
      );
    }
  }
  
  List<BookingSlotView> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _bookingsByDay[normalizedDay] ?? [];
  }
  
  Future<void> _rescheduleBooking(String bookingId, String staffId) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RescheduleModal(staffId: staffId),
    );
    
    if (result != null) {
      try {
        await _bookingApi.rescheduleBooking(
          bookingId,
          result['date'],
          result['hours'],
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking rescheduled successfully')),
        );
        
        _loadBookings();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reschedule: $e')),
        );
      }
    }
  }
  
  Future<void> _cancelBooking(String bookingId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => const CancelConfirmationDialog(),
    );
    
    if (confirm == true) {
      try {
        await _bookingApi.cancelBooking(bookingId);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking cancelled successfully')),
        );
        
        _loadBookings();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel: $e')),
        );
      }
    }
  }
  
  void _showBookingsForDay(DateTime day) {
    final bookings = _getEventsForDay(day);
    
    if (bookings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No bookings for ${DateFormat('MMM d, yyyy').format(day)}')),
      );
      return;
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(day),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                itemCount: bookings.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Row(
                      children: [
                        Text(
                          booking.formattedTime,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: booking.statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: booking.statusColor,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            booking.status.toUpperCase(),
                            style: TextStyle(
                              color: booking.statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        FutureBuilder<String>(
                          // In a real app, you would fetch staff details
                          future: Future.value('Staff Name'),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data ?? 'Loading staff details...',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    trailing: booking.status != 'cancelled'
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_calendar_outlined),
                                tooltip: 'Reschedule',
                                onPressed: () => _rescheduleBooking(
                                  booking.bookingId,
                                  booking.staffId,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel_outlined),
                                tooltip: 'Cancel',
                                color: Colors.red,
                                onPressed: () => _cancelBooking(booking.bookingId),
                              ),
                            ],
                          )
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings Calendar'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: 'List View',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/member-staff/bookings');
            },
          ),
        ],
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
              child: TableCalendar<BookingSlotView>(
                firstDay: DateTime.now().subtract(const Duration(days: 30)),
                lastDay: DateTime.now().add(const Duration(days: 60)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: _calendarFormat,
                eventLoader: _getEventsForDay,
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarStyle: CalendarStyle(
                  markersMaxCount: 3,
                  markerDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
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
                  _showBookingsForDay(selectedDay);
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _bookingsByDay.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No bookings found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Book a staff member to see your bookings here',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/member-staff/search');
                              },
                              icon: const Icon(Icons.search),
                              label: const Text('Find Staff'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          const Text(
                            'Upcoming Bookings',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...List.generate(
                            _getEventsForDay(_selectedDay).length > 0 ? 1 : 0,
                            (index) => Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      DateFormat('EEEE, MMMM d, yyyy').format(_selectedDay),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const Divider(height: 1),
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _getEventsForDay(_selectedDay).length,
                                    separatorBuilder: (context, index) => const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final booking = _getEventsForDay(_selectedDay)[index];
                                      return ListTile(
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        title: Row(
                                          children: [
                                            Text(
                                              booking.formattedTime,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: booking.statusColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: booking.statusColor,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                booking.status.toUpperCase(),
                                                style: TextStyle(
                                                  color: booking.statusColor,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 4),
                                            FutureBuilder<String>(
                                              // In a real app, you would fetch staff details
                                              future: Future.value('Staff Name'),
                                              builder: (context, snapshot) {
                                                return Text(
                                                  snapshot.data ?? 'Loading staff details...',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        trailing: booking.status != 'cancelled'
                                            ? Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.edit_calendar_outlined),
                                                    tooltip: 'Reschedule',
                                                    onPressed: () => _rescheduleBooking(
                                                      booking.bookingId,
                                                      booking.staffId,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.cancel_outlined),
                                                    tooltip: 'Cancel',
                                                    color: Colors.red,
                                                    onPressed: () => _cancelBooking(booking.bookingId),
                                                  ),
                                                ],
                                              )
                                            : null,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/member-staff/search');
        },
        child: const Icon(Icons.add),
        tooltip: 'Book Staff',
      ),
    );
  }
}
