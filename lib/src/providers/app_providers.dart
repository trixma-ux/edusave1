import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/project_repository.dart';
import '../data/repositories/event_repository.dart';
import '../data/repositories/beneficiary_repository.dart';
import '../data/repositories/partner_repository.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) => ProjectRepository());
final eventRepositoryProvider = Provider<EventRepository>((ref) => EventRepository());
final beneficiaryRepositoryProvider = Provider<BeneficiaryRepository>((ref) => BeneficiaryRepository());
final partnerRepositoryProvider = Provider<PartnerRepository>((ref) => PartnerRepository());

final currentTabProvider = StateProvider<int>((ref) => 0);
