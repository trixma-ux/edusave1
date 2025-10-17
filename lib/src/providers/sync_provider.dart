import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sync_service.dart';

final syncStatusProvider = StateNotifierProvider<SyncStatusNotifier, SyncStatus>((ref) {
  return SyncStatusNotifier(ref.read(syncServiceProvider));
});

class SyncStatusNotifier extends StateNotifier<SyncStatus> {
  final SyncService _syncService;

  SyncStatusNotifier(this._syncService) : super(SyncStatus.idle()) {
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final isOnline = await _syncService.isOnline();
    state = state.copyWith(isOnline: isOnline);
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

  Future<void> checkConnectivity() async {
    await _checkConnectivity();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

class SyncStatus {
  final bool isOnline;
  final bool isSyncing;
  final DateTime? lastSyncTime;
  final SyncResult? lastSyncResult;
  final String? error;

  SyncStatus({
    required this.isOnline,
    required this.isSyncing,
    this.lastSyncTime,
    this.lastSyncResult,
    this.error,
  });

  factory SyncStatus.idle() => SyncStatus(
    isOnline: false,
    isSyncing: false,
  );

  SyncStatus copyWith({
    bool? isOnline,
    bool? isSyncing,
    DateTime? lastSyncTime,
    SyncResult? lastSyncResult,
    String? error,
  }) {
    return SyncStatus(
      isOnline: isOnline ?? this.isOnline,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      lastSyncResult: lastSyncResult ?? this.lastSyncResult,
      error: error ?? this.error,
    );
  }

  bool get hasError => error != null;
  bool get isSuccess => lastSyncResult?.success ?? false;
  int get syncedItems => lastSyncResult?.syncedItems ?? 0;
}
