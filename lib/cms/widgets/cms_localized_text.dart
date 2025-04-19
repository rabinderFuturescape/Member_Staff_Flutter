import 'package:flutter/material.dart';
import '../localization/cms_localizations.dart';

/// Widget for displaying localized text
class CMSLocalizedText extends StatelessWidget {
  /// The key to translate
  final String translationKey;
  
  /// Arguments for the translation
  final Map<String, String>? args;
  
  /// Text style
  final TextStyle? style;
  
  /// Text alignment
  final TextAlign? textAlign;
  
  /// Text overflow
  final TextOverflow? overflow;
  
  /// Maximum number of lines
  final int? maxLines;
  
  /// Whether to use soft wrap
  final bool? softWrap;
  
  /// Create a new CMS localized text
  const CMSLocalizedText(
    this.translationKey, {
    Key? key,
    this.args,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final localizations = CMSLocalizations.of(context);
    
    return FutureBuilder<String>(
      future: localizations.translate(translationKey, args: args),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While waiting for the translation, use the synchronous version
          return Text(
            localizations.translateSync(translationKey, args: args),
            style: style,
            textAlign: textAlign,
            overflow: overflow,
            maxLines: maxLines,
            softWrap: softWrap,
          );
        }
        
        return Text(
          snapshot.data ?? translationKey,
          style: style,
          textAlign: textAlign,
          overflow: overflow,
          maxLines: maxLines,
          softWrap: softWrap,
        );
      },
    );
  }
}
