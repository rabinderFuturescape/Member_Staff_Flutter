import 'package:flutter/material.dart';
import '../../models/staff.dart';
import '../../models/staff_scope.dart';
import '../../models/society_staff.dart';
import '../../models/member_staff.dart';
import 'society_staff_form_screen.dart';
import 'member_staff_form_screen.dart';
import 'staff_schedule_screen.dart';

/// Screen for displaying staff details.
class StaffDetailScreen extends StatelessWidget {
  final Staff staff;

  const StaffDetailScreen({Key? key, required this.staff}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              if (staff.staffScope == StaffScope.society) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SocietyStaffFormScreen(
                      staff: staff as SocietyStaff,
                    ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MemberStaffFormScreen(
                      staff: staff as MemberStaff,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            _buildDetailSection(context),
            const SizedBox(height: 24),
            if (staff.staffScope == StaffScope.member)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StaffScheduleScreen(staffId: staff.id),
                    ),
                  );
                },
                icon: const Icon(Icons.calendar_today),
                label: const Text('View Schedule'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            staff.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              fontSize: 32,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                staff.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                staff.designation ?? 'No designation',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: staff.isActive ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  staff.isActive ? 'Active' : 'Inactive',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildDetailItem(Icons.email, 'Email', staff.email),
        _buildDetailItem(Icons.phone, 'Phone', staff.phone),
        const SizedBox(height: 24),
        const Text(
          'Staff Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildDetailItem(Icons.badge, 'Type', staff.staffScope.displayName),
        if (staff.staffScope == StaffScope.society) ...[
          _buildDetailItem(
            Icons.category,
            'Category',
            (staff as SocietyStaff).societyCategory,
          ),
          _buildDetailItem(
            Icons.access_time,
            'Work Timings',
            (staff as SocietyStaff).workTimings,
          ),
        ],
        if (staff.position != null)
          _buildDetailItem(Icons.work, 'Position', staff.position!),
        if (staff.salary != null)
          _buildDetailItem(
            Icons.attach_money,
            'Salary',
            '\$${staff.salary!.toStringAsFixed(2)}',
          ),
        _buildDetailItem(
          Icons.calendar_today,
          'Hire Date',
          '${staff.hireDate.day}/${staff.hireDate.month}/${staff.hireDate.year}',
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
