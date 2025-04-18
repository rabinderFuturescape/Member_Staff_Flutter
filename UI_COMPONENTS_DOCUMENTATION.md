# Member Staff Module - UI Components Documentation

This document provides a comprehensive overview of all UI components and widgets used in the Member Staff module. It serves as a reference for developers to understand the project structure and UI elements.

## Table of Contents

1. [Core Components](#core-components)
2. [Authentication Components](#authentication-components)
3. [Staff Verification Flow](#staff-verification-flow)
4. [Schedule Management](#schedule-management)
5. [Member-Staff Assignment](#member-staff-assignment)
6. [Common Widgets](#common-widgets)
7. [Form Components](#form-components)
8. [Navigation Components](#navigation-components)
9. [State Management](#state-management)
10. [Theming Components](#theming-components)

## Core Components

### MemberStaffModule

**Path**: `lib/src/features/member_staff/member_staff_module.dart`

The main entry point for the Member Staff module. It initializes the module and sets up the necessary providers.

```dart
class MemberStaffModule extends StatefulWidget {
  final String baseUrl;
  final String? initialRoute;
  final Map<String, String>? params;
  
  const MemberStaffModule({
    Key? key,
    required this.baseUrl,
    this.initialRoute,
    this.params,
  }) : super(key: key);
  
  @override
  State<MemberStaffModule> createState() => _MemberStaffModuleState();
}
```

**Usage**:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => MemberStaffModule(
      baseUrl: 'https://api.example.com',
    ),
  ),
);
```

### ApiClient

**Path**: `lib/src/core/network/api_client.dart`

Handles API requests with authentication and member context.

```dart
class ApiClient {
  final String baseUrl;
  final http.Client _httpClient;
  
  ApiClient({
    required this.baseUrl,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();
  
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams});
  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body});
  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body});
  Future<dynamic> delete(String endpoint, {Map<String, dynamic>? body});
}
```

### TokenManager

**Path**: `lib/src/core/auth/token_manager.dart`

Manages JWT tokens and member context.

```dart
class TokenManager {
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'oneapp_auth_token';
  
  static Future<String?> getAuthToken();
  static Future<void> saveAuthToken(String token);
  static Future<Map<String, dynamic>?> getDecodedToken();
  static Future<Map<String, dynamic>> getMemberContext();
}
```

## Authentication Components

### LoggedInMemberInfo

**Path**: `lib/src/widgets/logged_in_member_info.dart`

Displays information about the currently logged-in member.

```dart
class LoggedInMemberInfo extends StatelessWidget {
  final Map<String, dynamic> memberContext;
  
  const LoggedInMemberInfo({
    Key? key,
    required this.memberContext,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Member: ${memberContext['name']}'),
            Text('Unit: ${memberContext['unit_number']}'),
            Text('Company: ${memberContext['company_id']}'),
          ],
        ),
      ),
    );
  }
}
```

## Staff Verification Flow

### MobileVerificationScreen

**Path**: `lib/src/features/member_staff/screens/verification_flow/mobile_verification_screen.dart`

Screen for verifying a staff member's mobile number.

```dart
class MobileVerificationScreen extends StatefulWidget {
  const MobileVerificationScreen({Key? key}) : super(key: key);
  
  @override
  State<MobileVerificationScreen> createState() => _MobileVerificationScreenState();
}
```

**Key Components**:
- `MobileNumberInput`: Custom text field for entering mobile numbers
- `VerifyButton`: Button to initiate the verification process
- `StaffExistsAlert`: Alert dialog shown when staff already exists

### OtpVerificationScreen

**Path**: `lib/src/features/member_staff/screens/verification_flow/otp_verification_screen.dart`

Screen for verifying the OTP sent to a staff member's mobile number.

```dart
class OtpVerificationScreen extends StatefulWidget {
  final String mobile;
  
  const OtpVerificationScreen({
    Key? key,
    required this.mobile,
  }) : super(key: key);
  
  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}
```

**Key Components**:
- `OtpInput`: Custom widget for entering OTP digits
- `VerifyOtpButton`: Button to verify the entered OTP
- `ResendOtpButton`: Button to resend the OTP
- `OtpTimer`: Timer showing the remaining time for OTP expiration

### IdentityFormScreen

**Path**: `lib/src/features/member_staff/screens/verification_flow/identity_form_screen.dart`

Screen for collecting staff identity information.

```dart
class IdentityFormScreen extends StatefulWidget {
  final String staffId;
  
  const IdentityFormScreen({
    Key? key,
    required this.staffId,
  }) : super(key: key);
  
  @override
  State<IdentityFormScreen> createState() => _IdentityFormScreenState();
}
```

**Key Components**:
- `AadhaarInput`: Custom text field for entering Aadhaar numbers
- `AddressInput`: Multi-line text field for entering addresses
- `NextOfKinForm`: Form for entering next of kin details
- `PhotoCapture`: Widget for capturing or selecting a photo
- `VerifyIdentityButton`: Button to submit the identity information

### VerificationSuccessScreen

**Path**: `lib/src/features/member_staff/screens/verification_flow/verification_success_screen.dart`

Screen shown after successful staff verification.

```dart
class VerificationSuccessScreen extends StatelessWidget {
  final String staffId;
  
  const VerificationSuccessScreen({
    Key? key,
    required this.staffId,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 100),
            Text('Verification Successful!'),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Schedule Management

### StaffScheduleScreen

**Path**: `lib/src/features/member_staff/screens/schedule/staff_schedule_screen.dart`

Screen for viewing and managing a staff member's schedule.

```dart
class StaffScheduleScreen extends StatefulWidget {
  final String staffId;
  
  const StaffScheduleScreen({
    Key? key,
    required this.staffId,
  }) : super(key: key);
  
  @override
  State<StaffScheduleScreen> createState() => _StaffScheduleScreenState();
}
```

**Key Components**:
- `WeekView`: Calendar widget showing a week view of the schedule
- `DayView`: Calendar widget showing a day view of the schedule
- `TimeSlotList`: List of time slots for a specific day
- `AddTimeSlotButton`: Button to add a new time slot
- `DateSelector`: Widget for selecting a date

### TimeSlotCard

**Path**: `lib/src/features/member_staff/widgets/time_slot_card.dart`

Card displaying a time slot with actions.

```dart
class TimeSlotCard extends StatelessWidget {
  final TimeSlot timeSlot;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  
  const TimeSlotCard({
    Key? key,
    required this.timeSlot,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('${timeSlot.startTime} - ${timeSlot.endTime}'),
        subtitle: Text(timeSlot.isBooked ? 'Booked' : 'Available'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
```

### AddTimeSlotDialog

**Path**: `lib/src/features/member_staff/widgets/add_time_slot_dialog.dart`

Dialog for adding a new time slot.

```dart
class AddTimeSlotDialog extends StatefulWidget {
  final String staffId;
  final DateTime date;
  
  const AddTimeSlotDialog({
    Key? key,
    required this.staffId,
    required this.date,
  }) : super(key: key);
  
  @override
  State<AddTimeSlotDialog> createState() => _AddTimeSlotDialogState();
}
```

**Key Components**:
- `TimeRangePicker`: Widget for selecting start and end times
- `BookedSwitch`: Switch for marking a time slot as booked
- `AddButton`: Button to add the time slot

## Member-Staff Assignment

### MemberStaffListScreen

**Path**: `lib/src/features/member_staff/screens/assignment/member_staff_list_screen.dart`

Screen for viewing staff assigned to a member.

```dart
class MemberStaffListScreen extends StatefulWidget {
  final String memberId;
  
  const MemberStaffListScreen({
    Key? key,
    required this.memberId,
  }) : super(key: key);
  
  @override
  State<MemberStaffListScreen> createState() => _MemberStaffListScreenState();
}
```

**Key Components**:
- `StaffList`: List of staff assigned to the member
- `AddStaffButton`: Button to assign a new staff
- `StaffFilter`: Dropdown for filtering staff by type

### StaffCard

**Path**: `lib/src/features/member_staff/widgets/staff_card.dart`

Card displaying staff information with actions.

```dart
class StaffCard extends StatelessWidget {
  final Staff staff;
  final VoidCallback? onViewSchedule;
  final VoidCallback? onUnassign;
  
  const StaffCard({
    Key? key,
    required this.staff,
    this.onViewSchedule,
    this.onUnassign,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: staff.photoUrl != null
                  ? NetworkImage(staff.photoUrl!)
                  : null,
              child: staff.photoUrl == null
                  ? Text(staff.name[0])
                  : null,
            ),
            title: Text(staff.name),
            subtitle: Text(staff.mobile),
          ),
          ButtonBar(
            children: [
              TextButton(
                onPressed: onViewSchedule,
                child: Text('View Schedule'),
              ),
              TextButton(
                onPressed: onUnassign,
                child: Text('Unassign'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

### AssignStaffScreen

**Path**: `lib/src/features/member_staff/screens/assignment/assign_staff_screen.dart`

Screen for assigning a staff to a member.

```dart
class AssignStaffScreen extends StatefulWidget {
  final String memberId;
  
  const AssignStaffScreen({
    Key? key,
    required this.memberId,
  }) : super(key: key);
  
  @override
  State<AssignStaffScreen> createState() => _AssignStaffScreenState();
}
```

**Key Components**:
- `StaffSearchBar`: Search bar for finding staff
- `StaffSearchResults`: List of staff matching the search query
- `AssignButton`: Button to assign the selected staff

## Common Widgets

### LoadingIndicator

**Path**: `lib/src/widgets/loading_indicator.dart`

Widget for showing a loading indicator.

```dart
class LoadingIndicator extends StatelessWidget {
  final String? message;
  
  const LoadingIndicator({
    Key? key,
    this.message,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          if (message != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(message!),
            ),
        ],
      ),
    );
  }
}
```

### ErrorDisplay

**Path**: `lib/src/widgets/error_display.dart`

Widget for displaying error messages.

```dart
class ErrorDisplay extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;
  
  const ErrorDisplay({
    Key? key,
    required this.error,
    this.onRetry,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Colors.red, size: 48),
          Text(error),
          if (onRetry != null)
            ElevatedButton(
              onPressed: onRetry,
              child: Text('Retry'),
            ),
        ],
      ),
    );
  }
}
```

### EmptyStateDisplay

**Path**: `lib/src/widgets/empty_state_display.dart`

Widget for displaying empty state messages.

```dart
class EmptyStateDisplay extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;
  
  const EmptyStateDisplay({
    Key? key,
    required this.message,
    this.icon = Icons.info,
    this.onAction,
    this.actionLabel,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48),
          Text(message),
          if (onAction != null && actionLabel != null)
            ElevatedButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}
