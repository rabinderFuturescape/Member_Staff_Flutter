import 'package:flutter/material.dart';
import '../models/cms_models.dart';

/// Widget for displaying a grid of CMS features
class CMSFeatureGrid extends StatelessWidget {
  /// Features to display
  final List<CMSFeature> features;
  
  /// Number of columns
  final int crossAxisCount;
  
  /// Spacing between items
  final double spacing;
  
  /// Callback when a feature is tapped
  final Function(CMSFeature feature)? onFeatureTap;
  
  /// Create a new CMS feature grid
  const CMSFeatureGrid({
    Key? key,
    required this.features,
    this.crossAxisCount = 2,
    this.spacing = 16.0,
    this.onFeatureTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 1.0,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return _buildFeatureCard(context, feature);
      },
    );
  }
  
  /// Build a feature card
  Widget _buildFeatureCard(BuildContext context, CMSFeature feature) {
    // Parse the color
    Color color;
    try {
      color = Color(int.parse(feature.color.replaceAll('#', '0xFF')));
    } catch (e) {
      color = Theme.of(context).primaryColor;
    }
    
    // Parse the icon
    IconData icon;
    try {
      icon = IconData(
        int.parse(feature.icon, radix: 16),
        fontFamily: 'MaterialIcons',
      );
    } catch (e) {
      icon = Icons.settings;
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          if (onFeatureTap != null) {
            onFeatureTap!(feature);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 16),
              Text(
                feature.title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                feature.description,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
