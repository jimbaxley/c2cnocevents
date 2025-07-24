import 'package:flutter/material.dart';
import 'package:c2c_noc_events/services/fcm_service.dart';

class FCMStatusWidget extends StatefulWidget {
  const FCMStatusWidget({super.key});

  @override
  State<FCMStatusWidget> createState() => _FCMStatusWidgetState();
}

class _FCMStatusWidgetState extends State<FCMStatusWidget> {
  String _status = 'Checking FCM status...';
  String? _token;

  @override
  void initState() {
    super.initState();
    _checkFCMStatus();
  }

  Future<void> _checkFCMStatus() async {
    try {
      String? token = await FCMService.getToken();
      setState(() {
        if (token != null && token.isNotEmpty) {
          _token = token;
          _status = '✅ FCM Token: ${token.substring(0, 20)}...';
        } else {
          _status = '❌ No FCM token available';
        }
      });
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
      });
    }
  }

  Future<void> _resubscribeToEvents() async {
    setState(() {
      _status = 'Resubscribing to events topic...';
    });

    await FCMService.subscribeToTopic('events');
    await _checkFCMStatus();

    setState(() {
      _status = '$_status\n✅ Resubscribed to events topic';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'FCM Status (Debug)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _status,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _checkFCMStatus,
                  child: const Text('Refresh'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _resubscribeToEvents,
                  child: const Text('Resubscribe'),
                ),
                const SizedBox(width: 8),
                if (_token != null)
                  ElevatedButton(
                    onPressed: () {
                      FCMService.printCurrentToken();
                    },
                    child: const Text('Print Token'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
