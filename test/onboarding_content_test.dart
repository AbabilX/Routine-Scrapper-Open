import 'package:flutter_test/flutter_test.dart';

import 'package:diu/ui/onboarding/onboarding_pages.dart';

void main() {
  test('tour covers search, reminder, PDF, and privacy', () {
    expect(onboardingPages, hasLength(4));
    final text = onboardingPages
        .map((page) => '${page.kicker} ${page.title} ${page.body}')
        .join(' ');
    expect(text, contains('Open source'));
    expect(text.toLowerCase(), contains('privacy'));
    expect(text, contains('68_C'));
    expect(text, contains('রিমাইন্ডার'));
    expect(text, contains('PDF'));
    expect(text, contains('MIT'));
  });
}
