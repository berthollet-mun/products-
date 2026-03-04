import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:product/main.dart';
import 'package:product/services/database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App shows login screen', (WidgetTester tester) async {
    Get.put<DatabaseService>(DatabaseService(), permanent: true);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Gestion de Stock'), findsOneWidget);
    expect(find.text('SE CONNECTER'), findsOneWidget);
  });
}
