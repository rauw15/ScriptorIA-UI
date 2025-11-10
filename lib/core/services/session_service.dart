import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';

class SessionService extends WidgetsBindingObserver {
  static const String _lastActiveKey = 'last_active_timestamp';
  static const Duration _sessionTimeout = Duration(minutes: 2);
  final ApiClient _apiClient = ApiClient();

  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
    _updateLastActiveTime();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.resumed) {
      _checkSessionTimeout();
    } else if (state == AppLifecycleState.paused) {
      _updateLastActiveTime();
    }
  }

  Future<void> _updateLastActiveTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastActiveKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> checkSessionTimeout() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActiveTimestamp = prefs.getInt(_lastActiveKey);
    
    if (lastActiveTimestamp == null) {
      await _updateLastActiveTime();
      return;
    }

    final lastActive = DateTime.fromMillisecondsSinceEpoch(lastActiveTimestamp);
    final now = DateTime.now();
    final difference = now.difference(lastActive);

    if (difference >= _sessionTimeout) {
      await _apiClient.deleteToken();
      await prefs.remove(_lastActiveKey);
    } else {
      await _updateLastActiveTime();
    }
  }

  Future<void> _checkSessionTimeout() async {
    await checkSessionTimeout();
  }

  Future<void> resetSession() async {
    await _updateLastActiveTime();
  }
}

