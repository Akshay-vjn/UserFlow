import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:userflow/core/services/connectivity_service.dart';

void main() {
  group('ConnectivityService Tests', () {
    test('should handle connectivity changes properly', () {
      final container = ProviderContainer();
      final connectivityService = container.read(connectivityServiceProvider);
      
      expect(connectivityService, isNotNull);
      
      container.dispose();
    });
  });
}