import 'package:flutter/material.dart';
import '../core/core.dart';
import '../widgets/widgets.dart';

/// Component Gallery Screen
///
/// A screen that showcases the design system components.
class ComponentGalleryScreen extends StatelessWidget {
  /// Create a component gallery screen
  const ComponentGalleryScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Component Gallery'),
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Buttons'),
              Tab(text: 'Inputs'),
              Tab(text: 'Cards'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ButtonsTab(),
            _InputsTab(),
            _CardsTab(),
          ],
        ),
      ),
    );
  }
}

/// Buttons Tab
class _ButtonsTab extends StatelessWidget {
  /// Create a buttons tab
  const _ButtonsTab({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Button Variants',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          Wrap(
            spacing: DSSpacing.sm,
            runSpacing: DSSpacing.sm,
            children: [
              DSButton(
                text: 'Primary',
                variant: DSButtonVariant.primary,
                onPressed: () {},
              ),
              DSButton(
                text: 'Secondary',
                variant: DSButtonVariant.secondary,
                onPressed: () {},
              ),
              DSButton(
                text: 'Tertiary',
                variant: DSButtonVariant.tertiary,
                onPressed: () {},
              ),
              DSButton(
                text: 'Danger',
                variant: DSButtonVariant.danger,
                onPressed: () {},
              ),
              DSButton(
                text: 'Success',
                variant: DSButtonVariant.success,
                onPressed: () {},
              ),
              DSButton(
                text: 'Warning',
                variant: DSButtonVariant.warning,
                onPressed: () {},
              ),
              DSButton(
                text: 'Info',
                variant: DSButtonVariant.info,
                onPressed: () {},
              ),
            ],
          ),
          
          const SizedBox(height: DSSpacing.lg),
          const Text(
            'Button Sizes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          Wrap(
            spacing: DSSpacing.sm,
            runSpacing: DSSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              DSButton(
                text: 'Small',
                size: DSButtonSize.small,
                onPressed: () {},
              ),
              DSButton(
                text: 'Medium',
                size: DSButtonSize.medium,
                onPressed: () {},
              ),
              DSButton(
                text: 'Large',
                size: DSButtonSize.large,
                onPressed: () {},
              ),
            ],
          ),
          
