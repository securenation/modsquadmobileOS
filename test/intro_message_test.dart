import 'package:flutter_test/flutter_test.dart';
import 'package:modsquad_meetings/campaigns/intro_message.dart';

void main() {
  test('builds the advisor intro message', () {
    final message = generateIntroRequestMessage(
      targetFullName: 'Elena Vasquez',
      targetJobTitle: 'CISO',
      companyName: 'Meridian Health',
      startupName: 'Dante Security',
      reason: 'Warm intro to CISO',
      responseUrl: 'http://localhost:3000/i/token',
    );

    expect(message, contains('Elena Vasquez, CISO, Meridian Health'));
    expect(message, contains('Dante Security'));
    expect(message, contains('Why: Warm intro to CISO'));
    expect(message, contains('http://localhost:3000/i/token'));
  });
}
