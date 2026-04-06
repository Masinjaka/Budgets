import 'package:budgets/core/powersync/powersync.dart' as powersync;
import 'package:flutter/material.dart';
import 'package:powersync/powersync.dart';

/// A small banner that appears when the app is offline or syncing.
/// Shows nothing when fully connected and synced.
class SyncStatusWidget extends StatelessWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (!powersync.isPowerSyncInitialized) return const SizedBox.shrink();

    return StreamBuilder<SyncStatus>(
      stream: powersync.db.statusStream,
      builder: (context, snapshot) {
        final status = snapshot.data;

        if (status == null) return const SizedBox.shrink();

        final connected = status.connected;
        final downloading = status.downloading;
        final uploading = status.uploading;

        // Fully connected and idle — show nothing
        if (connected && !downloading && !uploading) {
          return const SizedBox.shrink();
        }

        final (icon, label, color) = _statusInfo(
          connected: connected,
          downloading: downloading,
          uploading: uploading,
        );

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: color.withValues(alpha: 0.15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  (IconData, String, Color) _statusInfo({
    required bool connected,
    required bool downloading,
    required bool uploading,
  }) {
    if (!connected) {
      return (Icons.cloud_off_rounded, 'Hors ligne', Colors.orange);
    }
    if (uploading) {
      return (Icons.cloud_upload_rounded, 'Synchronisation...', Colors.blue);
    }
    if (downloading) {
      return (Icons.cloud_download_rounded, 'Synchronisation...', Colors.blue);
    }
    return (Icons.cloud_done_rounded, 'Connecté', Colors.green);
  }
}
