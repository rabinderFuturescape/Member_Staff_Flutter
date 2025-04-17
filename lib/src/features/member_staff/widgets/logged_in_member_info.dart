import 'package:flutter/material.dart';
import '../../../core/auth/token_manager.dart';

/// A widget that displays information about the logged-in member.
class LoggedInMemberInfo extends StatefulWidget {
  const LoggedInMemberInfo({Key? key}) : super(key: key);

  @override
  State<LoggedInMemberInfo> createState() => _LoggedInMemberInfoState();
}

class _LoggedInMemberInfoState extends State<LoggedInMemberInfo> {
  String? _memberName;
  String? _unitNumber;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMemberInfo();
  }

  Future<void> _loadMemberInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final memberName = await TokenManager.getUserName();
      final unitNumber = await TokenManager.getUnitNumber();

      setState(() {
        _memberName = memberName;
        _unitNumber = unitNumber;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 40,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    if (_memberName == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Icon(
            Icons.person,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Logged in as: $_memberName',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                if (_unitNumber != null)
                  Text(
                    'Flat-$_unitNumber',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
