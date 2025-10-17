import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/offline_service.dart';
import '../services/sync_service.dart';

final offlineServiceProvider = Provider<OfflineService>((ref) {
  return OfflineService(ref.read(syncServiceProvider));
});

final offlineStatusProvider = StateNotifierProvider<OfflineStatusNotifier, OfflineStatus>((ref) {
  return OfflineStatusNotifier(ref.read(offlineServiceProvider));
});

class OfflineStatusNotifier extends StateNotifier<OfflineStatus> {
  final OfflineService _offlineService;
  final Connectivity _connectivity = Connectivity();

  OfflineStatusNotifier(this._offlineService) : super(OfflineStatus.initial()) {
    _checkConnectivity();
    _setupConnectivityListener();
  }

  Future<void> _checkConnectivity() async {
    final isOffline = await _offlineService.isOffline();
    state = state.copyWith(
      isOffline: isOffline,
      pendingOperationsCount: _offlineService.pendingOperationsCount,
    );
  }

  void _setupConnectivityListener() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      final isOffline = result == ConnectivityResult.none;
      state = state.copyWith(
        isOffline: isOffline,
        pendingOperationsCount: _offlineService.pendingOperationsCount,
      );

      // If back online, process pending operations
      if (!isOffline) {
        _processPendingOperations();
      }
    });
  }

  Future<void> _processPendingOperations() async {
    state = state.copyWith(isProcessingOperations: true);
    
    try {
      await _offlineService.retryFailedOperations();
      state = state.copyWith(
        isProcessingOperations: false,
        pendingOperationsCount: _offlineService.pendingOperationsCount,
        lastProcessedTime: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isProcessingOperations: false,
        error: e.toString(),
      );
    }
  }

  Future<void> queueOperation(PendingOperation operation) async {
    await _offlineService.queueOperation(operation);
    state = state.copyWith(
      pendingOperationsCount: _offlineService.pendingOperationsCount,
    );
  }

  Future<void> clearPendingOperations() async {
    await _offlineService.clearPendingOperations();
    state = state.copyWith(
      pendingOperationsCount: 0,
      error: null,
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  String getStatusMessage() {
    if (state.isOffline) {
      return _offlineService.getOfflineStatusMessage();
    }
    return 'En ligne';
  }
}

class OfflineStatus {
  final bool isOffline;
  final int pendingOperationsCount;
  final bool isProcessingOperations;
  final DateTime? lastProcessedTime;
  final String? error;

  OfflineStatus({
    required this.isOffline,
    required this.pendingOperationsCount,
    required this.isProcessingOperations,
    this.lastProcessedTime,
    this.error,
  });

  factory OfflineStatus.initial() => OfflineStatus(
    isOffline: false,
    pendingOperationsCount: 0,
    isProcessingOperations: false,
  );

  OfflineStatus copyWith({
    bool? isOffline,
    int? pendingOperationsCount,
    bool? isProcessingOperations,
    DateTime? lastProcessedTime,
    String? error,
  }) {
    return OfflineStatus(
      isOffline: isOffline ?? this.isOffline,
      pendingOperationsCount: pendingOperationsCount ?? this.pendingOperationsCount,
      isProcessingOperations: isProcessingOperations ?? this.isProcessingOperations,
      lastProcessedTime: lastProcessedTime ?? this.lastProcessedTime,
      error: error ?? this.error,
    );
  }

  bool get hasError => error != null;
  bool get hasPendingOperations => pendingOperationsCount > 0;
}
