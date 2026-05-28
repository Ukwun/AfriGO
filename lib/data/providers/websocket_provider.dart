import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/websocket_service.dart';

/// WebSocket Provider
/// Provides real-time WebSocket connection
/// Used by marketplace for live updates
final websocketProvider = Provider<WebSocketService>((ref) {
  final wsService = ref.watch(websocketServiceProvider);

  // Auto-connect when provider is used
  ref.onDispose(() {
    wsService.disconnect();
  });

  return wsService;
});