```

### ConfirmationDialog

**Path**: `lib/src/widgets/confirmation_dialog.dart`

Dialog for confirming actions.

```dart
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  
  const ConfirmationDialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    required this.onConfirm,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(cancelLabel),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
```

## Form Components

### MobileNumberInput

**Path**: `lib/src/widgets/form/mobile_number_input.dart`

Custom text field for entering mobile numbers.

```dart
class MobileNumberInput extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  
  const MobileNumberInput({
    Key? key,
    required this.controller,
    this.errorText,
    this.onChanged,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Mobile Number',
        prefixText: '+91 ',
        errorText: errorText,
      ),
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      onChanged: onChanged,
    );
  }
}
```

### OtpInput

**Path**: `lib/src/widgets/form/otp_input.dart`

Custom widget for entering OTP digits.

```dart
class OtpInput extends StatelessWidget {
  final ValueChanged<String> onOtpChanged;
  final int length;
  
  const OtpInput({
    Key? key,
    required this.onOtpChanged,
    this.length = 6,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        length,
        (index) => SizedBox(
          width: 40,
          child: TextField(
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              // Handle OTP input
            },
          ),
        ),
      ),
    );
  }
}
```

### AadhaarInput

**Path**: `lib/src/widgets/form/aadhaar_input.dart`

Custom text field for entering Aadhaar numbers.

```dart
class AadhaarInput extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  
  const AadhaarInput({
    Key? key,
    required this.controller,
    this.errorText,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Aadhaar Number',
        errorText: errorText,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(12),
      ],
    );
  }
}
```

### PhotoCapture

**Path**: `lib/src/widgets/form/photo_capture.dart`

Widget for capturing or selecting a photo.

```dart
class PhotoCapture extends StatefulWidget {
  final ValueChanged<File> onPhotoSelected;
  
