import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../data/models/project.dart';
import '../../providers/app_providers.dart';
import '../widgets/animated_card.dart';
import '../widgets/animated_button.dart';
import '../widgets/loading_widgets.dart';
import '../../theme/app_theme.dart';

class ProgramsScreen extends ConsumerWidget {
  const ProgramsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: OneSaveColors.background,
        appBar: AppBar(
          title: const Text('Programmes'),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'CLAC', icon: Icon(Icons.library_books)),
              Tab(text: 'IFADEM', icon: Icon(Icons.school)),
              Tab(text: 'ELAN', icon: Icon(Icons.lightbulb)),
            ],
            indicator: BoxDecoration(
              gradient: const LinearGradient(
                colors: OneSaveColors.primaryGradient,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            labelColor: OneSaveColors.onPrimary,
            unselectedLabelColor: OneSaveColors.onSurface.withOpacity(0.6),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
        body: const TabBarView(children: [
          _ProgramList(program: 'CLAC'),
          _ProgramList(program: 'IFADEM'),
          _ProgramList(program: 'ELAN'),
        ]),
      ),
    );
  }
}

class _ProgramList extends ConsumerWidget {
  final String program;
  const _ProgramList({required this.program});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(projectRepositoryProvider).getAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SkeletonList(itemCount: 6);
        }
        
        if (snapshot.hasError) {
          return Center(
            child: AnimatedCard(
              useGlassmorphism: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: OneSaveColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur de chargement',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Impossible de charger les projets',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: OneSaveColors.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AnimatedButton(
                    text: 'Réessayer',
                    icon: Icons.refresh,
                    onPressed: () {
                      // Trigger rebuild
                    },
                  ),
                ],
              ),
            ),
          );
        }
        
        final items = (snapshot.data ?? <Project>[]).where((p) => p.program == program).toList();
        
        if (items.isEmpty) {
          return Center(
            child: AnimatedCard(
              useGlassmorphism: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: OneSaveColors.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun projet',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aucun projet trouvé pour le programme $program',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: OneSaveColors.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        
        return AnimationLimiter(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final project = items[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: AnimatedCard(
                      useGlassmorphism: true,
                      margin: const EdgeInsets.only(bottom: 16),
                      onTap: () {
                        // Navigate to project details
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: _getProgramGradient(program).colors,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getProgramIcon(program),
                                  color: OneSaveColors.onPrimary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      project.title,
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      program,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: OneSaveColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(project.status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _getStatusColor(project.status).withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  project.status,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: _getStatusColor(project.status),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (project.description != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              project.description!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: OneSaveColors.onSurface.withOpacity(0.7),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
  
  LinearGradient _getProgramGradient(String program) {
    switch (program) {
      case 'CLAC':
        return const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)]);
      case 'IFADEM':
        return const LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF0891B2)]);
      case 'ELAN':
        return const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]);
      default:
        return const LinearGradient(colors: OneSaveColors.primaryGradient);
    }
  }
  
  IconData _getProgramIcon(String program) {
    switch (program) {
      case 'CLAC':
        return Icons.library_books;
      case 'IFADEM':
        return Icons.school;
      case 'ELAN':
        return Icons.lightbulb;
      default:
        return Icons.folder;
    }
  }
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'actif':
      case 'en cours':
        return OneSaveColors.secondary;
      case 'terminé':
      case 'complété':
        return OneSaveColors.primary;
      case 'en attente':
      case 'en pause':
        return const Color(0xFFF59E0B);
      case 'annulé':
      case 'échec':
        return OneSaveColors.error;
      default:
        return OneSaveColors.onSurface.withOpacity(0.6);
    }
  }
}
