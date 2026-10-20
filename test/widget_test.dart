import 'package:flutter_test/flutter_test.dart';
import 'package:movie_library/main.dart';

void main() {
  testWidgets('shows title and empty-search message',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MovieLibraryApp());
    expect(find.text('Movie Library'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pump();
    expect(find.text('No movies found'), findsOneWidget);
  });

  testWidgets('tapping a bonus badge updates every card',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MovieLibraryApp());
    expect(find.text('20%'), findsWidgets);

    await tester.tap(find.text('20%').first);
    await tester.pump();

    expect(find.text('20%'), findsNothing);
    expect(find.text('19%'), findsWidgets);
  });
}
