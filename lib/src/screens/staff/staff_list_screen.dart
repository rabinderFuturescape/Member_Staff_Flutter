import 'package:flutter/material.dart';
import '../../models/staff.dart';
import '../../models/staff_scope.dart';
import '../../services/api_service.dart';
import '../../widgets/app_button.dart';
import 'society_staff_form_screen.dart';
import 'member_staff_form_screen.dart';
import 'staff_detail_screen.dart';

/// Screen for displaying a list of staff members.
class StaffListScreen extends StatefulWidget {
  const StaffListScreen({Key? key}) : super(key: key);

  @override
  State<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService(baseUrl: 'https://api.example.com');
  bool _isLoading = false;
  List<Staff> _societyStaff = [];
  List<Staff> _memberStaff = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadStaff();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      _loadStaff();
    }
  }

  Future<void> _loadStaff() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_tabController.index == 0) {
        final staff = await _apiService.getStaffByScope(StaffScope.society);
        setState(() {
          _societyStaff = staff;
        });
      } else {
        final staff = await _apiService.getStaffByScope(StaffScope.member);
        setState(() {
          _memberStaff = staff;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading staff: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Society Staff'),
            Tab(text: 'Member Staff'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStaffList(_societyStaff, StaffScope.society),
          _buildStaffList(_memberStaff, StaffScope.member),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SocietyStaffFormScreen(),
              ),
            ).then((_) => _loadStaff());
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MemberStaffFormScreen(),
              ),
            ).then((_) => _loadStaff());
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStaffList(List<Staff> staffList, StaffScope scope) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (staffList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No staff members found',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'Add ${scope.displayName}',
              onPressed: () {
                if (scope == StaffScope.society) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SocietyStaffFormScreen(),
                    ),
                  ).then((_) => _loadStaff());
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MemberStaffFormScreen(),
                    ),
                  ).then((_) => _loadStaff());
                }
              },
              width: 200,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStaff,
      child: ListView.builder(
        itemCount: staffList.length,
        itemBuilder: (context, index) {
          final staff = staffList[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(staff.name.substring(0, 1)),
              ),
              title: Text(staff.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(staff.phone),
                  if (staff.designation != null)
                    Text(
                      staff.designation!,
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                ],
              ),
              trailing: staff.isActive
                  ? const Chip(
                      label: Text('Active'),
                      backgroundColor: Colors.green,
                      labelStyle: TextStyle(color: Colors.white),
                    )
                  : const Chip(
                      label: Text('Inactive'),
                      backgroundColor: Colors.red,
                      labelStyle: TextStyle(color: Colors.white),
                    ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StaffDetailScreen(staff: staff),
                  ),
                ).then((_) => _loadStaff());
              },
            ),
          );
        },
      ),
    );
  }
}
