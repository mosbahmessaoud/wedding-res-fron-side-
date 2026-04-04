// lib/services/connectivity_service.dart
import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';


class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  
  bool _isOnline = true;
  bool get isOnline => _isOnline;
  
  // Callbacks for connectivity changes
  final List<Function(bool)> _listeners = [];
  
  // In ConnectivityService class

Future<bool> checkRealInternet() async {
  try {
    final result = await InternetAddress.lookup('google.com')
        .timeout(const Duration(seconds: 5));
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  } on TimeoutException catch (_) {
    return false;
  }
}

void initialize() {
  _checkConnectivity();
  _subscription = _connectivity.onConnectivityChanged.listen((result) {
    _handleConnectivityChange(result);
  });
}

Future<void> _checkConnectivity() async {
  try {
    final result = await _connectivity.checkConnectivity();
    // First check adapter
    final hasAdapter = !result.contains(ConnectivityResult.none);
    if (!hasAdapter) {
      _updateOnlineStatus(false);
      return;
    }
    // Then verify real internet
    final hasInternet = await checkRealInternet();
    _updateOnlineStatus(hasInternet);
  } catch (e) {
    print('Error checking connectivity: $e');
    _updateOnlineStatus(false);
  }
}

void _updateOnlineStatus(bool isOnline) {
  final wasOnline = _isOnline;
  _isOnline = isOnline;
  if (wasOnline != _isOnline) {
    print('Connectivity changed: ${_isOnline ? "Online" : "Offline"}');
    for (var listener in _listeners) {
      listener(_isOnline);
    }
  }
}

void _handleConnectivityChange(List<ConnectivityResult> result) async {
  final hasAdapter = !result.contains(ConnectivityResult.none);
  if (!hasAdapter) {
    _updateOnlineStatus(false);
    return;
  }
  // Debounce: wait a moment for the connection to stabilize
  await Future.delayed(const Duration(milliseconds: 500));
  final hasInternet = await checkRealInternet();
  _updateOnlineStatus(hasInternet);
}


  // Add listener for connectivity changes
  void addListener(Function(bool isOnline) callback) {
    _listeners.add(callback);
  }
  
  // Remove listener
  void removeListener(Function(bool isOnline) callback) {
    _listeners.remove(callback);
  }
  
  // Dispose
  void dispose() {
    _subscription?.cancel();
    _listeners.clear();
  }
}

// Widget to show connectivity status
class ConnectivityBanner extends StatefulWidget {
  final Widget child;
  
  const ConnectivityBanner({Key? key, required this.child}) : super(key: key);
  
  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  bool _isOnline = true;
  bool _showBanner = false;
  
  @override
  void initState() {
    super.initState();
    ConnectivityService().addListener(_onConnectivityChanged);
    _isOnline = ConnectivityService().isOnline;
  }
  
  void _onConnectivityChanged(bool isOnline) {
    setState(() {
      _isOnline = isOnline;
      _showBanner = true;
    });
    
    // Hide banner after 3 seconds if back online
    if (isOnline) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showBanner = false;
          });
        }
      });
    }
  }
  
  @override
  void dispose() {
    ConnectivityService().removeListener(_onConnectivityChanged);
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showBanner || !_isOnline)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              color: _isOnline ? Colors.green : Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: SafeArea(
                bottom: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isOnline ? Icons.wifi : Icons.wifi_off,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isOnline 
                        ? 'تم استعادة الاتصال بالإنترنت' 
                        : 'لا يوجد اتصال بالإنترنت',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}