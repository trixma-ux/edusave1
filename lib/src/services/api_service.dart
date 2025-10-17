import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

class ApiService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  static const String _baseUrlKey = 'api_base_url';
  static const String _authTokenKey = 'api_auth_token';
  static const String _apiKeyKey = 'api_key';

  ApiService() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    
    // Add interceptors for authentication and error handling
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: _authTokenKey);
        final apiKey = await _storage.read(key: _apiKeyKey);
        
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        if (apiKey != null) {
          options.headers['X-API-Key'] = apiKey;
        }
        options.headers['Content-Type'] = 'application/json';
        options.headers['Accept'] = 'application/json';
        handler.next(options);
      },
      onError: (error, handler) {
        print('API Error: ${error.message}');
        handler.next(error);
      },
    ));
  }

  // Configure API settings
  Future<void> configureApi({
    required String baseUrl,
    String? authToken,
    String? apiKey,
  }) async {
    await _storage.write(key: _baseUrlKey, value: baseUrl);
    if (authToken != null) {
      await _storage.write(key: _authTokenKey, value: authToken);
    }
    if (apiKey != null) {
      await _storage.write(key: _apiKeyKey, value: apiKey);
    }
    _dio.options.baseUrl = baseUrl;
  }

  // Get current configuration
  Future<ApiConfiguration> getConfiguration() async {
    final baseUrl = await _storage.read(key: _baseUrlKey) ?? '';
    final authToken = await _storage.read(key: _authTokenKey);
    final apiKey = await _storage.read(key: _apiKeyKey);
    
    return ApiConfiguration(
      baseUrl: baseUrl,
      authToken: authToken,
      apiKey: apiKey,
    );
  }

  // Test API connection
  Future<ApiTestResult> testConnection() async {
    try {
      final response = await _dio.get('/health');
      return ApiTestResult(
        success: true,
        message: 'Connection successful',
        responseTime: DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      return ApiTestResult(
        success: false,
        message: 'Connection failed: ${e.toString()}',
        responseTime: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  // Import data from external API
  Future<ImportResult> importData({
    required String endpoint,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: parameters);
      
      return ImportResult(
        success: true,
        data: response.data,
        message: 'Data imported successfully',
        recordCount: _countRecords(response.data),
      );
    } catch (e) {
      return ImportResult(
        success: false,
        data: null,
        message: 'Import failed: ${e.toString()}',
        recordCount: 0,
      );
    }
  }

  // Export data to external API
  Future<ExportResult> exportData({
    required String endpoint,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      
      return ExportResult(
        success: true,
        message: 'Data exported successfully',
        responseData: response.data,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        message: 'Export failed: ${e.toString()}',
        responseData: null,
      );
    }
  }

  // Sync with external system
  Future<SyncResult> syncWithExternalSystem({
    required String syncEndpoint,
    Map<String, dynamic>? localData,
  }) async {
    try {
      // First, get remote data
      final remoteResponse = await _dio.get(syncEndpoint);
      
      // Then, send local data if provided
      if (localData != null) {
        await _dio.post(syncEndpoint, data: localData);
      }
      
      return SyncResult(
        success: true,
        message: 'Sync completed successfully',
        syncedItems: _countRecords(remoteResponse.data),
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Sync failed: ${e.toString()}',
        syncedItems: 0,
      );
    }
  }

  // Get data from external API with pagination
  Future<PaginatedResult> getPaginatedData({
    required String endpoint,
    int page = 1,
    int limit = 50,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: {
        'page': page,
        'limit': limit,
        ...?filters,
      });
      
      return PaginatedResult(
        success: true,
        data: response.data['data'] ?? response.data,
        totalCount: response.data['total'] ?? 0,
        currentPage: page,
        totalPages: response.data['totalPages'] ?? 1,
        hasNextPage: response.data['hasNext'] ?? false,
        hasPreviousPage: response.data['hasPrevious'] ?? false,
      );
    } catch (e) {
      return PaginatedResult(
        success: false,
        data: null,
        totalCount: 0,
        currentPage: page,
        totalPages: 0,
        hasNextPage: false,
        hasPreviousPage: false,
      );
    }
  }

  // Upload file to external API
  Future<UploadResult> uploadFile({
    required String endpoint,
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? additionalFields,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        ...?additionalFields,
      });
      
      final response = await _dio.post(endpoint, data: formData);
      
      return UploadResult(
        success: true,
        message: 'File uploaded successfully',
        fileUrl: response.data['url'] ?? response.data['fileUrl'],
        fileId: response.data['id'] ?? response.data['fileId'],
      );
    } catch (e) {
      return UploadResult(
        success: false,
        message: 'Upload failed: ${e.toString()}',
        fileUrl: null,
        fileId: null,
      );
    }
  }

  // Download file from external API
  Future<DownloadResult> downloadFile({
    required String endpoint,
    required String savePath,
  }) async {
    try {
      final response = await _dio.download(endpoint, savePath);
      
      return DownloadResult(
        success: true,
        message: 'File downloaded successfully',
        filePath: savePath,
        fileSize: response.headers.value('content-length') != null 
          ? int.parse(response.headers.value('content-length')!)
          : 0,
      );
    } catch (e) {
      return DownloadResult(
        success: false,
        message: 'Download failed: ${e.toString()}',
        filePath: null,
        fileSize: 0,
      );
    }
  }

  // Helper method to count records in response data
  int _countRecords(dynamic data) {
    if (data is List) {
      return data.length;
    } else if (data is Map && data.containsKey('data') && data['data'] is List) {
      return (data['data'] as List).length;
    } else if (data is Map && data.containsKey('items') && data['items'] is List) {
      return (data['items'] as List).length;
    }
    return 0;
  }

  // Clear stored configuration
  Future<void> clearConfiguration() async {
    await _storage.delete(key: _baseUrlKey);
    await _storage.delete(key: _authTokenKey);
    await _storage.delete(key: _apiKeyKey);
  }
}

// Data classes for API responses
class ApiConfiguration {
  final String baseUrl;
  final String? authToken;
  final String? apiKey;

  ApiConfiguration({
    required this.baseUrl,
    this.authToken,
    this.apiKey,
  });

  bool get isConfigured => baseUrl.isNotEmpty;
}

class ApiTestResult {
  final bool success;
  final String message;
  final int responseTime;

  ApiTestResult({
    required this.success,
    required this.message,
    required this.responseTime,
  });
}

class ImportResult {
  final bool success;
  final dynamic data;
  final String message;
  final int recordCount;

  ImportResult({
    required this.success,
    required this.data,
    required this.message,
    required this.recordCount,
  });
}

class ExportResult {
  final bool success;
  final String message;
  final dynamic responseData;

  ExportResult({
    required this.success,
    required this.message,
    required this.responseData,
  });
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

class PaginatedResult {
  final bool success;
  final dynamic data;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PaginatedResult({
    required this.success,
    required this.data,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });
}

class UploadResult {
  final bool success;
  final String message;
  final String? fileUrl;
  final String? fileId;

  UploadResult({
    required this.success,
    required this.message,
    this.fileUrl,
    this.fileId,
  });
}

class DownloadResult {
  final bool success;
  final String message;
  final String? filePath;
  final int fileSize;

  DownloadResult({
    required this.success,
    required this.message,
    this.filePath,
    required this.fileSize,
  });
}
