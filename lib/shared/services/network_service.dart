import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

enum NetworkProfile { offline, poor, average, good }

class NetworkService {
  static final NetworkService _i = NetworkService._();
  NetworkService._();
  factory NetworkService() => _i;

  final _controller = StreamController<NetworkProfile>.broadcast();
  Stream<NetworkProfile> get stream => _controller.stream;

  Timer? _timer;
  NetworkProfile _last = NetworkProfile.good;
  NetworkProfile get last => _last;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) async {
      final profile = await _measure();
      _last = profile;
      _controller.add(profile);
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<NetworkProfile> currentProfile() async {
    // Возвращает актуальный профиль, при необходимости измеряет
    try {
      final p = await _measure();
      _last = p;
      return p;
    } catch (_) {
      return _last;
    }
  }

  Future<NetworkProfile> _measure() async {
    final conn = await Connectivity().checkConnectivity();
    if (conn.contains(ConnectivityResult.none)) return NetworkProfile.offline;
    try {
      final sw = Stopwatch()..start();
      final req = await HttpClient()
          .getUrl(Uri.parse('https://www.google.com/generate_204'));
      final resp = await req.close();
      await resp.drain();
      sw.stop();
      final ms = sw.elapsedMilliseconds;
      if (ms > 1500) return NetworkProfile.poor;
      if (ms > 600) return NetworkProfile.average;
      return NetworkProfile.good;
    } catch (_) {
      return NetworkProfile.poor;
    }
  }
}
