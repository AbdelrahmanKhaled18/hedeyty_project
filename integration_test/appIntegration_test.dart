import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:yarb/main.dart';
import 'package:yarb/screens/events/event_list_screen.dart';
import 'package:yarb/screens/home_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  group("End-to-End Testing", () {
    testWidgets('Sign-Up and Create Event Test', (tester) async {
      // Launch the app using runApp
      runApp(const app());

      // Wait for the Start Screen
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('startScreen')), findsOneWidget);

      // Tap the Sign-Up Button on Start Screen
      await tester.tap(find.byKey(const Key('SignupButton')));
      await tester.pumpAndSettle();

      // Verify Sign-Up Screen
      expect(find.byKey(const Key('signupScreen')), findsOneWidget);

      // Fill the Sign-Up Form
      await tester.enterText(find.byKey(const Key('nameField')), 'omar');
      await tester.enterText(
          find.byKey(const Key('emailField')), 'omar@gmail.com');
      await tester.enterText(
          find.byKey(const Key('passwordField')), 'omar1234');

      // Ensure Visibility of the Sign-Up Button Before Tapping
      final signUpButton = find.byKey(const Key('signupButtonAction'));
      await tester.ensureVisible(signUpButton);

      // Tap the Sign-Up Button
      await tester.tap(signUpButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify Home Screen After Signup
      expect(find.byType(HomeScreen), findsOneWidget);

      // Tap the Floating Action Button to Create an Event
      final createEventButton = find.byKey(const Key('createEventButton'));
      await tester.ensureVisible(createEventButton);
      await tester.tap(createEventButton);
      await tester.pumpAndSettle();

      // Verify Event Creation Page Opened
      expect(find.byKey(const Key('eventCreationPage')), findsOneWidget);

      // Fill the Event Creation Form
      await tester.enterText(
          find.byKey(const Key('eventNameField')), 'Birthday Party');
      // Tap the Event Date Field to open the Date Picker
      final eventDateField = find.byKey(const Key('eventDateField'));
      await tester.tap(eventDateField);
      await tester.pumpAndSettle();

// Open the Year Selector (if available)
      final openYearSelector = find.textContaining(RegExp(r'\d{4}')); // Matches any 4-digit year
      if (openYearSelector.evaluate().isNotEmpty) {
        await tester.tap(openYearSelector);
        await tester.pumpAndSettle();
      }

// Scroll to the Desired Year and Select
      final yearOption = find.text('2024');
      if (yearOption.evaluate().isNotEmpty) {
        await tester.tap(yearOption);
        await tester.pumpAndSettle();
      } else {
        throw TestFailure('The year 2024 was not found.');
      }

      final monthOption = find.text('DEC');
      if (monthOption.evaluate().isNotEmpty) {
        await tester.tap(monthOption);
        await tester.pumpAndSettle();
      }

      await tester.tap(find.text('25'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('eventLocationField')), 'New York City');
      await tester.enterText(
          find.byKey(const Key('eventDescriptionField')), 'A special birthday party.');


      final eventSubmitButton = find.byKey(const Key('eventSubmitButton'));
      await tester.ensureVisible(eventSubmitButton);


      await tester.tap(eventSubmitButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));


      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      // Verify Home Screen After Pressing Back Button
      expect(find.byKey(const Key('homePage')), findsOneWidget);

      // Navigate to Event List Tab using Bottom Navigation Bar
      final eventTabButton = find.byKey(const Key('EventsTab'));
      await tester.tap(eventTabButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify Event List Page
      expect(find.byType(EventListScreen), findsOneWidget);

      final eventCard = find.byKey(const Key('eventCard_BirthdayParty'));
      await tester.tap(eventCard);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('giftListPage')), findsOneWidget);

      // Tap the Add Gift Button
      final addGiftButton = find.byKey(const Key('addGiftButton'));
      await tester.ensureVisible(addGiftButton);
      await tester.tap(addGiftButton);
      await tester.pumpAndSettle();


      expect(find.byKey(const Key('giftCreationPage')), findsOneWidget);



      // Fill the Gift Details
      await tester.enterText(find.byKey(const Key('giftNameField')), 'Smartwatch');
      await tester.enterText(find.byKey(const Key('giftCategoryField')), 'Electronics');
      await tester.enterText(find.byKey(const Key('giftDescriptionField')), 'Premium smartwatch with features.');
      await tester.enterText(find.byKey(const Key('giftPriceField')), '299.99');


      final submitGiftButton = find.byKey(const Key('giftSubmitButton'));
      await tester.ensureVisible(submitGiftButton);
      await tester.tap(submitGiftButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));


      expect(find.byKey(const Key('giftListPage')), findsOneWidget);





    });
  });


}