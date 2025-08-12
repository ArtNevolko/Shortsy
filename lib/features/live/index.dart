import 'package:flutter/material.dart';
import 'live_screen.dart' show LiveEmbedded, LiveEmbeddedController;

enum LiveMode { host, viewer }

class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key, this.mode});
  final LiveMode? mode;
  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  final _ctrl = LiveEmbeddedController();
  bool _onAir = false;

  @override
  Widget build(BuildContext context) {
    final mode = widget.mode ?? LiveMode.host;
    final isHost = mode == LiveMode.host;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(isHost ? 'Прямой эфир' : 'Просмотр эфира')),
      body: Center(
          child: AspectRatio(
              aspectRatio: 9 / 16, child: LiveEmbedded(controller: _ctrl))),
      floatingActionButton: isHost
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_onAir)
                  FloatingActionButton.small(
                    heroTag: 'sw',
                    onPressed: () => _ctrl.switchCamera?.call(),
                    child: const Icon(Icons.cameraswitch),
                  ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'live',
                  backgroundColor: _onAir ? Colors.red : Colors.green,
                  onPressed: () async {
                    if (_onAir) {
                      await _ctrl.stop?.call();
                      if (mounted) setState(() => _onAir = false);
                    } else {
                      if (mounted) setState(() => _onAir = true);
                      await WidgetsBinding.instance.endOfFrame;
                      await _ctrl.startHost?.call();
                    }
                  },
                  child: Icon(_onAir ? Icons.stop : Icons.wifi_tethering),
                ),
              ],
            )
          : null,
    );
  }
}