  const PhotoCapture({
    Key? key,
    required this.onPhotoSelected,
  }) : super(key: key);
  
  @override
  State<PhotoCapture> createState() => _PhotoCaptureState();
}
```

## Navigation Components

### BottomNavBar

**Path**: `lib/src/widgets/navigation/bottom_nav_bar.dart`

Bottom navigation bar for the Member Staff module.

```dart
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  
  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Staff',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Schedule',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
```

### AppDrawer

**Path**: `lib/src/widgets/navigation/app_drawer.dart`

Drawer for the Member Staff module.

```dart
class AppDrawer extends StatelessWidget {
  final Map<String, dynamic> memberContext;
  
  const AppDrawer({
    Key? key,
    required this.memberContext,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Member Staff'),
                Text('Member: ${memberContext['name']}'),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Staff List'),
            onTap: () {
              // Navigate to staff list
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('Schedule'),
            onTap: () {
              // Navigate to schedule
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              // Navigate to settings
            },
          ),
        ],
      ),
    );
  }
}
```

## State Management

### MemberStaffProvider

**Path**: `lib/src/features/member_staff/providers/member_staff_provider.dart`

Provider for managing the state of the Member Staff module.

```dart
class MemberStaffProvider extends ChangeNotifier {
  final MemberStaffApi api;
  
