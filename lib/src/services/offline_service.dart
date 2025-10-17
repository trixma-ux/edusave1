import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/models.dart';
import 'sync_service.dart';

final offlineServiceProvider = Provider<OfflineService>((ref) {
  return OfflineService(ref.read(syncServiceProvider));
});

class OfflineService {
  final SyncService _syncService;
  final Connectivity _connectivity = Connectivity();
  final List<PendingOperation> _pendingOperations = [];
  
  static const String _pendingOperationsKey = 'pending_operations';

  OfflineService(this._syncService) {
    _loadPendingOperations();
    _setupConnectivityListener();
  }

  // Load pending operations from storage
  Future<void> _loadPendingOperations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final operationsJson = prefs.getString(_pendingOperationsKey);
      
      if (operationsJson != null) {
        final List<dynamic> operationsList = jsonDecode(operationsJson);
        _pendingOperations.clear();
        _pendingOperations.addAll(
          operationsList.map((json) => PendingOperation.fromJson(json)),
        );
      }
    } catch (e) {
      print('Error loading pending operations: $e');
    }
  }

  // Save pending operations to storage
  Future<void> _savePendingOperations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final operationsJson = jsonEncode(
        _pendingOperations.map((op) => op.toJson()).toList(),
      );
      await prefs.setString(_pendingOperationsKey, operationsJson);
    } catch (e) {
      print('Error saving pending operations: $e');
    }
  }

  // Setup connectivity listener
  void _setupConnectivityListener() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        // Device is back online, process pending operations
        _processPendingOperations();
      }
    });
  }

  // Check if device is offline
  Future<bool> isOffline() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult == ConnectivityResult.none;
  }

  // Queue an operation for later execution
  Future<void> queueOperation(PendingOperation operation) async {
    _pendingOperations.add(operation);
    await _savePendingOperations();
  }

  // Process all pending operations when back online
  Future<void> _processPendingOperations() async {
    if (await isOffline()) return;

    final operationsToProcess = List<PendingOperation>.from(_pendingOperations);
    _pendingOperations.clear();
    await _savePendingOperations();

    for (final operation in operationsToProcess) {
      try {
        await _executeOperation(operation);
      } catch (e) {
        // If operation fails, add it back to the queue
        _pendingOperations.add(operation);
        print('Error executing operation: $e');
      }
    }

    if (_pendingOperations.isNotEmpty) {
      await _savePendingOperations();
    }
  }

  // Execute a specific operation
  Future<void> _executeOperation(PendingOperation operation) async {
    switch (operation.type) {
      case OperationType.createProject:
        await _syncService.uploadProject(Project.fromJson(operation.data));
        break;
      case OperationType.updateProject:
        await _syncService.uploadProject(Project.fromJson(operation.data));
        break;
      case OperationType.deleteProject:
        // Handle project deletion
        break;
      case OperationType.createEvent:
        await _syncService.uploadEvent(Event.fromJson(operation.data));
        break;
      case OperationType.updateEvent:
        await _syncService.uploadEvent(Event.fromJson(operation.data));
        break;
      case OperationType.deleteEvent:
        // Handle event deletion
        break;
      case OperationType.createBeneficiary:
        await _syncService.uploadBeneficiary(Beneficiary.fromJson(operation.data));
        break;
      case OperationType.updateBeneficiary:
        await _syncService.uploadBeneficiary(Beneficiary.fromJson(operation.data));
        break;
      case OperationType.deleteBeneficiary:
        // Handle beneficiary deletion
        break;
      case OperationType.createPartner:
        await _syncService.uploadPartner(Partner.fromJson(operation.data));
        break;
      case OperationType.updatePartner:
        await _syncService.uploadPartner(Partner.fromJson(operation.data));
        break;
      case OperationType.deletePartner:
        // Handle partner deletion
        break;
    }
  }

  // Get pending operations count
  int get pendingOperationsCount => _pendingOperations.length;

  // Get all pending operations
  List<PendingOperation> get pendingOperations => List.unmodifiable(_pendingOperations);

  // Clear all pending operations
  Future<void> clearPendingOperations() async {
    _pendingOperations.clear();
    await _savePendingOperations();
  }

  // Retry failed operations
  Future<void> retryFailedOperations() async {
    await _processPendingOperations();
  }

  // Check if there are pending operations
  bool get hasPendingOperations => _pendingOperations.isNotEmpty;

  // Get offline status message
  String getOfflineStatusMessage() {
    if (hasPendingOperations) {
      return '${pendingOperationsCount} opération(s) en attente de synchronisation';
    }
    return 'Mode hors ligne actif';
  }
}

class PendingOperation {
  final String id;
  final OperationType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final int retryCount;

  PendingOperation({
    required this.id,
    required this.type,
    required this.data,
    required this.timestamp,
    this.retryCount = 0,
  });

  factory PendingOperation.fromJson(Map<String, dynamic> json) {
    return PendingOperation(
      id: json['id'],
      type: OperationType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp']),
      retryCount: json['retryCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'retryCount': retryCount,
    };
  }

  PendingOperation copyWith({
    String? id,
    OperationType? type,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    int? retryCount,
  }) {
    return PendingOperation(
      id: id ?? this.id,
      type: type ?? this.type,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

enum OperationType {
  createProject,
  updateProject,
  deleteProject,
  createEvent,
  updateEvent,
  deleteEvent,
  createBeneficiary,
  updateBeneficiary,
  deleteBeneficiary,
  createPartner,
  updatePartner,
  deletePartner,
}
