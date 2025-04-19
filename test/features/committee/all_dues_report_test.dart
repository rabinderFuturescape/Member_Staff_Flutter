import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

import 'package:member_staff_flutter/screens/all_dues_report_screen.dart';
import 'package:member_staff_flutter/models/dues_report_model.dart';
import 'package:member_staff_flutter/models/dues_chart_model.dart';
import 'package:member_staff_flutter/providers/auth_provider.dart';
import 'package:member_staff_flutter/services/api_service.dart';

// Generate mocks
@GenerateMocks([ApiService, AuthProvider])
import 'all_dues_report_test.mocks.dart';

void main() {
  late MockApiService mockApiService;
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockApiService = MockApiService();
    mockAuthProvider = MockAuthProvider();

    // Setup default behavior for the mocks
    when(mockAuthProvider.token).thenReturn('test_token');
    when(mockAuthProvider.isCommitteeMember).thenReturn(true);
  });

  // Helper function to create a test response
  Response<dynamic> createMockResponse({
    int statusCode = 200,
    Map<String, dynamic>? data,
  }) {
    return Response(
      data: data,
      statusCode: statusCode,
      requestOptions: RequestOptions(path: ''),
    );
  }

  // Helper function to create a mock dues report response
  Response<dynamic> createMockDuesReportResponse() {
    return createMockResponse(
      data: {
        'data': [
          {
            'member_name': 'John Doe',
            'unit_number': 'A-101',
            'building_name': 'Building A',
            'bill_cycle': 'Apr 2025',
            'bill_amount': 1000.0,
            'amount_paid': 0.0,
            'due_amount': 1000.0,
            'due_date': '2025-04-10',
            'last_payment_date': null,
          },
          {
            'member_name': 'Jane Smith',
            'unit_number': 'A-102',
            'building_name': 'Building A',
            'bill_cycle': 'Apr 2025',
            'bill_amount': 1200.0,
            'amount_paid': 500.0,
            'due_amount': 700.0,
            'due_date': '2025-04-10',
            'last_payment_date': '2025-04-05',
          },
        ],
        'current_page': 1,
        'last_page': 1,
        'total': 2,
      },
    );
  }

  // Helper function to create a mock chart data response
  Response<dynamic> createMockChartDataResponse() {
    return createMockResponse(
      data: [
        {
          'label': 'Building A',
          'total_due': 1700.0,
        },
        {
          'label': 'Building B',
          'total_due': 1500.0,
        },
      ],
    );
  }

  testWidgets('AllDuesReportScreen loads and displays dues report data',
      (WidgetTester tester) async {
    // Setup mock responses
    when(mockApiService.get(
      '/committee/dues-report',
      queryParameters: anyNamed('queryParameters'),
      token: anyNamed('token'),
    )).thenAnswer((_) async => createMockDuesReportResponse());

    when(mockApiService.get(
      '/committee/dues-report/chart-summary',
      queryParameters: anyNamed('queryParameters'),
      token: anyNamed('token'),
    )).thenAnswer((_) async => createMockChartDataResponse());

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
          ],
          child: AllDuesReportScreen(),
        ),
      ),
    );

    // Wait for the widget to load
    await tester.pumpAndSettle();

    // Verify that the screen title is displayed
    expect(find.text('All Dues Report'), findsOneWidget);

    // Verify that the dues report data is displayed
    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('Jane Smith'), findsOneWidget);
    expect(find.text('A-101'), findsOneWidget);
    expect(find.text('A-102'), findsOneWidget);

    // Verify that the chart section is displayed
    expect(find.text('Dues Summary Charts'), findsOneWidget);
  });

  testWidgets('AllDuesReportScreen applies filters correctly',
      (WidgetTester tester) async {
    // Setup mock responses
    when(mockApiService.get(
      '/committee/dues-report',
      queryParameters: anyNamed('queryParameters'),
      token: anyNamed('token'),
    )).thenAnswer((_) async => createMockDuesReportResponse());

    when(mockApiService.get(
      '/committee/dues-report/chart-summary',
      queryParameters: anyNamed('queryParameters'),
      token: anyNamed('token'),
    )).thenAnswer((_) async => createMockChartDataResponse());

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
          ],
          child: AllDuesReportScreen(),
        ),
      ),
    );

    // Wait for the widget to load
    await tester.pumpAndSettle();

    // Tap on the Advanced Filters section to expand it
    await tester.tap(find.text('Advanced Filters'));
    await tester.pumpAndSettle();

    // Select a building from the dropdown
    await tester.tap(find.text('All Buildings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Building A').last);
    await tester.pumpAndSettle();

    // Verify that the API was called with the correct parameters
    verify(mockApiService.get(
      '/committee/dues-report',
      queryParameters: argThat(predicate((Map<String, dynamic> params) =>
          params.containsKey('building') && params['building'] == 'Building A')),
      token: anyNamed('token'),
    )).called(1);
  });

  testWidgets('AllDuesReportScreen loads more data on scroll',
      (WidgetTester tester) async {
    // Setup mock responses for initial load
    when(mockApiService.get(
      '/committee/dues-report',
      queryParameters: argThat(predicate((Map<String, dynamic> params) =>
          params.containsKey('page') && params['page'] == 1)),
      token: anyNamed('token'),
    )).thenAnswer((_) async => createMockResponse(
          data: {
            'data': List.generate(
              20,
              (index) => {
                'member_name': 'Member $index',
                'unit_number': 'A-${100 + index}',
                'building_name': 'Building A',
                'bill_cycle': 'Apr 2025',
                'bill_amount': 1000.0,
                'amount_paid': 0.0,
                'due_amount': 1000.0,
                'due_date': '2025-04-10',
                'last_payment_date': null,
              },
            ),
            'current_page': 1,
            'last_page': 2,
            'total': 40,
          },
        ));

    // Setup mock responses for second page
    when(mockApiService.get(
      '/committee/dues-report',
      queryParameters: argThat(predicate((Map<String, dynamic> params) =>
          params.containsKey('page') && params['page'] == 2)),
      token: anyNamed('token'),
    )).thenAnswer((_) async => createMockResponse(
          data: {
            'data': List.generate(
              20,
              (index) => {
                'member_name': 'Member ${20 + index}',
                'unit_number': 'A-${120 + index}',
                'building_name': 'Building A',
                'bill_cycle': 'Apr 2025',
                'bill_amount': 1000.0,
                'amount_paid': 0.0,
                'due_amount': 1000.0,
                'due_date': '2025-04-10',
                'last_payment_date': null,
              },
            ),
            'current_page': 2,
            'last_page': 2,
            'total': 40,
          },
        ));

    when(mockApiService.get(
      '/committee/dues-report/chart-summary',
      queryParameters: anyNamed('queryParameters'),
      token: anyNamed('token'),
    )).thenAnswer((_) async => createMockChartDataResponse());

    // Build the widget with a fixed height to ensure scrolling
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
          ],
          child: SizedBox(
            height: 500,
            child: AllDuesReportScreen(),
          ),
        ),
      ),
    );

    // Wait for the widget to load
    await tester.pumpAndSettle();

    // Verify that the first page is loaded
    expect(find.text('Member 0'), findsOneWidget);

    // Scroll to the bottom to trigger loading more data
    await tester.dragUntilVisible(
      find.text('Member 19'),
      find.byType(ListView),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();

    // Verify that the second page is loaded
    verify(mockApiService.get(
      '/committee/dues-report',
      queryParameters: argThat(predicate((Map<String, dynamic> params) =>
          params.containsKey('page') && params['page'] == 2)),
      token: anyNamed('token'),
    )).called(1);
  });

  testWidgets('AllDuesReportScreen changes chart type correctly',
      (WidgetTester tester) async {
    // Setup mock responses
    when(mockApiService.get(
      '/committee/dues-report',
      queryParameters: anyNamed('queryParameters'),
      token: anyNamed('token'),
    )).thenAnswer((_) async => createMockDuesReportResponse());

    when(mockApiService.get(
      '/committee/dues-report/chart-summary',
      queryParameters: anyNamed('queryParameters'),
      token: anyNamed('token'),
    )).thenAnswer((_) async => createMockChartDataResponse());

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
          ],
          child: AllDuesReportScreen(),
        ),
      ),
    );

    // Wait for the widget to load
    await tester.pumpAndSettle();

    // Tap on the Dues Summary Charts section to expand it
    await tester.tap(find.text('Dues Summary Charts'));
    await tester.pumpAndSettle();

    // Tap on the "By Floor" chart type
    await tester.tap(find.text('By Floor'));
    await tester.pumpAndSettle();

    // Verify that the API was called with the correct parameters
    verify(mockApiService.get(
      '/committee/dues-report/chart-summary',
      queryParameters: argThat(predicate((Map<String, dynamic> params) =>
          params.containsKey('chart_type') && params['chart_type'] == 'floor')),
      token: anyNamed('token'),
    )).called(1);

    // Tap on the "Top Members" chart type
    await tester.tap(find.text('Top Members'));
    await tester.pumpAndSettle();

    // Verify that the API was called with the correct parameters
    verify(mockApiService.get(
      '/committee/dues-report/chart-summary',
      queryParameters: argThat(predicate((Map<String, dynamic> params) =>
          params.containsKey('chart_type') &&
          params['chart_type'] == 'top_members')),
      token: anyNamed('token'),
    )).called(1);
  });
}
