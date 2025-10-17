import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/enhanced_sync_service.dart';

final enhancedSyncStatusProvider = StateNotifierProvider<EnhancedSyncStatusNotifier, EnhancedSyncStatus>((ref) {
  return EnhancedSyncStatusNotifier(ref.read(enhancedSyncServiceProvider));
});

class EnhancedSyncStatusNotifier extends StateNotifier<EnhancedSyncStatus> {
  final EnhancedSyncService _syncService;

  EnhancedSyncStatusNotifier(this._syncService) : super(EnhancedSyncStatus.idle()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _checkConnectivity();
    await _loadSettings();
  }

  Future<void> _checkConnectivity() async {
    final isOnline = await _syncService.isOnline();
    state = state.copyWith(isOnline: isOnline);
  }

  Future<void> _loadSettings() async {
    final autoSyncEnabled = await _syncService.isAutoSyncEnabled();
    final syncInterval = await _syncService.getSyncInterval();
    final lastSyncTime = await _syncService.getLastSyncTime();
    
    state = state.copyWith(
      autoSyncEnabled: autoSyncEnabled,
      syncInterval: syncInterval,
      lastSyncTime: lastSyncTime,
    );
  }

  Future<void> performSync() async {
    if (state.isSyncing) return;

    state = state.copyWith(
      isSyncing: true,
      lastSyncTime: null,
      error: null,
    );

    try {
      final result = await _syncService.performFullSync();
      
      state = state.copyWith(
        isSyncing: false,
        lastSyncTime: DateTime.now(),
        lastSyncResult: result,
        error: result.success ? null : result.message,
      );
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        error: e.toString(),
      );
    }
  }

  Future<void> setAutoSyncEnabled(bool enabled) async {
    await _syncService.setAutoSyncEnabled(enabled);
    state = state.copyWith(autoSyncEnabled: enabled);
  }

  Future<void> setSyncInterval(int minutes) async {
    await _syncService.setSyncInterval(minutes);
    state = state.copyWith(syncInterval: minutes);
  }

  Future<void> checkConnectivity() async {
    await _checkConnectivity();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> configureApi({
    required String baseUrl,
    required String authToken,
  }) async {
    await _syncService.configureApi(
      baseUrl: baseUrl,
      authToken: authToken,
    );
  }
}

class EnhancedSyncStatus {
  final bool isOnline;
  final bool isSyncing;
  final bool autoSyncEnabled;
  final int syncInterval;
  final DateTime? lastSyncTime;
  final SyncResult? lastSyncResult;
  final String? error;

  EnhancedSyncStatus({
    required this.isOnline,
    required this.isSyncing,
    required this.autoSyncEnabled,
    required this.syncInterval,
    this.lastSyncTime,
    this.lastSyncResult,
    this.error,
  });

  factory EnhancedSyncStatus.idle() => EnhancedSyncStatus(
    isOnline: false,
    isSyncing: false,
    autoSyncEnabled: false,
    syncInterval: 15,
  );

  EnhancedSyncStatus copyWith({
    bool? isOnline,
    bool? isSyncing,
    bool? autoSyncEnabled,
    int? syncInterval,
    DateTime? lastSyncTime,
    SyncResult? lastSyncResult,
    String? error,
  }) {
    return EnhancedSyncStatus(
      isOnline: isOnline ?? this.isOnline,
      isSyncing: isSyncing ?? this.isSyncing,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      syncInterval: syncInterval ?? this.syncInterval,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      lastSyncResult: lastSyncResult ?? this.lastSyncResult,
      error: error ?? this.error,
    );
  }

  bool get hasError => error != null;
  bool get isSuccess => lastSyncResult?.success ?? false;
  int get syncedItems => lastSyncResult?.syncedItems ?? 0;
  String get lastSyncText {
    if (lastSyncTime == null) return 'Jamais';
    final now = DateTime.now();
    final difference = now.difference(lastSyncTime!);
    
    if (difference.inMinutes < 1) return 'À l\'instant';
    if (difference.inMinutes < 60) return 'Il y a ${difference.inMinutes} min';
    if (difference.inHours < 24) return 'Il y a ${difference.inHours} h';
    return 'Il y a ${difference.inDays} j';
  }
}
