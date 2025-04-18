import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api/member_staff_booking_api.dart';
import '../models/booking.dart';
import '../../../core/services/api_client.dart';
import 'member_staff_booking_screen.dart';

class MemberStaffSearchScreen extends StatefulWidget {
  const MemberStaffSearchScreen({Key? key}) : super(key: key);

  @override
  State<MemberStaffSearchScreen> createState() => _MemberStaffSearchScreenState();
}

class _MemberStaffSearchScreenState extends State<MemberStaffSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  DateTime? _selectedDate;
  bool _isSearching = false;
  List<dynamic> _searchResults = [];
  
  final List<String> _categories = [
    'All',
    'Domestic Help',
    'Driver',
    'Cook',
    'Electrician',
    'Plumber',
  ];
  
  @override
  void initState() {
    super.initState();
    _performSearch();
  }
  
  Future<void> _performSearch() async {
    setState(() {
      _isSearching = true;
    });
    
    try {
      // In a real app, this would call the API
      // For demo purposes, we'll use mock data
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _searchResults = [
          {
            'id': '1001',
            'name': 'Rajesh Kumar',
            'category': 'Domestic Help',
            'is_verified': true,
            'primary_working_hours': '8:00 AM - 5:00 PM',
            'photo_url': 'https://randomuser.me/api/portraits/men/1.jpg',
          },
          {
            'id': '1002',
            'name': 'Priya Singh',
            'category': 'Cook',
            'is_verified': true,
            'primary_working_hours': '7:00 AM - 2:00 PM',
            'photo_url': 'https://randomuser.me/api/portraits/women/2.jpg',
          },
          {
            'id': '1003',
            'name': 'Amit Sharma',
            'category': 'Driver',
            'is_verified': true,
            'primary_working_hours': '9:00 AM - 6:00 PM',
            'photo_url': 'https://randomuser.me/api/portraits/men/3.jpg',
          },
          {
            'id': '1004',
            'name': 'Neha Patel',
            'category': 'Domestic Help',
            'is_verified': false,
            'primary_working_hours': '10:00 AM - 7:00 PM',
            'photo_url': 'https://randomuser.me/api/portraits/women/4.jpg',
          },
          {
            'id': '1005',
            'name': 'Suresh Verma',
            'category': 'Electrician',
            'is_verified': true,
            'primary_working_hours': '8:00 AM - 6:00 PM',
            'photo_url': 'https://randomuser.me/api/portraits/men/5.jpg',
          },
        ];
        
        // Filter by category if needed
        if (_selectedCategory != 'All') {
          _searchResults = _searchResults.where((staff) => 
            staff['category'] == _selectedCategory
          ).toList();
        }
        
        // Filter by search query if needed
        if (_searchController.text.isNotEmpty) {
          final query = _searchController.text.toLowerCase();
          _searchResults = _searchResults.where((staff) => 
            staff['name'].toLowerCase().contains(query)
          ).toList();
        }
        
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching staff: $e')),
      );
    }
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      
      _performSearch();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Staff'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _performSearch();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
                const SizedBox(height: 16),
                
                // Filters
                Row(
                  children: [
                    // Category Filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCategory = value;
                            });
                            _performSearch();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Date Filter
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDate == null
                                    ? 'Any Date'
                                    : DateFormat('MMM d, yyyy').format(_selectedDate!),
                                style: TextStyle(
                                  color: _selectedDate == null
                                      ? Colors.grey.shade600
                                      : Colors.black,
                                ),
                              ),
                              const Icon(Icons.calendar_today, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Results Section
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No staff found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Try changing your search criteria',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final staff = _searchResults[index];
                          return StaffListItem(
                            id: staff['id'],
                            name: staff['name'],
                            category: staff['category'],
                            isVerified: staff['is_verified'],
                            workingHours: staff['primary_working_hours'],
                            photoUrl: staff['photo_url'],
                            onCheckAvailability: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MemberStaffBookingScreen(
                                    staffId: staff['id'],
                                    staffName: staff['name'],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class StaffListItem extends StatelessWidget {
  final String id;
  final String name;
  final String category;
  final bool isVerified;
  final String workingHours;
  final String photoUrl;
  final VoidCallback onCheckAvailability;
  
  const StaffListItem({
    Key? key,
    required this.id,
    required this.name,
    required this.category,
    required this.isVerified,
    required this.workingHours,
    required this.photoUrl,
    required this.onCheckAvailability,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Staff Photo
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(photoUrl),
                ),
                const SizedBox(width: 16),
                
                // Staff Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isVerified)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.green,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.verified,
                                    color: Colors.green,
                                    size: 14,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'VERIFIED',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            workingHours,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onCheckAvailability,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Check Availability',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
