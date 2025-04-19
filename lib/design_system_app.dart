import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'design_system/design_system.dart';

/// Design System App
///
/// A wrapper for the application that provides the design system.
class DesignSystemApp extends StatelessWidget {
  /// The child widget
  final Widget child;
  
  /// Create a design system app
  const DesignSystemApp({
    Key? key,
    required this.child,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => DesignSystemProvider()..initialize(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final themeProvider = Provider.of<ThemeProvider>(context);
          final designSystemProvider = Provider.of<DesignSystemProvider>(context);
          
          return MaterialApp(
            title: 'Member Staff App',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            builder: (context, child) {
              // Apply font size scaling
              final mediaQuery = MediaQuery.of(context);
              final textScaleFactor = designSystemProvider.fontSizeScale;
              
              return MediaQuery(
                data: mediaQuery.copyWith(
                  textScaleFactor: textScaleFactor,
                ),
                child: child!,
              );
            },
            home: child,
          );
        },
      ),
    );
  }
}
