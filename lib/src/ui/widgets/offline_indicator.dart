import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/offline_provider.dart';

class OfflineIndicator extends ConsumerWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineStatus = ref.watch(offlineStatusProvider);
    final offlineNotifier = ref.read(offlineStatusProvider.notifier);

    if (!offlineStatus.isOffline && !offlineStatus.hasPendingOperations) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: offlineStatus.isOffline 
          ? Colors.orange 
          : offlineStatus.hasPendingOperations 
            ? Colors.blue 
            : Colors.green,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            offlineStatus.isOffline 
              ? Icons.cloud_off 
              : Icons.sync,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              offlineNotifier.getStatusMessage(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (offlineStatus.hasPendingOperations && !offlineStatus.isOffline)
            IconButton(
              icon: const Icon(
                Icons.sync,
                color: Colors.white,
                size: 16,
              ),
              onPressed: offlineStatus.isProcessingOperations 
                ? null 
                : () => offlineNotifier.clearPendingOperations(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
            ),
        ],
      ),
    );
  }
}
