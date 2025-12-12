import 'package:flutter/material.dart';
import 'dart:async';
import 'theme.dart';
import 'package:google_fonts/google_fonts.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  Timer? _timer;
  bool _isRunning = false;

  int _elapsedMillis = 0;   // 用毫秒記時間

  @override
  void initState() {
    super.initState();
  }

  void _start() {
    if (_isRunning) return;

    _isRunning = true;

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _elapsedMillis += 100; // 每次增加 0.1 秒
      });
    });

    setState(() {});
  }

  void _pause() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    setState(() {});
  }

  void _reset() {
    _pause();
    _elapsedMillis = 0;
    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int totalMillis) {
    final totalSeconds = totalMillis ~/ 1000;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
  String _formatTimeDot(int totalMillis) {

    final tenths = ((totalMillis % 1000) ~/ 100); // 0~9

    return '.$tenths';
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _formatTime(_elapsedMillis),
                style: GoogleFonts.robotoMono(
                  fontSize: 72,
                  fontWeight: FontWeight.w400,
                  color: colors.onSurface,
                ),
              ),
              Text(
                _formatTimeDot(_elapsedMillis),
                style: GoogleFonts.robotoMono(
                  fontSize: 48,
                  fontWeight: FontWeight.w400,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 重置
              Container(
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  icon: Icon(Icons.refresh, color: colors.outline, size: 28),
                  onPressed: _reset,
                ),
              ),
              const SizedBox(width: 12),

              // 播放 / 暫停
              Container(
                decoration: BoxDecoration(
                  color: colors.tertiaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  icon: Icon(
                    _isRunning ? Icons.pause : Icons.play_arrow,
                    color: colors.tertiary,
                    size: 28,
                  ),
                  onPressed: () {
                    if (_isRunning) {
                      _pause();
                    } else {
                      _start();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
