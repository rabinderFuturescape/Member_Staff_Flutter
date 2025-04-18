import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api/member_staff_booking_api.dart';
import '../models/booking.dart';
import '../../../core/services/api_client.dart';

class RescheduleModal extends StatefulWidget {
  final String staffId;
  
  const RescheduleModal({
    Key? key,
    required this.staffId,
  }) : super(key: key);

  @override
  State<RescheduleModal> createState() => _RescheduleModalState();
}

class _RescheduleModalState extends State<RescheduleModal> {
  final MemberStaffBookingApi _bookingApi = MemberStaffBookingApi(
    apiClient: ApiClient(), // Assume this is available
  );
  
  DateTime _selectedDate = DateTime.now();
  final List<int> _selectedHours = [];
  List<HourlyAvailability>? _availableHours;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }
  
  Future<void> _loadAvailability() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final availability = await _bookingApi.getStaffAvailability(
        widget.staffId,
        dateStr,
      );
      
      setState(() {
        _availableHours = availability;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load availability: $e')),
      );
    }
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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
        _selectedHours.clear();
      });
      
      _loadAvailability();
    }
  }
  
  void _toggleHour(int hour) {
    setState(() {
      if (_selectedHours.contains(hour)) {
        _selectedHours.remove(hour);
      } else {
        _selectedHours.add(hour);
      }
    });
  }
  
  void _submit() {
    if (_selectedHours.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one time slot')),
      );
      return;
    }
    
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    Navigator.of(context).pop({
      'date': dateStr,
      'hours': _selectedHours,
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Reschedule Booking',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Select New Date',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Select New Time Slots',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_availableHours == null)
                const Center(
                  child: Text('Failed to load availability'),
                )
              else if (_availableHours!.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No time slots available for this date'),
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableHours!.map((hour) {
                    final isSelected = _selectedHours.contains(hour.hour);
                    return ChoiceChip(
                      label: Text(hour.formattedTime),
                      selected: isSelected,
                      onSelected: hour.isBooked
                          ? null
                          : (_) => _toggleHour(hour.hour),
                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                      backgroundColor: Colors.grey.shade100,
                      labelStyle: TextStyle(
                        color: hour.isBooked
                            ? Colors.grey
                            : isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      disabledColor: Colors.grey.shade200,
                    );
                  }).toList(),
                ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedHours.isEmpty ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Confirm Reschedule',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
