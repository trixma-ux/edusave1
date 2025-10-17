import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/project_repository.dart';
import '../data/repositories/event_repository.dart';
import '../data/repositories/beneficiary_repository.dart';
import '../data/repositories/partner_repository.dart';
import '../data/repositories/user_repository.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository();
});

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository();
});

final beneficiaryRepositoryProvider = Provider<BeneficiaryRepository>((ref) {
  return BeneficiaryRepository();
});

final partnerRepositoryProvider = Provider<PartnerRepository>((ref) {
  return PartnerRepository();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});
