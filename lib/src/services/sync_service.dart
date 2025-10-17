import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/models/models.dart';
import '../data/repositories/project_repository.dart';
import '../data/repositories/event_repository.dart';
import '../data/repositories/beneficiary_repository.dart';
import '../data/repositories/partner_repository.dart';
import '../providers/repository_providers.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    ref.read(projectRepositoryProvider),
    ref.read(eventRepositoryProvider),
    ref.read(beneficiaryRepositoryProvider),
    ref.read(partnerRepositoryProvider),
  );
});

class SyncService {
  final ProjectRepository _projectRepository;
  final EventRepository _eventRepository;
  final BeneficiaryRepository _beneficiaryRepository;
  final PartnerRepository _partnerRepository;
  
  final Dio _dio = Dio();
  final Connectivity _connectivity = Connectivity();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  static const String _baseUrlKey = 'sync_base_url';
  static const String _authTokenKey = 'sync_auth_token';
  static const String _lastSyncKey = 'last_sync_timestamp';

  SyncService(
    this._projectRepository,
    this._eventRepository,
    this._beneficiaryRepository,
    this._partnerRepository,
  ) {
    _initializeDio();
  }

  void _initializeDio() {
    _dio.options.baseUrl = 'https://api.onesave.cnf.ci'; // Default API URL
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    
    // Add interceptors for authentication and error handling
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: _authTokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.headers['Content-Type'] = 'application/json';
        handler.next(options);
      },
      onError: (error, handler) {
        // Handle network errors and API errors
        print('Sync error: ${error.message}');
        handler.next(error);
      },
    ));
  }

  // Check if device is online
  Future<bool> isOnline() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Get last sync timestamp
  Future<DateTime?> getLastSyncTime() async {
    final timestamp = await _storage.read(key: _lastSyncKey);
    if (timestamp != null) {
      return DateTime.parse(timestamp);
    }
    return null;
  }

  // Set last sync timestamp
  Future<void> setLastSyncTime(DateTime timestamp) async {
    await _storage.write(key: _lastSyncKey, value: timestamp.toIso8601String());
  }

  // Configure API settings
  Future<void> configureApi({
    required String baseUrl,
    required String authToken,
  }) async {
    await _storage.write(key: _baseUrlKey, value: baseUrl);
    await _storage.write(key: _authTokenKey, value: authToken);
    _dio.options.baseUrl = baseUrl;
  }

  // Full synchronization
  Future<SyncResult> performFullSync() async {
    if (!await isOnline()) {
      return SyncResult(
        success: false,
        message: 'No internet connection',
        syncedItems: 0,
      );
    }

    try {
      int syncedItems = 0;
      final errors = <String>[];

      // Sync projects
      try {
        final projects = await _syncProjects();
        syncedItems += projects;
      } catch (e) {
        errors.add('Projects: $e');
      }

      // Sync events
      try {
        final events = await _syncEvents();
        syncedItems += events;
      } catch (e) {
        errors.add('Events: $e');
      }

      // Sync beneficiaries
      try {
        final beneficiaries = await _syncBeneficiaries();
        syncedItems += beneficiaries;
      } catch (e) {
        errors.add('Beneficiaries: $e');
      }

      // Sync partners
      try {
        final partners = await _syncPartners();
        syncedItems += partners;
      } catch (e) {
        errors.add('Partners: $e');
      }

      // Update last sync time
      await setLastSyncTime(DateTime.now());

      return SyncResult(
        success: errors.isEmpty,
        message: errors.isEmpty 
          ? 'Sync completed successfully' 
          : 'Sync completed with errors: ${errors.join(', ')}',
        syncedItems: syncedItems,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Sync failed: $e',
        syncedItems: 0,
      );
    }
  }

  // Sync projects
  Future<int> _syncProjects() async {
    final lastSync = await getLastSyncTime();
    final localProjects = await _projectRepository.getAll();
    
    // Upload local changes
    for (final project in localProjects) {
      if (lastSync == null || project.updatedAt.isAfter(lastSync)) {
        await uploadProject(project);
      }
    }

    // Download remote changes
    final response = await _dio.get('/projects', queryParameters: {
      'since': lastSync?.toIso8601String(),
    });

    int syncedCount = 0;
    for (final data in response.data['projects']) {
      final remoteProject = Project.fromJson(data);
      final localProject = await _projectRepository.getById(remoteProject.id!);
      
      if (localProject == null) {
        // New project from server
        await _projectRepository.create(remoteProject);
        syncedCount++;
      } else if (remoteProject.updatedAt.isAfter(localProject.updatedAt)) {
        // Server version is newer - resolve conflict
        await _resolveProjectConflict(remoteProject, localProject);
        syncedCount++;
      }
    }

    return syncedCount;
  }

  // Sync events
  Future<int> _syncEvents() async {
    final lastSync = await getLastSyncTime();
    final localEvents = await _eventRepository.getAll();
    
    // Upload local changes
    for (final event in localEvents) {
      if (lastSync == null || event.updatedAt.isAfter(lastSync)) {
        await uploadEvent(event);
      }
    }

    // Download remote changes
    final response = await _dio.get('/events', queryParameters: {
      'since': lastSync?.toIso8601String(),
    });

    int syncedCount = 0;
    for (final data in response.data['events']) {
      final remoteEvent = Event.fromJson(data);
      final localEvent = await _eventRepository.getById(remoteEvent.id!);
      
      if (localEvent == null) {
        await _eventRepository.create(remoteEvent);
        syncedCount++;
      } else if (remoteEvent.updatedAt.isAfter(localEvent.updatedAt)) {
        await _resolveEventConflict(remoteEvent, localEvent);
        syncedCount++;
      }
    }

    return syncedCount;
  }

  // Sync beneficiaries
  Future<int> _syncBeneficiaries() async {
    final lastSync = await getLastSyncTime();
    final localBeneficiaries = await _beneficiaryRepository.getAll();
    
    // Upload local changes
    for (final beneficiary in localBeneficiaries) {
      if (lastSync == null || beneficiary.updatedAt.isAfter(lastSync)) {
        await uploadBeneficiary(beneficiary);
      }
    }

    // Download remote changes
    final response = await _dio.get('/beneficiaries', queryParameters: {
      'since': lastSync?.toIso8601String(),
    });

    int syncedCount = 0;
    for (final data in response.data['beneficiaries']) {
      final remoteBeneficiary = Beneficiary.fromJson(data);
      final localBeneficiary = await _beneficiaryRepository.getById(remoteBeneficiary.id!);
      
      if (localBeneficiary == null) {
        await _beneficiaryRepository.create(remoteBeneficiary);
        syncedCount++;
      } else if (remoteBeneficiary.updatedAt.isAfter(localBeneficiary.updatedAt)) {
        await _resolveBeneficiaryConflict(remoteBeneficiary, localBeneficiary);
        syncedCount++;
      }
    }

    return syncedCount;
  }

  // Sync partners
  Future<int> _syncPartners() async {
    final lastSync = await getLastSyncTime();
    final localPartners = await _partnerRepository.getAll();
    
    // Upload local changes
    for (final partner in localPartners) {
      if (lastSync == null || partner.updatedAt.isAfter(lastSync)) {
        await uploadPartner(partner);
      }
    }

    // Download remote changes
    final response = await _dio.get('/partners', queryParameters: {
      'since': lastSync?.toIso8601String(),
    });

    int syncedCount = 0;
    for (final data in response.data['partners']) {
      final remotePartner = Partner.fromJson(data);
      final localPartner = await _partnerRepository.getById(remotePartner.id!);
      
      if (localPartner == null) {
        await _partnerRepository.create(remotePartner);
        syncedCount++;
      } else if (remotePartner.updatedAt.isAfter(localPartner.updatedAt)) {
        await _resolvePartnerConflict(remotePartner, localPartner);
        syncedCount++;
      }
    }

    return syncedCount;
  }

  // Upload methods
  Future<void> uploadProject(Project project) async {
    await _dio.post('/projects', data: project.toJson());
  }

  Future<void> uploadEvent(Event event) async {
    await _dio.post('/events', data: event.toJson());
  }

  Future<void> uploadBeneficiary(Beneficiary beneficiary) async {
    await _dio.post('/beneficiaries', data: beneficiary.toJson());
  }

  Future<void> uploadPartner(Partner partner) async {
    await _dio.post('/partners', data: partner.toJson());
  }

  // Conflict resolution methods (last-write-wins)
  Future<void> _resolveProjectConflict(Project remote, Project local) async {
    // For now, use last-write-wins strategy
    // In a real app, you might want to show a conflict resolution UI
    await _projectRepository.update(remote);
  }

  Future<void> _resolveEventConflict(Event remote, Event local) async {
    await _eventRepository.update(remote);
  }

  Future<void> _resolveBeneficiaryConflict(Beneficiary remote, Beneficiary local) async {
    await _beneficiaryRepository.update(remote);
  }

  Future<void> _resolvePartnerConflict(Partner remote, Partner local) async {
    await _partnerRepository.update(remote);
  }
}

class SyncResult {
  final bool success;
  final String message;
  final int syncedItems;

  SyncResult({
    required this.success,
    required this.message,
    required this.syncedItems,
  });
}
