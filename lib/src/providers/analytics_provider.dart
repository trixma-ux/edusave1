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

final comprehensiveAnalyticsProvider = FutureProvider<ComprehensiveAnalytics>((ref) async {
  final analyticsService = ref.read(analyticsServiceProvider);
  return await analyticsService.getComprehensiveAnalytics();
});

final projectStatsByProgramProvider = FutureProvider<Map<String, int>>((ref) async {
  final analyticsService = ref.read(analyticsServiceProvider);
  return await analyticsService.getProjectStatsByProgram();
});

final projectStatsByStatusProvider = FutureProvider<Map<String, int>>((ref) async {
  final analyticsService = ref.read(analyticsServiceProvider);
  return await analyticsService.getProjectStatsByStatus();
});

final beneficiaryStatsByGenderProvider = FutureProvider<Map<String, int>>((ref) async {
  final analyticsService = ref.read(analyticsServiceProvider);
  return await analyticsService.getBeneficiaryStatsByGender();
});

final beneficiaryStatsBySegmentProvider = FutureProvider<Map<String, int>>((ref) async {
  final analyticsService = ref.read(analyticsServiceProvider);
  return await analyticsService.getBeneficiaryStatsBySegment();
});

final partnerStatsByTypeProvider = FutureProvider<Map<String, int>>((ref) async {
  final analyticsService = ref.read(analyticsServiceProvider);
  return await analyticsService.getPartnerStatsByType();
});

final monthlyProjectTrendsProvider = FutureProvider<List<MonthlyTrend>>((ref) async {
  final analyticsService = ref.read(analyticsServiceProvider);
  return await analyticsService.getMonthlyProjectTrends();
});

final monthlyEventTrendsProvider = FutureProvider<List<MonthlyTrend>>((ref) async {
  final analyticsService = ref.read(analyticsServiceProvider);
  return await analyticsService.getMonthlyEventTrends();
});

final projectCompletionRateProvider = FutureProvider<double>((ref) async {
  final analyticsService = ref.read(analyticsServiceProvider);
  return await analyticsService.getProjectCompletionRate();
});

final averageProjectDurationProvider = FutureProvider<Duration?>((ref) async {
  final analyticsService = ref.read(analyticsServiceProvider);
  return await analyticsService.getAverageProjectDuration();
});

final totalBeneficiariesProvider = FutureProvider<int>((ref) async {
  final analyticsService = ref.read(analyticsServiceProvider);
  return await analyticsService.getTotalBeneficiaries();
});

final totalPartnersProvider = FutureProvider<int>((ref) async {
  final analyticsService = ref.read(analyticsServiceProvider);
  return await analyticsService.getTotalPartners();
});

final totalEventsProvider = FutureProvider<int>((ref) async {
  final analyticsService = ref.read(analyticsServiceProvider);
  return await analyticsService.getTotalEvents();
});

final upcomingEventsProvider = FutureProvider<List<Event>>((ref) async {
  final analyticsService = ref.read(analyticsServiceProvider);
  return await analyticsService.getUpcomingEvents();
});

final projectStatusDistributionProvider = FutureProvider<ProjectStatusDistribution>((ref) async {
  final analyticsService = ref.read(analyticsServiceProvider);
  return await analyticsService.getProjectStatusDistribution();
});
