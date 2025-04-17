import 'package:flutter/material.dart';
import 'api_exception.dart';

/// A utility class for handling errors in the application.
class ErrorHandler {
  /// Shows a snackbar with an error message.
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Shows a snackbar with a success message.
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Shows an error dialog with details.
  static Future<void> showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    VoidCallback? onRetry,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Dismiss'),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }

  /// Handles an API exception and shows appropriate UI feedback.
  static void handleApiException(
    BuildContext context,
    ApiException exception, {
    VoidCallback? onRetry,
  }) {
    final message = exception.userFriendlyMessage;

    // For authentication errors, show a dialog
    if (exception.statusCode == 401 || exception.statusCode == 403) {
      showErrorDialog(
        context,
        'Authentication Error',
        message,
        onRetry: onRetry,
      );
    } else if (exception.statusCode == 500 || exception.statusCode == 503) {
      // For server errors, show a dialog with retry option
      showErrorDialog(
        context,
        'Server Error',
        message,
        onRetry: onRetry,
      );
    } else {
      // For other errors, show a snackbar
      showErrorSnackBar(context, message);
    }
  }

  /// Handles a general exception and shows appropriate UI feedback.
  static void handleException(
    BuildContext context,
    dynamic exception, {
    VoidCallback? onRetry,
  }) {
    if (exception is ApiException) {
      handleApiException(context, exception, onRetry: onRetry);
    } else {
      showErrorSnackBar(context, 'An unexpected error occurred: $exception');
    }
  }
}
