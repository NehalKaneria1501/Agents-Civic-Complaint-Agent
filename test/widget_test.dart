import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agentsciviccomplaintagent/main.dart';

void main() {
  testWidgets('Full Auth & Onboarding Flow: Splash -> Permissions -> Sign In -> Forgot PIN -> OTP -> MainApp', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // 1. Launch App from Splash
    await tester.pumpWidget(const CivicAgentApp(startWithMainApp: false));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Splash Screen
    expect(find.text('CivicAgent'), findsOneWidget);
    expect(find.text('Ahmedabad Municipal Corporation'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Launch Instant Demo (Skip Login)'), findsOneWidget);

    // 2. Tap Get Started -> Navigate to Permissions Screen
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Verify Permissions Screen
    expect(find.text('Municipal Device Permissions'), findsOneWidget);
    expect(find.text('Allow All Required Permissions'), findsOneWidget);
    expect(find.text('Camera & Live Reticle'), findsOneWidget);
    expect(find.text('Precise GPS Coordinates'), findsOneWidget);
    expect(find.text('Save & Continue to Sign In'), findsOneWidget);

    // Tap master "Allow All Required Permissions"
    await tester.tap(find.text('Allow All Required Permissions'));
    await tester.pumpAndSettle();

    // 3. Tap "Save & Continue to Sign In" -> Navigate to Sign In Screen
    await tester.tap(find.text('Save & Continue to Sign In'));
    await tester.pumpAndSettle();

    // Verify Sign In Screen
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Citizen Login'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Sign In with OTP'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);

    // 4. Test Forgot Password Navigation
    await tester.tap(find.text('Forgot Password?'));
    await tester.pumpAndSettle();

    expect(find.text('Reset Citizen Password'), findsOneWidget);
    expect(find.text('Send Verification OTP'), findsOneWidget);

    // Return to Sign In via back button
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    // 5. From Sign In, tap "Sign In with OTP" -> Navigate to OTP Screen
    await tester.tap(find.text('Sign In with OTP'));
    await tester.pumpAndSettle();

    // Verify OTP Verification Screen
    expect(find.text('OTP Verification'), findsOneWidget);
    expect(find.text('Auto-fill (428915)'), findsOneWidget);

    // Auto-fill OTP & Verify
    await tester.tap(find.text('Auto-fill (428915)'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Verify & Proceed'));
    await tester.pumpAndSettle();

    // Verify We are now in Main App Shell
    expect(find.text('CivicAgent'), findsOneWidget);
    expect(find.text('AMC Ward 42 Agent'), findsOneWidget);
  });

  testWidgets('Stitch Civic Issue Reporting Agent UI and Flow Test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // 1. Build and render the app directly in mainApp shell
    await tester.pumpWidget(const CivicAgentApp(startWithMainApp: true));
    await tester.pumpAndSettle();

    // Verify Stitch App Bar & Branding
    expect(find.text('CivicAgent'), findsOneWidget);
    expect(find.text('AMC Ward 42 Agent'), findsOneWidget);
    expect(find.text('Snap & Report Issue'), findsOneWidget);
    expect(find.text('Quick Categories'), findsOneWidget);
    expect(find.text('Recent Ward Ticker'), findsOneWidget);

    // 2. Tap on "Agent" tab in bottom navigation
    final agentNavFinder = find.text('Agent');
    expect(agentNavFinder, findsOneWidget);
    await tester.tap(agentNavFinder);
    await tester.pumpAndSettle();

    // Verify Agent Chat Screen
    expect(find.text('CivicBot Assistant'), findsOneWidget);
    expect(find.textContaining('Image Analysis:'), findsOneWidget);
    expect(find.textContaining('Tracking ID Generated'), findsAtLeastNWidgets(1));
    expect(find.textContaining('#AMC-9482'), findsAtLeastNWidgets(1));

    // 3. Tap "View Ticket" button to open Ticket Details screen
    final viewTicketButton = find.text('View Ticket').first;
    expect(viewTicketButton, findsOneWidget);
    await tester.tap(viewTicketButton);
    await tester.pumpAndSettle();

    // Verify Ticket Details view
    expect(find.text('Ticket Details'), findsOneWidget);
    expect(find.text('Photographic Evidence'), findsOneWidget);
    expect(find.text('Status History & Timeline'), findsOneWidget);
    expect(find.text('Department Notes'), findsOneWidget);
    expect(find.text('Track Repair Crew Live (Squad #AMC-R4)'), findsOneWidget);

    // 4. Test Crew Live Tracking Navigation
    final trackCrewButton = find.text('Track Repair Crew Live (Squad #AMC-R4)');
    await tester.ensureVisible(trackCrewButton);
    await tester.pumpAndSettle();
    await tester.tap(trackCrewButton);
    await tester.pumpAndSettle();

    // Verify Crew Live Tracking Screen
    expect(find.textContaining('Crew Live Tracking'), findsOneWidget);
    expect(find.text('LIVE DISPATCH'), findsOneWidget);
    expect(find.text('Ramesh Solanki (Squad Lead)'), findsOneWidget);
    expect(find.text('Distance'), findsOneWidget);

    // Return back to Ticket Details
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Ticket Details'), findsOneWidget);

    // 5. Scroll down and tap "Ask Civic AI Agent about this ticket"
    final askAgentButton = find.text('Ask Civic AI Agent about this ticket');
    expect(askAgentButton, findsOneWidget);
    await tester.ensureVisible(askAgentButton);
    await tester.pumpAndSettle();
    await tester.tap(askAgentButton);
    await tester.pumpAndSettle();

    // Returns to Agent Chat
    expect(find.text('CivicBot Assistant'), findsOneWidget);

    // 6. Navigate to "Tickets" ledger tab
    final ticketsNavFinder = find.text('Tickets');
    expect(ticketsNavFinder, findsOneWidget);
    await tester.tap(ticketsNavFinder);
    await tester.pumpAndSettle();

    expect(find.text('My Tickets & Status'), findsOneWidget);
  });
}
