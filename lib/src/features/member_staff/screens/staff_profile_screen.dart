import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/staff.dart';
import '../widgets/staff_rating_summary.dart';
import '../widgets/staff_rating_dialog.dart';
import '../providers/staff_rating_provider.dart';

class StaffProfileScreen extends StatefulWidget {
  final Staff staff;
  final String staffType; // 'society' or 'member'

  const StaffProfileScreen({
    Key? key,
    required this.staff,
    required this.staffType,
  }) : super(key: key);

  @override
  _StaffProfileScreenState createState() => _StaffProfileScreenState();
}

class _StaffProfileScreenState extends State<StaffProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Staff Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStaffHeader(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: StaffRatingSummary(
                staffId: widget.staff.id,
                staffType: widget.staffType,
                onRatePressed: _showRatingDialog,
              ),
            ),
            _buildStaffDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffHeader() {
    return Container(
      width: double.infinity,
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: widget.staff.photoUrl != null
                ? NetworkImage(widget.staff.photoUrl!)
                : null,
            child: widget.staff.photoUrl == null
                ? Text(
                    widget.staff.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(fontSize: 40),
                  )
                : null,
          ),
          SizedBox(height: 16),
          Text(
            widget.staff.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            widget.staff.category ?? widget.staffType.capitalize(),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showRatingDialog,
            icon: Icon(Icons.star),
            label: Text('Rate Staff'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffDetails() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Staff Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          _buildDetailItem(Icons.phone, 'Phone', widget.staff.phone ?? 'Not available'),
          _buildDetailItem(Icons.location_on, 'Address', widget.staff.address ?? 'Not available'),
          _buildDetailItem(Icons.work, 'Status', widget.staff.status ?? 'Active'),
          if (widget.staffType == 'member') ...[
            _buildDetailItem(Icons.schedule, 'Availability', 'View Schedule'),
            _buildDetailItem(Icons.history, 'Attendance', 'View Attendance'),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRatingDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StaffRatingDialog(
        staff: widget.staff,
        staffType: widget.staffType,
      ),
    );

    if (result == true) {
      // Rating was submitted successfully, refresh the rating summary
      final ratingProvider = Provider.of<StaffRatingProvider>(context, listen: false);
      ratingProvider.getRatingSummary(
        staffId: widget.staff.id,
        staffType: widget.staffType,
        forceRefresh: true,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Thank you for your rating!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
