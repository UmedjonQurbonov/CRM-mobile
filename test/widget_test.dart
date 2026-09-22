import 'package:crm_mobile/app.dart';
import 'package:crm_mobile/core/di/injection.dart';
import 'package:crm_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await initDependencies();
  });

  tearDown(() async {
    await resetDependencies();
  });

  testWidgets('App smoke test renders login screen initially', (WidgetTester tester) async {
    await tester.pumpWidget(const CrmApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('CRM Retail POS'), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
