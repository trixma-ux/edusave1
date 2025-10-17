import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/analytics_provider.dart';
import '../../services/analytics_service.dart';
import '../../theme/app_theme.dart';

class EnhancedAnalyticsScreen extends ConsumerWidget {
  const EnhancedAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(comprehensiveAnalyticsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: analytics.when(
        data: (data) => _buildAnalyticsContent(context, data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Erreur de chargement des données',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(comprehensiveAnalyticsProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsContent(BuildContext context, ComprehensiveAnalytics analytics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(context),
          const SizedBox(height: 24),
          
          // Key Metrics Cards
          _buildKeyMetrics(context, analytics),
          const SizedBox(height: 24),
          
          // Charts Section
          _buildChartsSection(context, analytics),
          const SizedBox(height: 24),
          
          // Upcoming Events
          _buildUpcomingEvents(context, analytics),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: OneSaveColors.primaryGradient,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.analytics,
            color: OneSaveColors.onPrimary,
            size: 32,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tableau de bord',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Analyses et statistiques avancées',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeyMetrics(BuildContext context, ComprehensiveAnalytics analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Métriques clés',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildMetricCard(
              context,
              'Projets',
              analytics.projectStatusDistribution.total.toString(),
              Icons.work,
              OneSaveColors.primary,
            ),
            _buildMetricCard(
              context,
              'Bénéficiaires',
              analytics.totalBeneficiaries.toString(),
              Icons.people,
              OneSaveColors.secondary,
            ),
            _buildMetricCard(
              context,
              'Événements',
              analytics.totalEvents.toString(),
              Icons.event,
              Colors.orange,
            ),
            _buildMetricCard(
              context,
              'Partenaires',
              analytics.totalPartners.toString(),
              Icons.handshake,
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection(BuildContext context, ComprehensiveAnalytics analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analyses détaillées',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Project Status Chart
        _buildProjectStatusChart(context, analytics),
        const SizedBox(height: 24),
        
        // Program Distribution Chart
        _buildProgramDistributionChart(context, analytics),
        const SizedBox(height: 24),
        
        // Gender Distribution Chart
        _buildGenderDistributionChart(context, analytics),
        const SizedBox(height: 24),
        
        // Monthly Trends Chart
        _buildMonthlyTrendsChart(context, analytics),
      ],
    );
  }

  Widget _buildProjectStatusChart(BuildContext context, ComprehensiveAnalytics analytics) {
    final statusData = analytics.projectStatusDistribution;
    final total = statusData.total;
    
    if (total == 0) {
      return _buildEmptyChart(context, 'Aucun projet disponible');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Répartition des projets par statut',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    _buildPieSection('Planifiés', statusData.planned, total, Colors.blue),
                    _buildPieSection('En cours', statusData.inProgress, total, Colors.orange),
                    _buildPieSection('Terminés', statusData.completed, total, Colors.green),
                    _buildPieSection('Clôturés', statusData.closed, total, Colors.grey),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramDistributionChart(BuildContext context, ComprehensiveAnalytics analytics) {
    final programData = analytics.projectStatsByProgram;
    
    if (programData.isEmpty) {
      return _buildEmptyChart(context, 'Aucune donnée de programme disponible');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Répartition par programme',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: programData.values.reduce((a, b) => a > b ? a : b).toDouble() + 1,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < programData.keys.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                programData.keys.elementAt(index),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: programData.entries.map((entry) {
                    final index = programData.keys.toList().indexOf(entry.key);
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          color: _getColorForIndex(index),
                          width: 20,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderDistributionChart(BuildContext context, ComprehensiveAnalytics analytics) {
    final genderData = analytics.beneficiaryStatsByGender;
    
    if (genderData.isEmpty) {
      return _buildEmptyChart(context, 'Aucune donnée de genre disponible');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Répartition des bénéficiaires par genre',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: genderData.entries.map((entry) {
                    final total = genderData.values.reduce((a, b) => a + b);
                    return _buildPieSection(
                      entry.key,
                      entry.value,
                      total,
                      _getColorForIndex(genderData.keys.toList().indexOf(entry.key)),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyTrendsChart(BuildContext context, ComprehensiveAnalytics analytics) {
    final trends = analytics.monthlyProjectTrends;
    
    if (trends.isEmpty) {
      return _buildEmptyChart(context, 'Aucune tendance mensuelle disponible');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tendances mensuelles des projets',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < trends.length) {
                            return Text(
                              trends[index].month.substring(5), // Show only MM
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: trends.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.count.toDouble());
                      }).toList(),
                      isCurved: true,
                      color: OneSaveColors.primary,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingEvents(BuildContext context, ComprehensiveAnalytics analytics) {
    final upcomingEvents = analytics.upcomingEvents;
    
    if (upcomingEvents.isEmpty) {
      return _buildEmptyChart(context, 'Aucun événement à venir');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Événements à venir (30 prochains jours)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...upcomingEvents.take(5).map((event) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: OneSaveColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (event.location != null)
                          Text(
                            event.location!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '${event.date.day}/${event.date.month}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: OneSaveColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChart(BuildContext context, String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.bar_chart,
                size: 48,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  PieChartSectionData _buildPieSection(String title, int value, int total, Color color) {
    return PieChartSectionData(
      color: color,
      value: value.toDouble(),
      title: '${((value / total) * 100).toStringAsFixed(1)}%',
      radius: 80,
      titleStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      OneSaveColors.primary,
      OneSaveColors.secondary,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
    ];
    return colors[index % colors.length];
  }
}
