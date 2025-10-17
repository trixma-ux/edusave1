import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final apiConfigurationProvider = FutureProvider<ApiConfiguration>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.getConfiguration();
});

final apiTestResultProvider = StateNotifierProvider<ApiTestNotifier, ApiTestResult?>((ref) {
  return ApiTestNotifier(ref.read(apiServiceProvider));
});

class ApiTestNotifier extends StateNotifier<ApiTestResult?> {
  final ApiService _apiService;

  ApiTestNotifier(this._apiService) : super(null);

  Future<void> testConnection() async {
    state = null; // Reset state
    final result = await _apiService.testConnection();
    state = result;
  }

  void clearResult() {
    state = null;
  }
}

final importResultProvider = StateNotifierProvider<ImportNotifier, ImportResult?>((ref) {
  return ImportNotifier(ref.read(apiServiceProvider));
});

class ImportNotifier extends StateNotifier<ImportResult?> {
  final ApiService _apiService;

  ImportNotifier(this._apiService) : super(null);

  Future<void> importData({
    required String endpoint,
    Map<String, dynamic>? parameters,
  }) async {
    state = null; // Reset state
    final result = await _apiService.importData(
      endpoint: endpoint,
      parameters: parameters,
    );
    state = result;
  }

  void clearResult() {
    state = null;
  }
}

final exportResultProvider = StateNotifierProvider<ExportNotifier, ExportResult?>((ref) {
  return ExportNotifier(ref.read(apiServiceProvider));
});

class ExportNotifier extends StateNotifier<ExportResult?> {
  final ApiService _apiService;

  ExportNotifier(this._apiService) : super(null);

  Future<void> exportData({
    required String endpoint,
    required Map<String, dynamic> data,
  }) async {
    state = null; // Reset state
    final result = await _apiService.exportData(
      endpoint: endpoint,
      data: data,
    );
    state = result;
  }

  void clearResult() {
    state = null;
  }
}

final syncResultProvider = StateNotifierProvider<SyncNotifier, SyncResult?>((ref) {
  return SyncNotifier(ref.read(apiServiceProvider));
});

class SyncNotifier extends StateNotifier<SyncResult?> {
  final ApiService _apiService;

  SyncNotifier(this._apiService) : super(null);

  Future<void> syncWithExternalSystem({
    required String syncEndpoint,
    Map<String, dynamic>? localData,
  }) async {
    state = null; // Reset state
    final result = await _apiService.syncWithExternalSystem(
      syncEndpoint: syncEndpoint,
      localData: localData,
    );
    state = result;
  }

  void clearResult() {
    state = null;
  }
}
