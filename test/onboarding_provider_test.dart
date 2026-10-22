import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:myapp/providers/onboarding_provider.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('« Passer » termine l\'onboarding et prévient le routeur', () async {
    final onboarding = OnboardingProvider(completed: await OnboardingProvider.load());
    var notified = false;
    onboarding.addListener(() => notified = true);

    expect(onboarding.completed, isFalse);
    await onboarding.complete();

    // Le routeur écoute ce provider : sans notification, il renvoyait vers l'onboarding
    expect(onboarding.completed, isTrue);
    expect(notified, isTrue);
    expect(await OnboardingProvider.load(), isTrue);
  });
}
