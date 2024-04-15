import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'license_notifier.g.dart';

@riverpod
class LicenseNotifier extends _$LicenseNotifier {
  @override
  Future<List<LicenseEntry>> build() async {
    final entries = <LicenseEntry>[];
    await for (final license in LicenseRegistry.licenses) {
      entries.add(license);
    }
    return entries;
  }
}