  MemberStaffProvider({
    required this.api,
  });
  
  // Staff state
  List<Staff> _staff = [];
  Staff? _selectedStaff;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<Staff> get staff => _staff;
  Staff? get selectedStaff => _selectedStaff;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Methods
  Future<void> loadStaff();
  Future<void> checkStaffMobile(String mobile);
  Future<void> sendOtp(String mobile);
  Future<void> verifyOtp(String mobile, String otp);
  Future<void> createStaff(Staff staff);
  Future<void> verifyStaff(String staffId, Map<String, dynamic> data);
  Future<void> loadStaffSchedule(String staffId, DateTime startDate, DateTime endDate);
  Future<void> addTimeSlot(String staffId, TimeSlot timeSlot);
  Future<void> updateTimeSlot(String staffId, String timeSlotId, TimeSlot timeSlot);
  Future<void> removeTimeSlot(String staffId, String timeSlotId);
  Future<void> assignStaff(String memberId, String staffId);
  Future<void> unassignStaff(String memberId, String staffId);
}
```

## Theming Components

### AppTheme

**Path**: `lib/src/core/theme/app_theme.dart`

Theme data for the Member Staff module.

```dart
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      // Other theme properties
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: Colors.blue,
      // Other theme properties
    );
  }
}
```

### ThemeProvider

**Path**: `lib/src/core/theme/theme_provider.dart`

Provider for managing the app theme.

```dart
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  void setLightMode() {
    _themeMode = ThemeMode.light;
    notifyListeners();
  }
  
  void setDarkMode() {
    _themeMode = ThemeMode.dark;
    notifyListeners();
  }
  
  void setSystemMode() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
}
```

## Conclusion

This document provides a comprehensive overview of all UI components and widgets used in the Member Staff module. It serves as a reference for developers to understand the project structure and UI elements.

For more detailed information about each component, please refer to the source code and inline documentation.
