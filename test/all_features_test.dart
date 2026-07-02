import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_log/main.dart';
import 'package:travel_log/widgets/brutal_widgets.dart';
import 'package:travel_log/screens/typewriter_screen.dart';
import 'package:travel_log/screens/evidence_screen.dart';
import 'package:travel_log/screens/banger_screen.dart';

import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    // Provide a mock HTTP client that returns 200 with empty PNG bytes
    HttpOverrides.global = _MockHttpOverrides();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Brutal Widgets Tests', () {
    testWidgets('BrutalCard builds and can be tapped', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BrutalCard(
              color: Colors.red,
              rotationDegrees: 5.0,
              hasTape: true,
              onTap: () {
                tapped = true;
              },
              child: const Text('Card Content'),
            ),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
      await tester.tap(find.text('Card Content'));
      expect(tapped, isTrue);
    });

    testWidgets('BrutalButton interactive states', (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BrutalButton(
              onPressed: () {
                pressed = true;
              },
              child: const Text('Button Content'),
            ),
          ),
        ),
      );

      expect(find.text('Button Content'), findsOneWidget);
      
      // Tap down/up sequences
      final gesture = await tester.startGesture(tester.getCenter(find.text('Button Content')));
      await tester.pump();
      
      // Release gesture
      await gesture.up();
      await tester.pump();
      
      expect(pressed, isTrue);
    });

    testWidgets('Other auxiliary widgets render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                DymoLabel(text: 'Dymo'),
                TapeOverlay(),
                GrainOverlay(child: Text('Child')),
              ],
            ),
          ),
        ),
      );
      expect(find.text('DYMO'), findsOneWidget);
      expect(find.text('Child'), findsOneWidget);
    });
  });

  group('App Shell & Navigation Tests', () {
    testWidgets('Tab switching and direct screen navigation', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const TravelLogApp());

      // 1. We start on Scrapbook tab
      expect(find.text('YOUR MESSY TRIPS'), findsOneWidget);

      // Tap bottom nav items
      await tester.tap(find.byIcon(Icons.play_circle));
      await tester.pumpAndSettle();
      expect(find.text('THE STUDIO'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      expect(find.text('MY PROFILE'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.book));
      await tester.pumpAndSettle();
      expect(find.text('YOUR MESSY TRIPS'), findsOneWidget);

      // Tap FAB on Scrapbook
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(find.text('CHAOS INITIALIZED! SELECT A TRIP TO START THE TEA.'), findsOneWidget);

      // Open Cabo Fail dialog
      await tester.tap(find.text("CABO FAIL '23"));
      await tester.pumpAndSettle();
      expect(find.text("CABO FAIL '23"), findsNWidgets(2)); // Card + Dialog header
      
      // Close dialog option
      await tester.tap(find.text('[ CLOSE ]'));
      await tester.pumpAndSettle();
      expect(find.text('What do you want to edit or view for this trip?'), findsNothing);

      // Reopen dialog and go to Typewriter
      await tester.tap(find.text("CABO FAIL '23"));
      await tester.pumpAndSettle();
      await tester.tap(find.text('WRITE LYRICS (AI LYRICS)'));
      await tester.pumpAndSettle();
      expect(find.text("CABO FAIL '23"), findsOneWidget); // Screen title now
      
      // Go back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('YOUR MESSY TRIPS'), findsOneWidget);

      // Reopen dialog and go to Evidence
      await tester.tap(find.text("CABO FAIL '23"));
      await tester.pumpAndSettle();
      await tester.tap(find.text('VIEW DIARY & MAP (THE EVIDENCE)'));
      await tester.pumpAndSettle();
      expect(find.text('THE EVIDENCE'), findsOneWidget);

      // Go back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('YOUR MESSY TRIPS'), findsOneWidget);

      // Reopen dialog and go to Studio tab via dialog option
      await tester.tap(find.text("CABO FAIL '23"));
      await tester.pumpAndSettle();
      await tester.tap(find.text('PRODUCE TRACK (AI STUDIO)'));
      await tester.pumpAndSettle();
      expect(find.text('THE STUDIO'), findsOneWidget);
    });
  });

  group('Typewriter Screen Tests', () {
    testWidgets('Interaction and simulation of generation', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: TypewriterScreen(
            onBack: () {},
            onProduceTrack: () {},
          ),
        ),
      );

      // Verify toolbar buttons
      expect(find.text('[B]'), findsOneWidget);
      expect(find.text('[I]'), findsOneWidget);

      // Tap generate verse
      await tester.tap(find.text('GENERATE VERSE'));
      await tester.pump();
      expect(find.text('GENERATING...'), findsOneWidget);

      // Wait for timer simulation
      await tester.pump(const Duration(milliseconds: 600));
      // Typewriter timer keeps periodic updates
      await tester.pump(const Duration(seconds: 10));
      
      // Verify generation completes
      expect(find.text('GENERATE VERSE'), findsOneWidget);
    });
  });

  group('Evidence Screen Tests', () {
    testWidgets('Map pin clicks and scroll behavior', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: EvidenceScreen(
            onBack: () {},
          ),
        ),
      );

      // Click Add the Tea
      await tester.tap(find.text('ADD THE TEA'));
      await tester.pumpAndSettle();
      expect(find.text('SPILLING THE TEA... NEW MEMORY POPUP COMING SOON!'), findsOneWidget);

      // Click Map Pins
      await tester.tap(find.text('THE INCIDENT'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('BAD IDEA #4'));
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    });
  });

  group('Banger Screen Tests', () {
    testWidgets('Vibe selection, recording flow and playback toggle', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: BangerScreen(
            onBack: () {},
          ),
        ),
      );

      // Dropdown selection
      expect(find.text('POP-PUNK (2000S)'), findsOneWidget);
      
      // Tap record button
      await tester.tap(find.text('PRESS RECORD'));
      await tester.pump();
      
      // Should show generating/recording states
      expect(find.text('Cooking the beat...'), findsOneWidget);

      // Let generator transition after 3 seconds
      await tester.pump(const Duration(seconds: 4));
      await tester.pump();

      // Playback screen loaded
      expect(find.text('NOW PLAYING'), findsOneWidget);

      // Toggle Play/Pause
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}

class _MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient();
}

class _MockHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #getUrl || invocation.memberName == #get) {
      return Future.value(_MockHttpClientRequest());
    }
    return null;
  }
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #close) {
      return Future.value(_MockHttpClientResponse());
    }
    if (invocation.memberName == #headers) {
      return _MockHttpHeaders();
    }
    return null;
  }
}

class _MockHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  static const List<int> _transparentImage = [
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
    0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
    0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
    0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #statusCode) return 200;
    if (invocation.memberName == #contentLength) return _transparentImage.length;
    if (invocation.memberName == #headers) return _MockHttpHeaders();
    if (invocation.memberName == #compressionState) return HttpClientResponseCompressionState.notCompressed;
    return null;
  }

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_transparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}
