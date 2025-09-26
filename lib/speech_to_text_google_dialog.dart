library speech_to_text_google_dialog;

import 'dart:async';
import 'package:flutter/services.dart';

/// Provides ability to show the Google speech-to-text dialog
class SpeechToTextGoogleDialog {
  static SpeechToTextGoogleDialog? _instance;
  final EventChannel _stream = const EventChannel('SpeechToTextGoogleStream');
  final _platform = const MethodChannel('SpeechToTextGoogleChannel');

  /// This function provides singleton object of [SpeechToTextGoogleDialog]
  static SpeechToTextGoogleDialog getInstance() {
    _instance ??= SpeechToTextGoogleDialog();
    return _instance!;
  }

  /// Show Google speech-to-text dialog
  ///
  /// [onTextReceived] → callback for recognized speech text
  /// [onCancel] → callback when user cancels dialog
  /// [onError] → callback when an error or no speech occurs
  /// [locale] → pass e.g. "en-US" to change language
  Future<bool> showGoogleDialog({
    required Function(String text) onTextReceived,
    Function()? onCancel,
    Function(String error)? onError,
    String? locale,
  }) async {
    try {
      final bool? result =
      await _platform.invokeMethod('showSpeechToTextDialog', {
        'locale': locale,
      });

      _stream.receiveBroadcastStream().listen((event) {
          // Normal speech text result
          if (event is String) {
            onTextReceived(event);
          }else{
            // No speech detected
            if (onCancel != null) onCancel();
          }
        },
        onError: (error) {
          final platformError = error as PlatformException;
          if (platformError.code == "CANCELLED") {
            if (onCancel != null) onCancel();
          } else {
            if (onError != null) {
              onError("${platformError.code}: ${platformError.message}");
            }
          }
        },
      );

      return result ?? false;
    } on PlatformException {
      return false;
    }
  }
}