          const SizedBox(height: DSSpacing.lg),
          const Text(
            'Button States',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          Wrap(
            spacing: DSSpacing.sm,
            runSpacing: DSSpacing.sm,
            children: [
              DSButton(
                text: 'Enabled',
                onPressed: () {},
              ),
              const DSButton(
                text: 'Disabled',
                isDisabled: true,
              ),
              const DSButton(
                text: 'Loading',
                isLoading: true,
                onPressed: null,
              ),
            ],
          ),
          
          const SizedBox(height: DSSpacing.lg),
          const Text(
            'Button with Icons',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          Wrap(
            spacing: DSSpacing.sm,
            runSpacing: DSSpacing.sm,
            children: [
              DSButton(
                text: 'Icon Left',
                icon: Icons.add,
                onPressed: () {},
              ),
              DSButton(
                text: 'Icon Right',
                icon: Icons.arrow_forward,
                isIconRight: true,
                onPressed: () {},
              ),
            ],
          ),
          
          const SizedBox(height: DSSpacing.lg),
          const Text(
            'Full Width Button',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          DSButton(
            text: 'Full Width Button',
            isFullWidth: true,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

/// Inputs Tab
class _InputsTab extends StatelessWidget {
  /// Create an inputs tab
  const _InputsTab({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Text Field Variants',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          const DSTextField(
            labelText: 'Outlined Text Field',
            hintText: 'Enter text',
            variant: DSTextFieldVariant.outlined,
          ),
          const SizedBox(height: DSSpacing.md),
          const DSTextField(
            labelText: 'Filled Text Field',
            hintText: 'Enter text',
            variant: DSTextFieldVariant.filled,
          ),
          const SizedBox(height: DSSpacing.md),
          const DSTextField(
            labelText: 'Underlined Text Field',
            hintText: 'Enter text',
            variant: DSTextFieldVariant.underlined,
          ),
          
          const SizedBox(height: DSSpacing.lg),
          const Text(
            'Text Field Sizes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          const DSTextField(
            labelText: 'Small Text Field',
            hintText: 'Enter text',
            size: DSTextFieldSize.small,
            isFullWidth: false,
          ),
          const SizedBox(height: DSSpacing.md),
          const DSTextField(
            labelText: 'Medium Text Field',
            hintText: 'Enter text',
            size: DSTextFieldSize.medium,
            isFullWidth: false,
          ),
          const SizedBox(height: DSSpacing.md),
          const DSTextField(
            labelText: 'Large Text Field',
            hintText: 'Enter text',
            size: DSTextFieldSize.large,
            isFullWidth: false,
          ),
          
          const SizedBox(height: DSSpacing.lg),
          const Text(
            'Text Field States',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          const DSTextField(
            labelText: 'Enabled Text Field',
            hintText: 'Enter text',
          ),
          const SizedBox(height: DSSpacing.md),
          const DSTextField(
            labelText: 'Disabled Text Field',
            hintText: 'Enter text',
            enabled: false,
          ),
          const SizedBox(height: DSSpacing.md),
          const DSTextField(
            labelText: 'Read-Only Text Field',
            hintText: 'Enter text',
            readOnly: true,
          ),
          const SizedBox(height: DSSpacing.md),
          const DSTextField(
            labelText: 'Error Text Field',
            hintText: 'Enter text',
            errorText: 'This field has an error',
          ),
          
          const SizedBox(height: DSSpacing.lg),
          const Text(
            'Text Field with Icons',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          const DSTextField(
            labelText: 'Prefix Icon',
            hintText: 'Enter text',
            prefixIcon: Icons.search,
          ),
          const SizedBox(height: DSSpacing.md),
          const DSTextField(
            labelText: 'Suffix Icon',
            hintText: 'Enter text',
            suffixIcon: Icons.clear,
          ),
          
          const SizedBox(height: DSSpacing.lg),
          const Text(
            'Text Field with Helper Text',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          const DSTextField(
            labelText: 'Helper Text',
            hintText: 'Enter text',
            helperText: 'This is a helper text',
          ),
          
          const SizedBox(height: DSSpacing.lg),
          const Text(
            'Text Field with Counter',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          const DSTextField(
            labelText: 'Counter Text',
            hintText: 'Enter text',
            counterText: '0/100',
          ),
          
          const SizedBox(height: DSSpacing.lg),
          const Text(
            'Multi-line Text Field',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          const DSTextField(
            labelText: 'Multi-line Text Field',
            hintText: 'Enter text',
            maxLines: 5,
          ),
        ],
      ),
    );
  }
}

/// Cards Tab
class _CardsTab extends StatelessWidget {
  /// Create a cards tab
  const _CardsTab({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Card Variants',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          DSCard(
            variant: DSCardVariant.elevated,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Elevated Card',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: DSSpacing.xs),
                const Text(
                  'This is an elevated card with a shadow.',
                ),
                const SizedBox(height: DSSpacing.sm),
                DSButton(
                  text: 'Action',
                  size: DSButtonSize.small,
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: DSSpacing.md),
          DSCard(
            variant: DSCardVariant.outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Outlined Card',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: DSSpacing.xs),
                const Text(
                  'This is an outlined card with a border.',
                ),
                const SizedBox(height: DSSpacing.sm),
                DSButton(
                  text: 'Action',
                  size: DSButtonSize.small,
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: DSSpacing.md),
          DSCard(
            variant: DSCardVariant.filled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filled Card',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: DSSpacing.xs),
                const Text(
                  'This is a filled card with a background color.',
                ),
                const SizedBox(height: DSSpacing.sm),
                DSButton(
                  text: 'Action',
                  size: DSButtonSize.small,
                  onPressed: () {},
                ),
              ],
            ),
          ),
          
          const SizedBox(height: DSSpacing.lg),
          const Text(
            'Card with Custom Styling',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          DSCard(
            backgroundColor: DSColors.primaryBackground,
            borderRadius: DSBorders.radiusLg,
            elevation: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Custom Card',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: DSSpacing.xs),
                const Text(
                  'This is a card with custom styling.',
                ),
                const SizedBox(height: DSSpacing.sm),
                DSButton(
                  text: 'Action',
                  size: DSButtonSize.small,
                  onPressed: () {},
                ),
              ],
            ),
          ),
          
          const SizedBox(height: DSSpacing.lg),
          const Text(
            'Card with Tap Action',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: DSSpacing.sm),
          DSCard(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Card tapped'),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Tappable Card',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: DSSpacing.xs),
                Text(
                  'Tap this card to trigger an action.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
