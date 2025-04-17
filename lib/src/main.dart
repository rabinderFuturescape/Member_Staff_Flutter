import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/auth/token_manager.dart';
import 'features/member_staff/member_staff_module.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Member Staff App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthWrapper(),
    );
  }
}

/// Wrapper that checks authentication status and redirects accordingly.
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final isValid = await TokenManager.isTokenValid();
      
      setState(() {
        _isAuthenticated = isValid;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to check authentication: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(_error!),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _checkAuth,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isAuthenticated) {
      return const Scaffold(
        body: Center(
          child: Text('Please login from the parent OneApp'),
        ),
      );
    }

    // User is authenticated, show the Member Staff module
    return const MemberStaffModule(
      baseUrl: 'https://api.oneapp.example.com/api',
    );
  }
}
