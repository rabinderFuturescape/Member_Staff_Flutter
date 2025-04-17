import 'package:flutter/material.dart';
import '../../models/member.dart';
import '../../models/member_staff.dart';
import '../../services/api_service.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_dropdown.dart';
import '../../widgets/app_button.dart';

/// Screen for adding or editing a member staff.
class MemberStaffFormScreen extends StatefulWidget {
  final MemberStaff? staff;

  const MemberStaffFormScreen({Key? key, this.staff}) : super(key: key);

  @override
  State<MemberStaffFormScreen> createState() => _MemberStaffFormScreenState();
}

class _MemberStaffFormScreenState extends State<MemberStaffFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _designationController = TextEditingController();
  final _otpController = TextEditingController();

  String? _selectedMemberId;
  bool _isActive = true;
  bool _isLoading = false;
  bool _isVerifyingPhone = false;
  bool _isPhoneVerified = false;

  final ApiService _apiService = ApiService(baseUrl: 'https://api.example.com');
  List<Member> _members = [];

  // Common member staff roles
  final List<String> _roles = [
    'Domestic Help',
    'Driver',
    'Electrician',
    'Plumber',
    'Carpenter',
    'Gardener',
    'Cook',
    'Nanny',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadMembers();
    
    if (widget.staff != null) {
      _nameController.text = widget.staff!.name;
      _emailController.text = widget.staff!.email;
      _phoneController.text = widget.staff!.phone;
      _designationController.text = widget.staff!.designation ?? '';
      _isActive = widget.staff!.isActive;
      _isPhoneVerified = true; // Assume phone is verified for existing staff
    }
  }

  Future<void> _loadMembers() async {
    try {
      final members = await _apiService.getMembers();
      setState(() {
        _members = members;
        if (_members.isNotEmpty) {
          _selectedMemberId = _members.first.id;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading members: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _designationController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyPhone() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a phone number')),
      );
      return;
    }

    setState(() {
      _isVerifyingPhone = true;
    });

    // Simulate OTP sending
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isVerifyingPhone = false;
    });

    // Show OTP verification dialog
    if (mounted) {
      _showOtpDialog();
    }
  }

  void _showOtpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Verify Phone Number'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter the OTP sent to your phone:'),
              const SizedBox(height: 16),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  hintText: 'Enter OTP',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _otpController.clear();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Simulate OTP verification
                if (_otpController.text.length == 6) {
                  setState(() {
                    _isPhoneVerified = true;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Phone number verified')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid OTP')),
                  );
                }
              },
              child: const Text('Verify'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (!_isPhoneVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please verify the phone number')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final staff = MemberStaff(
          id: widget.staff?.id ?? '',
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          position: null,
          hireDate: widget.staff?.hireDate ?? DateTime.now(),
          salary: null,
          isActive: _isActive,
          designation: _designationController.text,
        );

        final result = await _apiService.createOrAssignMemberStaff(staff, _selectedMemberId!);
        final (createdStaff, isNewStaff) = result;
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isNewStaff
                    ? 'Staff created and assigned successfully'
                    : 'Existing staff assigned successfully',
              ),
            ),
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
        title: Text(widget.staff == null ? 'Add Member Staff' : 'Edit Member Staff'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_members.isNotEmpty)
                AppDropdown<String>(
                  label: 'Assign to Member',
                  hint: 'Select a member',
                  value: _selectedMemberId,
                  items: _members.map((member) {
                    return DropdownMenuItem<String>(
                      value: member.id,
                      child: Text(member.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMemberId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a member';
                    }
                    return null;
                  },
                ),
              if (_members.isNotEmpty) const SizedBox(height: 16),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Phone',
                      hint: 'Enter phone number',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      enabled: !_isPhoneVerified,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a phone number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: AppButton(
                      text: _isPhoneVerified ? 'Verified' : 'Verify',
                      onPressed: _isPhoneVerified ? null : _verifyPhone,
                      isLoading: _isVerifyingPhone,
                      isOutlined: !_isPhoneVerified,
                      color: _isPhoneVerified ? Colors.green : null,
                      width: 100,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppDropdown<String>(
                label: 'Role',
                hint: 'Select staff role',
                value: _designationController.text.isEmpty ? null : _designationController.text,
                items: _roles.map((role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _designationController.text = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a role';
                  }
                  return null;
                },
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
