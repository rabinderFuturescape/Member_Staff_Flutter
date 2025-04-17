import 'package:flutter/material.dart';
import '../../models/society_staff.dart';
import '../../services/api_service.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_dropdown.dart';
import '../../widgets/app_button.dart';

/// Screen for adding or editing a society staff member.
class SocietyStaffFormScreen extends StatefulWidget {
  final SocietyStaff? staff;

  const SocietyStaffFormScreen({Key? key, this.staff}) : super(key: key);

  @override
  State<SocietyStaffFormScreen> createState() => _SocietyStaffFormScreenState();
}

class _SocietyStaffFormScreenState extends State<SocietyStaffFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _designationController = TextEditingController();
  final _workTimingsController = TextEditingController();
  final _salaryController = TextEditingController();

  String? _selectedCategory;
  bool _isActive = true;
  bool _isLoading = false;

  final ApiService _apiService = ApiService(baseUrl: 'https://api.example.com');

  // Society staff categories
  final List<String> _categories = [
    'Office Staff',
    'House Keeping',
    'Security',
    'Maintenance',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.staff != null) {
      _nameController.text = widget.staff!.name;
      _emailController.text = widget.staff!.email;
      _phoneController.text = widget.staff!.phone;
      _designationController.text = widget.staff!.designation ?? '';
      _workTimingsController.text = widget.staff!.workTimings;
      _salaryController.text = widget.staff!.salary?.toString() ?? '';
      _selectedCategory = widget.staff!.societyCategory;
      _isActive = widget.staff!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _designationController.dispose();
    _workTimingsController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final staff = SocietyStaff(
          id: widget.staff?.id ?? '',
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          position: null,
          hireDate: widget.staff?.hireDate ?? DateTime.now(),
          salary: _salaryController.text.isNotEmpty
              ? double.parse(_salaryController.text)
              : null,
          isActive: _isActive,
          designation: _designationController.text,
          societyCategory: _selectedCategory!,
          workTimings: _workTimingsController.text,
        );

        await _apiService.createSocietyStaff(staff);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Staff saved successfully')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving staff: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.staff == null ? 'Add Society Staff' : 'Edit Society Staff'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Name',
                hint: 'Enter staff name',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Email',
                hint: 'Enter email address',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Phone',
                hint: 'Enter phone number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppDropdown<String>(
                label: 'Category',
                hint: 'Select staff category',
                value: _selectedCategory,
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Designation',
                hint: 'Enter staff designation (e.g., Accountant, Admin)',
                controller: _designationController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a designation';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Work Timings',
                hint: 'Enter work timings (e.g., 9:00-17:00)',
                controller: _workTimingsController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter work timings';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Salary (Optional)',
                hint: 'Enter salary amount',
                controller: _salaryController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Active Status'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              AppButton(
                text: 'Save',
                onPressed: _submitForm,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
