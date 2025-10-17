import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/models.dart';
import '../data/repositories/project_repository.dart';
import '../data/repositories/event_repository.dart';
import '../data/repositories/beneficiary_repository.dart';
import '../data/repositories/partner_repository.dart';
import '../providers/repository_providers.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(
    ref.read(projectRepositoryProvider),
    ref.read(eventRepositoryProvider),
    ref.read(beneficiaryRepositoryProvider),
    ref.read(partnerRepositoryProvider),
  );
});

class AnalyticsService {
  final ProjectRepository _projectRepository;
  final EventRepository _eventRepository;
  final BeneficiaryRepository _beneficiaryRepository;
  final PartnerRepository _partnerRepository;

  AnalyticsService(
    this._projectRepository,
    this._eventRepository,
    this._beneficiaryRepository,
    this._partnerRepository,
  );

  // Get project statistics by program
  Future<Map<String, int>> getProjectStatsByProgram() async {
    final projects = await _projectRepository.getAll();
    final stats = <String, int>{};
    
    for (final project in projects) {
      stats[project.program] = (stats[project.program] ?? 0) + 1;
    }
    
    return stats;
  }

  // Get project statistics by status
  Future<Map<String, int>> getProjectStatsByStatus() async {
    final projects = await _projectRepository.getAll();
    final stats = <String, int>{};
    
    for (final project in projects) {
      stats[project.status] = (stats[project.status] ?? 0) + 1;
    }
    
    return stats;
  }

  // Get beneficiary statistics by gender
  Future<Map<String, int>> getBeneficiaryStatsByGender() async {
    final beneficiaries = await _beneficiaryRepository.getAll();
    final stats = <String, int>{};
    
    for (final beneficiary in beneficiaries) {
      final gender = beneficiary.gender ?? 'Non spécifié';
      stats[gender] = (stats[gender] ?? 0) + 1;
    }
    
    return stats;
  }

  // Get beneficiary statistics by segment
  Future<Map<String, int>> getBeneficiaryStatsBySegment() async {
    final beneficiaries = await _beneficiaryRepository.getAll();
    final stats = <String, int>{};
    
    for (final beneficiary in beneficiaries) {
      final segment = beneficiary.segment ?? 'Non spécifié';
      stats[segment] = (stats[segment] ?? 0) + 1;
    }
    
    return stats;
  }

  // Get partner statistics by type
  Future<Map<String, int>> getPartnerStatsByType() async {
    final partners = await _partnerRepository.getAll();
    final stats = <String, int>{};
    
    for (final partner in partners) {
      final type = partner.type ?? 'Non spécifié';
      stats[type] = (stats[type] ?? 0) + 1;
    }
    
    return stats;
  }

  // Get monthly project trends
  Future<List<MonthlyTrend>> getMonthlyProjectTrends() async {
    final projects = await _projectRepository.getAll();
    final trends = <String, int>{};
    
    for (final project in projects) {
      final monthKey = '${project.createdAt.year}-${project.createdAt.month.toString().padLeft(2, '0')}';
      trends[monthKey] = (trends[monthKey] ?? 0) + 1;
    }
    
    return trends.entries
        .map((entry) => MonthlyTrend(
              month: entry.key,
              count: entry.value,
            ))
        .toList()
      ..sort((a, b) => a.month.compareTo(b.month));
  }

  // Get monthly event trends
  Future<List<MonthlyTrend>> getMonthlyEventTrends() async {
    final events = await _eventRepository.getAll();
    final trends = <String, int>{};
    
    for (final event in events) {
      final monthKey = '${event.date.year}-${event.date.month.toString().padLeft(2, '0')}';
      trends[monthKey] = (trends[monthKey] ?? 0) + 1;
    }
    
    return trends.entries
        .map((entry) => MonthlyTrend(
              month: entry.key,
              count: entry.value,
            ))
        .toList()
      ..sort((a, b) => a.month.compareTo(b.month));
  }

  // Get project completion rate
  Future<double> getProjectCompletionRate() async {
    final projects = await _projectRepository.getAll();
    if (projects.isEmpty) return 0.0;
    
    final completedProjects = projects.where((p) => p.status == 'TERMINE').length;
    return completedProjects / projects.length;
  }

  // Get average project duration
  Future<Duration?> getAverageProjectDuration() async {
    final projects = await _projectRepository.getAll();
    final projectsWithDates = projects.where((p) => 
      p.startDate != null && p.endDate != null).toList();
    
    if (projectsWithDates.isEmpty) return null;
    
    final totalDuration = projectsWithDates.fold<Duration>(
      Duration.zero,
      (sum, project) => sum + project.endDate!.difference(project.startDate!),
    );
    
    return Duration(
      days: totalDuration.inDays ~/ projectsWithDates.length,
    );
  }

