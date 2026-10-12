import 'package:flutter_test/flutter_test.dart';
import 'package:habit_study_tracker/main.dart';

void main() {
  testWidgets('Приложение показывает Hello World', (tester) async {
    await tester.pumpWidget(const HabitStudyTrackerApp());
    expect(find.textContaining('Hello World!'), findsOneWidget);
  });
}
