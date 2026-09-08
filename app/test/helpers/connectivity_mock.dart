import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// The offline banner asks connectivity_plus on every AppScaffold. Tests have
/// no platform, so answer "wifi" and give the status stream a handler.
void mockConnectivity() {
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(
    const MethodChannel('dev.fluttercommunity.plus/connectivity'),
    (call) async => call.method == 'check' ? <String>['wifi'] : null,
  );
  messenger.setMockStreamHandler(
    const EventChannel('dev.fluttercommunity.plus/connectivity_status'),
    MockStreamHandler.inline(
      onListen: (_, sink) => sink.success(<String>['wifi']),
    ),
  );
}