  // Get total beneficiaries count
  Future<int> getTotalBeneficiaries() async {
    final beneficiaries = await _beneficiaryRepository.getAll();
    return beneficiaries.length;
  }

  // Get total partners count
  Future<int> getTotalPartners() async {
    final partners = await _partnerRepository.getAll();
    return partners.length;
  }

  // Get total events count
  Future<int> getTotalEvents() async {
    final events = await _eventRepository.getAll();
    return events.length;
  }

  // Get upcoming events (next 30 days)
  Future<List<Event>> getUpcomingEvents() async {
    final events = await _eventRepository.getAll();
    final now = DateTime.now();
    final thirtyDaysFromNow = now.add(const Duration(days: 30));
    
    return events.where((event) => 
      event.date.isAfter(now) && event.date.isBefore(thirtyDaysFromNow)
    ).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  // Get project status distribution
  Future<ProjectStatusDistribution> getProjectStatusDistribution() async {
    final projects = await _projectRepository.getAll();
    
    return ProjectStatusDistribution(
      total: projects.length,
      planned: projects.where((p) => p.status == 'PLANIFIE').length,
      inProgress: projects.where((p) => p.status == 'EN_COURS').length,
      completed: projects.where((p) => p.status == 'TERMINE').length,
      closed: projects.where((p) => p.status == 'CLOTURE').length,
    );
  }

  // Get comprehensive analytics
  Future<ComprehensiveAnalytics> getComprehensiveAnalytics() async {
    final projectStats = await getProjectStatsByProgram();
    final statusStats = await getProjectStatsByStatus();
    final genderStats = await getBeneficiaryStatsByGender();
    final segmentStats = await getBeneficiaryStatsBySegment();
    final partnerStats = await getPartnerStatsByType();
    final projectTrends = await getMonthlyProjectTrends();
    final eventTrends = await getMonthlyEventTrends();
    final completionRate = await getProjectCompletionRate();
    final avgDuration = await getAverageProjectDuration();
    final totalBeneficiaries = await getTotalBeneficiaries();
    final totalPartners = await getTotalPartners();
    final totalEvents = await getTotalEvents();
    final upcomingEvents = await getUpcomingEvents();
    final statusDistribution = await getProjectStatusDistribution();

    return ComprehensiveAnalytics(
      projectStatsByProgram: projectStats,
      projectStatsByStatus: statusStats,
      beneficiaryStatsByGender: genderStats,
      beneficiaryStatsBySegment: segmentStats,
      partnerStatsByType: partnerStats,
      monthlyProjectTrends: projectTrends,
      monthlyEventTrends: eventTrends,
      projectCompletionRate: completionRate,
      averageProjectDuration: avgDuration,
      totalBeneficiaries: totalBeneficiaries,
      totalPartners: totalPartners,
      totalEvents: totalEvents,
      upcomingEvents: upcomingEvents,
      projectStatusDistribution: statusDistribution,
    );
  }
}

class MonthlyTrend {
  final String month;
  final int count;

  MonthlyTrend({
    required this.month,
    required this.count,
  });
}

class ProjectStatusDistribution {
  final int total;
  final int planned;
  final int inProgress;
  final int completed;
  final int closed;

  ProjectStatusDistribution({
    required this.total,
    required this.planned,
    required this.inProgress,
    required this.completed,
    required this.closed,
  });
}

class ComprehensiveAnalytics {
  final Map<String, int> projectStatsByProgram;
  final Map<String, int> projectStatsByStatus;
  final Map<String, int> beneficiaryStatsByGender;
  final Map<String, int> beneficiaryStatsBySegment;
  final Map<String, int> partnerStatsByType;
  final List<MonthlyTrend> monthlyProjectTrends;
  final List<MonthlyTrend> monthlyEventTrends;
  final double projectCompletionRate;
  final Duration? averageProjectDuration;
  final int totalBeneficiaries;
  final int totalPartners;
  final int totalEvents;
  final List<Event> upcomingEvents;
  final ProjectStatusDistribution projectStatusDistribution;

  ComprehensiveAnalytics({
    required this.projectStatsByProgram,
    required this.projectStatsByStatus,
    required this.beneficiaryStatsByGender,
    required this.beneficiaryStatsBySegment,
    required this.partnerStatsByType,
    required this.monthlyProjectTrends,
    required this.monthlyEventTrends,
    required this.projectCompletionRate,
    this.averageProjectDuration,
    required this.totalBeneficiaries,
    required this.totalPartners,
    required this.totalEvents,
    required this.upcomingEvents,
    required this.projectStatusDistribution,
  });
}
