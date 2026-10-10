import 'package:flutter_test/flutter_test.dart';
import 'package:quanlychitieu/main.dart';

void main() {
  testWidgets('Kiem tra khoi tao ung dung', (WidgetTester tester) async {
    await tester.pumpWidget(const UngDungQuanLyChiTieu());
    expect(find.byType(UngDungQuanLyChiTieu), findsOneWidget);
  });
}
