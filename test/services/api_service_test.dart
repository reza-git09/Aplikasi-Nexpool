import 'package:flutter_test/flutter_test.dart';
import 'package:nexpool/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'removes a stale saved backend URL and uses the configured backend',
    () async {
      SharedPreferences.setMockInitialValues({
        'custom_api_base_url': 'http://172.20.10.2:8000/api',
      });

      await ApiService.init();

      final preferences = await SharedPreferences.getInstance();

      expect(ApiService.baseUrl, ApiService.defaultBaseUrl);
      expect(preferences.containsKey('custom_api_base_url'), isFalse);
    },
  );
}
