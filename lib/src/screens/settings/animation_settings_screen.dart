import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/animation_preferences.dart';
import '../../widgets/animated_form_fields.dart';
import '../../utils/animation_constants.dart';
import '../../widgets/micro_interactions.dart';

/// Screen for managing animation settings.
class AnimationSettingsScreen extends StatelessWidget {
  const AnimationSettingsScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animation Settings'),
      ),
      body: Consumer<AnimationPreferencesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildInfoCard(context),
              const SizedBox(height: 24),
              _buildAnimationToggle(context, provider),
              const SizedBox(height: 16),
              _buildReducedMotionToggle(context, provider),
              const SizedBox(height: 24),
              _buildAnimationPreview(context, provider),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Animation Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Customize the animation experience in the app. You can disable animations completely or enable reduced motion for a more subtle experience.',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAnimationToggle(BuildContext context, AnimationPreferencesProvider provider) {
    return SwitchListTile(
      title: const Text(
        'Enable Animations',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: const Text(
        'Turn on/off all animations in the app',
        style: TextStyle(
          fontSize: 14,
        ),
      ),
      value: provider.animationsEnabled,
      onChanged: (value) {
        provider.setAnimationsEnabled(value);
      },
      secondary: Icon(
        Icons.animation,
        color: provider.animationsEnabled
            ? Theme.of(context).primaryColor
            : Colors.grey,
      ),
    );
  }
  
  Widget _buildReducedMotionToggle(BuildContext context, AnimationPreferencesProvider provider) {
    return SwitchListTile(
      title: const Text(
        'Reduced Motion',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: const Text(
        'Use simpler and shorter animations',
        style: TextStyle(
          fontSize: 14,
        ),
      ),
      value: provider.reducedMotion,
      onChanged: provider.animationsEnabled
          ? (value) {
              provider.setReducedMotionEnabled(value);
            }
          : null,
      secondary: Icon(
        Icons.accessibility,
        color: provider.animationsEnabled && provider.reducedMotion
            ? Theme.of(context).primaryColor
            : Colors.grey,
      ),
    );
  }
  
  Widget _buildAnimationPreview(BuildContext context, AnimationPreferencesProvider provider) {
    final duration = provider.getAnimationDuration(AnimationConstants.mediumDuration);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Animation Preview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPreviewItem(
                  context,
                  'Bounce',
                  BounceWidget(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.touch_app,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  provider.animationsEnabled,
                ),
                _buildPreviewItem(
                  context,
                  'Pulse',
                  PulseWidget(
                    animate: provider.animationsEnabled,
                    duration: duration,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  provider.animationsEnabled,
                ),
                _buildPreviewItem(
                  context,
                  'Shake',
                  ShakeWidget(
                    shake: false,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.warning,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  provider.animationsEnabled,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: AnimatedButton(
                text: 'Test Animation',
                onPressed: () {
                  // Show a snackbar with animation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Animation test'),
                      duration: provider.getAnimationDuration(const Duration(seconds: 2)),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                isOutlined: true,
                width: 200,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPreviewItem(BuildContext context, String label, Widget child, bool enabled) {
    return Column(
      children: [
        child,
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: enabled ? null : Colors.grey,
          ),
        ),
      ],
    );
  }
}
