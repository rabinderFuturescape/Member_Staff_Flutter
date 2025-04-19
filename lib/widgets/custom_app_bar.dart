import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.showBackButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return AppBar(
      title: Text(title),
      automaticallyImplyLeading: showBackButton,
      actions: actions ?? [
        if (authProvider.isAuthenticated)
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Show user profile or settings
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('User Profile'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${authProvider.user?.name ?? ""}'),
                      Text('Email: ${authProvider.user?.email ?? ""}'),
                      Text('Role: ${authProvider.user?.role ?? ""}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Close'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        authProvider.logout();
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
