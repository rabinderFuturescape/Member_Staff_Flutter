import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:member_staff/src/features/member_staff/api/staff_rating_api.dart';
import 'package:member_staff/src/features/member_staff/models/staff_rating.dart';
import 'package:member_staff/src/features/member_staff/models/rating_summary.dart';
import 'package:member_staff/src/features/member_staff/providers/staff_rating_provider.dart';
import 'package:member_staff/src/features/member_staff/widgets/staff_rating_dialog.dart';
import 'package:member_staff/src/features/member_staff/widgets/staff_rating_summary.dart';
import 'package:member_staff/src/features/member_staff/models/staff.dart';
import 'package:member_staff/src/core/api/api_client.dart';
import 'package:member_staff/src/core/auth/auth_service.dart';

@GenerateMocks([StaffRatingApi, ApiClient, AuthService])
void main() {
  group('StaffRatingProvider Tests', () {
    late MockStaffRatingApi mockApi;
    late StaffRatingProvider provider;

    setUp(() {
      mockApi = MockStaffRatingApi();
      provider = StaffRatingProvider(api: mockApi);
    });

    test('getRatingSummary should return rating summary', () async {
      // Arrange
      final summary = RatingSummary(
        staffId: 1,
        staffType: 'member',
        averageRating: 4.5,
        totalRatings: 10,
        ratingDistribution: {1: 0, 2: 1, 3: 1, 4: 2, 5: 6},
        recentReviews: [],
      );

      when(mockApi.getRatingSummary(staffId: 1, staffType: 'member'))
          .thenAnswer((_) async => summary);

      // Act
      final result = await provider.getRatingSummary(
        staffId: 1,
        staffType: 'member',
      );

      // Assert
      expect(result, equals(summary));
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });

    test('getRatingSummary should handle errors', () async {
      // Arrange
      when(mockApi.getRatingSummary(staffId: 1, staffType: 'member'))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => provider.getRatingSummary(staffId: 1, staffType: 'member'),
        throwsException,
      );
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNotNull);
    });

    test('submitRating should submit rating successfully', () async {
      // Arrange
      final rating = StaffRating(
        id: 1,
        memberId: 1,
        staffId: 1,
        staffType: 'member',
        rating: 4,
        feedback: 'Great service!',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockApi.submitRating(
        staffId: 1,
        staffType: 'member',
        rating: 4,
        feedback: 'Great service!',
      )).thenAnswer((_) async => rating);

      // Act
      final result = await provider.submitRating(
        staffId: 1,
        staffType: 'member',
        rating: 4,
        feedback: 'Great service!',
      );

      // Assert
      expect(result, equals(rating));
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });

    test('submitRating should handle errors', () async {
      // Arrange
      when(mockApi.submitRating(
        staffId: 1,
        staffType: 'member',
        rating: 4,
        feedback: 'Great service!',
      )).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => provider.submitRating(
          staffId: 1,
          staffType: 'member',
          rating: 4,
          feedback: 'Great service!',
        ),
        throwsException,
      );
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNotNull);
    });
  });

  group('StaffRatingApi Tests', () {
    late MockApiClient mockApiClient;
    late MockAuthService mockAuthService;
    late StaffRatingApi api;

    setUp(() {
      mockApiClient = MockApiClient();
      mockAuthService = MockAuthService();
      api = StaffRatingApi(
        apiClient: mockApiClient,
        authService: mockAuthService,
      );
    });

    test('submitRating should make correct API call', () async {
      // Arrange
      final responseBody = jsonEncode({
        'message': 'Rating submitted successfully.',
        'rating': {
          'id': 1,
          'member_id': 1,
          'staff_id': 1,
          'staff_type': 'member',
          'rating': 4,
          'feedback': 'Great service!',
          'created_at': '2023-11-20T12:00:00.000Z',
          'updated_at': '2023-11-20T12:00:00.000Z',
        },
      });

      when(mockAuthService.getCurrentMemberId()).thenAnswer((_) async => 1);
      when(mockApiClient.post(
        '/staff/rating',
        body: {
          'member_id': 1,
          'staff_id': 1,
          'staff_type': 'member',
          'rating': 4,
          'feedback': 'Great service!',
        },
      )).thenAnswer((_) async => http.Response(responseBody, 201));

      // Act
      final result = await api.submitRating(
        staffId: 1,
        staffType: 'member',
        rating: 4,
        feedback: 'Great service!',
      );

      // Assert
      expect(result.id, equals(1));
      expect(result.memberId, equals(1));
      expect(result.staffId, equals(1));
      expect(result.staffType, equals('member'));
      expect(result.rating, equals(4));
      expect(result.feedback, equals('Great service!'));
    });

    test('getRatingSummary should make correct API call', () async {
      // Arrange
      final responseBody = jsonEncode({
        'staff_id': 1,
        'staff_type': 'member',
        'average_rating': 4.5,
        'total_ratings': 10,
        'rating_distribution': {
          '1': 0,
          '2': 1,
          '3': 1,
          '4': 2,
          '5': 6,
        },
        'recent_reviews': [],
      });

      when(mockApiClient.get(
        '/staff/1/ratings?staff_type=member',
      )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final result = await api.getRatingSummary(
        staffId: 1,
        staffType: 'member',
      );

      // Assert
      expect(result.staffId, equals(1));
      expect(result.staffType, equals('member'));
      expect(result.averageRating, equals(4.5));
      expect(result.totalRatings, equals(10));
      expect(result.ratingDistribution, equals({1: 0, 2: 1, 3: 1, 4: 2, 5: 6}));
    });
  });

  group('StaffRatingDialog Widget Tests', () {
    testWidgets('should display rating dialog correctly', (WidgetTester tester) async {
      // Arrange
      final staff = Staff(
        id: 1,
        name: 'John Doe',
        category: 'Cook',
        photoUrl: null,
        phone: '1234567890',
        address: '123 Main St',
        status: 'active',
      );

      final mockApi = MockStaffRatingApi();
      final provider = StaffRatingProvider(api: mockApi);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<StaffRatingProvider>.value(
              value: provider,
              child: StaffRatingDialog(
                staff: staff,
                staffType: 'member',
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Rate John Doe'), findsOneWidget);
      expect(find.text('Cook'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget);
    });
  });
}
