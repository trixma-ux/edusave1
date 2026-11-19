import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/analytics_service.dart';
import '../data/models/event.dart';
import 'repository_providers.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(
    ref.read(projectRepositoryProvider),
    ref.read(eventRepositoryProvider),
    ref.read(beneficiaryRepositoryProvider),
    ref.read(partnerRepositoryProvider),
  );
});

final comprehensiveAnalyticsProvider = FutureProvider.autoDispose<ComprehensiveAnalytics>((ref) async {
  final analyticsService = ref.read(analyticsServiceProvider);
  return await analyticsService.getComprehensiveAnalytics();
});

final projectStatsByProgramProvider = FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final analyticsService = ref.read(analyticsServiceProvider);
  return await analyticsService.getProjectStatsByProgram();
});

final projectStatsByStatusProvider = FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final analyticsService = ref.read(analyticsServiceProvider);
  return await analyticsService.getProjectStatsByStatus();
});

final beneficiaryStatsByGenderProvider = FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final analyticsService = ref.read(analyticsServiceProvider);
  return await analyticsService.getBeneficiaryStatsByGender();
});

final beneficiaryStatsBySegmentProvider = FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final analyticsService = ref.read(analyticsServiceProvider);
  return await analyticsService.getBeneficiaryStatsBySegment();
});

final partnerStatsByTypeProvider = FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final analyticsService = ref.read(analyticsServiceProvider);
  return await analyticsService.getPartnerStatsByType();
});

final monthlyProjectTrendsProvider = FutureProvider.autoDispose<List<MonthlyTrend>>((ref) async {
  final analyticsService = ref.read(analyticsServiceProvider);
  return await analyticsService.getMonthlyProjectTrends();
});

final monthlyEventTrendsProvider = FutureProvider.autoDispose<List<MonthlyTrend>>((ref) async {
  final analyticsService = ref.read(analyticsServiceProvider);
  return await analyticsService.getMonthlyEventTrends();
});

final projectCompletionRateProvider = FutureProvider.autoDispose<double>((ref) async {
  final analyticsService = ref.read(analyticsServiceProvider);
  return await analyticsService.getProjectCompletionRate();
});

final averageProjectDurationProvider = FutureProvider.autoDispose<Duration?>((ref) async {
  final analyticsService = ref.read(analyticsServiceProvider);
  return await analyticsService.getAverageProjectDuration();
});

final totalBeneficiariesProvider = FutureProvider.autoDispose<int>((ref) async {
  final analyticsService = ref.read(analyticsServiceProvider);
  return await analyticsService.getTotalBeneficiaries();
});

final totalPartnersProvider = FutureProvider.autoDispose<int>((ref) async {
  final analyticsService = ref.read(analyticsServiceProvider);
  return await analyticsService.getTotalPartners();
});

final totalEventsProvider = FutureProvider.autoDispose<int>((ref) async {
  final analyticsService = ref.read(analyticsServiceProvider);
  return await analyticsService.getTotalEvents();
});

final upcomingEventsProvider = FutureProvider.autoDispose<List<Event>>((ref) async {
  final analyticsService = ref.read(analyticsServiceProvider);
  return await analyticsService.getUpcomingEvents();
});

final projectStatusDistributionProvider = FutureProvider.autoDispose<ProjectStatusDistribution>((ref) async {
  final analyticsService = ref.read(analyticsServiceProvider);
  return await analyticsService.getProjectStatusDistribution();
});
