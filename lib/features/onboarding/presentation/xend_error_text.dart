import 'package:xend/xend.dart';

/// Short, user-facing text for a wallet error. Shared by onboarding and settings.
String xendErrorText(Object e) => switch (e) {
      InvalidRecoveryPhrase() =>
        'That phrase isn’t valid. Check each word and its order.',
      UserCancelledAuth() => 'Face ID was cancelled.',
      NetworkError() => 'Can’t reach the network. Check your connection.',
      RateLimited() => 'Too many attempts. Wait a moment and try again.',
      BackupUnavailable() =>
        'iCloud Keychain is unavailable. Turn it on in Settings to back up '
            'your wallet.',
      KeyInvalidated() =>
        'Face ID changed on this device. Reopen Nimbus to restore your key.',
      SecureElementError() =>
        'Face ID or secure storage isn’t available on this device.',
      _ => 'Something went wrong. Try again.',
    };
