import 'package:flutter/material.dart';
import '../core/core.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';
import 'theme_preview_screen.dart';
import 'component_gallery_screen.dart';

/// Design Console Screen
///
/// A screen that allows for previewing and customizing the design system components.
class DesignConsoleScreen extends StatefulWidget {
  /// Create a design console screen
  const DesignConsoleScreen({Key? key}) : super(key: key);
  
  @override
  State<DesignConsoleScreen> createState() => _DesignConsoleScreenState();
}

class _DesignConsoleScreenState extends State<DesignConsoleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design Console'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Theme Preview'),
            Tab(text: 'Component Gallery'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            tooltip: 'Toggle Theme',
            onPressed: () {
              final themeProvider = ThemeProvider.of(context);
              themeProvider.toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ThemePreviewScreen(),
          ComponentGalleryScreen(),
        ],
      ),
    );
  }
  
  /// Show the settings dialog
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => const _SettingsDialog(),
    );
  }
}

/// Settings Dialog
class _SettingsDialog extends StatelessWidget {
  /// Create a settings dialog
  const _SettingsDialog({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final designSystemProvider = DesignSystemProvider.of(context);
    
    return AlertDialog(
      title: const Text('Design System Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Font Size Scale',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: DSSpacing.xs),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    designSystemProvider.decreaseFontSize();
                  },
                ),
                Expanded(
                  child: Slider(
                    value: designSystemProvider.fontSizeScale,
                    min: 0.8,
                    max: 1.5,
                    divisions: 7,
                    label: designSystemProvider.fontSizeScale.toStringAsFixed(1),
                    onChanged: (value) {
                      designSystemProvider.setFontSizeScale(value);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    designSystemProvider.increaseFontSize();
                  },
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.md),
            SwitchListTile(
              title: const Text('Animations Enabled'),
              value: designSystemProvider.animationsEnabled,
              onChanged: (value) {
                designSystemProvider.setAnimationsEnabled(value);
              },
            ),
            SwitchListTile(
              title: const Text('Reduced Motion'),
              value: designSystemProvider.reducedMotion,
              onChanged: (value) {
                designSystemProvider.setReducedMotion(value);
              },
            ),
            SwitchListTile(
              title: const Text('High Contrast'),
              value: designSystemProvider.highContrast,
              onChanged: (value) {
                designSystemProvider.setHighContrast(value);
              },
            ),
          ],
        ),
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
            designSystemProvider.resetFontSize();
            designSystemProvider.setAnimationsEnabled(true);
            designSystemProvider.setReducedMotion(false);
            designSystemProvider.setHighContrast(false);
          },
          child: const Text('Reset to Defaults'),
        ),
      ],
    );
  }
}
