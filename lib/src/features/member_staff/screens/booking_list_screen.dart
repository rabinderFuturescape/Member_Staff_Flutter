import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api/member_staff_booking_api.dart';
import '../models/booking.dart';
import '../widgets/reschedule_modal.dart';
import '../widgets/cancel_confirmation_dialog.dart';
import '../../../core/services/auth_service.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({Key? key}) : super(key: key);

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  final MemberStaffBookingApi _bookingApi = MemberStaffBookingApi(
    apiClient: ApiClient(), // Assume this is available
  );

  late Future<List<BookingSlotView>> _bookingsFuture;
  final AuthService _authService = AuthService(); // Assume this is available

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
    _bookingsFuture = _authService.getCurrentMember().then((member) {
      return _bookingApi.getMemberBookings(member.id);
    });
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

        setState(() {
          _loadBookings();
        });
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

        setState(() {
          _loadBookings();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Calendar View',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/member-staff/bookings/calendar');
            },
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
      body: FutureBuilder<List<BookingSlotView>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading bookings: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final bookings = snapshot.data ?? [];

          if (bookings.isEmpty) {
            return Center(
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
                      // Navigate to staff search screen
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
            );
          }

          // Group bookings by date
          final Map<String, List<BookingSlotView>> groupedBookings = {};
          for (final booking in bookings) {
            final dateStr = DateFormat('yyyy-MM-dd').format(booking.date);
            if (!groupedBookings.containsKey(dateStr)) {
              groupedBookings[dateStr] = [];
            }
            groupedBookings[dateStr]!.add(booking);
          }

          // Sort dates
          final sortedDates = groupedBookings.keys.toList()
            ..sort((a, b) => a.compareTo(b));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final dateStr = sortedDates[index];
              final dateBookings = groupedBookings[dateStr]!;
              final date = DateTime.parse(dateStr);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(date),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dateBookings.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final booking = dateBookings[index];
                        return BookingListItem(
                          booking: booking,
                          onReschedule: () => _rescheduleBooking(
                            booking.bookingId,
                            booking.staffId,
                          ),
                          onCancel: () => _cancelBooking(booking.bookingId),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class BookingListItem extends StatelessWidget {
  final BookingSlotView booking;
  final VoidCallback onReschedule;
  final VoidCallback onCancel;

  const BookingListItem({
    Key? key,
    required this.booking,
    required this.onReschedule,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  onPressed: onReschedule,
                ),
                IconButton(
                  icon: const Icon(Icons.cancel_outlined),
                  tooltip: 'Cancel',
                  color: Colors.red,
                  onPressed: onCancel,
                ),
              ],
            )
          : null,
    );
  }
}
