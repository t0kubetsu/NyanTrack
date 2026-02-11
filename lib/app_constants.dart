import 'package:http_certificate_pinning/http_certificate_pinning.dart';

class AppConstants {
  static const String locationEndpoint = 'https://yamileth-hypobaric-victoria.ngrok-free.dev/location';
  static const String deviceEndpoint = 'https://yamileth-hypobaric-victoria.ngrok-free.dev/device';
  static const String allowedSHAFingerprints = '8D:37:2E:8D:5F:51:06:97:39:CB:44:C7:CF:0E:F8:A5:44:F8:6E:22:CD:B9:87:A7:31:85:27:91:F0:D5:68:14';
  static SecureHttpClient getSecureClient() {
    return SecureHttpClient.build([allowedSHAFingerprints]);
  }
}