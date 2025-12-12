import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'theme.dart';
import 'util.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:window_manager/window_manager.dart';
import 'config.dart';

class MiniTimerWindow extends StatelessWidget {
  final int windowId;
  final Map<String, dynamic> args;

  const MiniTimerWindow({
    super.key,
    required this.windowId,
    required this.args,
  });

  @override
  Widget build(BuildContext context) {
    int initSeconds = 25 * 60;

    print(args);
    final data = args['data'];
    if (data is Map && data['initSeconds'] != null) {
      final v = data['initSeconds'];
      if (v is num) {
        initSeconds = v.toInt();
      }
    }

    final brightness = View.of(context).platformDispatcher.platformBrightness;
    TextTheme textTheme = createTextTheme(context, "ABeeZee", "ABeeZee");
    MaterialTheme myTheme = MaterialTheme(textTheme);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: brightness == Brightness.light ? myTheme.light() : myTheme.dark(),
      home: _MiniTimerPage(
        windowId: windowId,
        initSeconds: initSeconds,
      ),
    );
  }
}

class _MiniTimerPage extends StatefulWidget {
  final int windowId;
  final int initSeconds;

  const _MiniTimerPage({
    super.key,
    required this.windowId,
    required this.initSeconds,
  });

  @override
  State<_MiniTimerPage> createState() => _MiniTimerPageState();
}

class _MiniTimerPageState extends State<_MiniTimerPage> {
  late int _seconds;
  late bool _running;
  Timer? _timer;

  // ---- 設定檔 ----
  AppConfig _config = AppConfig.defaults();

  // ---- 音效相關 ----
  final AudioPlayer _endPlayer = AudioPlayer();   // 結束鈴聲
  final AudioPlayer _warnPlayer = AudioPlayer();  // 提示音

  bool _loopEndSound = true;        // 結束鈴聲是否循環
  bool _endSoundEnabled = true;     // 結束提示音是否啟用（由 config 控制）
  bool _enableWarningSound = true;  // 即將結束提示音是否啟用
  int _warningThreshold = 10;       // 還剩幾秒時播提示音

  bool _hasPlayedWarning = false;   // 避免提示音重複播

  @override
  void initState() {
    super.initState();
    _seconds = widget.initSeconds;
    _running = false;
    _initAlwaysOnTop();
    _initConfigAndStart();

  }

  Future<void> _initAlwaysOnTop() async {
    await windowManager.ensureInitialized();
    await windowManager.setAlwaysOnTop(true);
  }

  /// 讀 config，套用開關 & 秒數，然後再開始倒數
  Future<void> _initConfigAndStart() async {
    final cfg = await loadConfig();
    setState(() {
      _config = cfg;
      _endSoundEnabled = cfg.endSoundEnabled;
      _enableWarningSound = cfg.warningSoundEnabled;
      _warningThreshold = cfg.warningThreshold;
    });
    _toggle(); // 讀完設定再開始倒數
  }

  @override
  void dispose() {
    _timer?.cancel();
    _endPlayer.dispose();
    _warnPlayer.dispose();
    super.dispose();
  }

  // 倒數結束時呼叫：播放結束鈴聲
  Future<void> _onTimerFinished() async {
    _hasPlayedWarning = false;
    await _warnPlayer.stop();

    // 如果「結束提示音」關閉，就什麼都不播
    if (!_endSoundEnabled) {
      await _endPlayer.stop();
      return;
    }

    await _endPlayer.stop();
    await _endPlayer.setReleaseMode(
      _loopEndSound ? ReleaseMode.loop : ReleaseMode.stop,
    );

    // 有自訂檔案 → 播電腦檔案；沒有 → 播內建 assets
    final customPath = _config.customEndSoundPath;
    if (customPath != null && customPath.isNotEmpty) {
      await _endPlayer.play(DeviceFileSource(customPath));
    } else {
      await _endPlayer.play(AssetSource('sounds/done.mp3'));
    }
  }

  // 播放提示音
  Future<void> _playWarningSound() async {
    await _warnPlayer.stop();
    await _warnPlayer.play(AssetSource('sounds/alarm_warning.mp3'));
  }

  void _toggle() {
    if (_running) {
      // 暫停
      _timer?.cancel();
      _endPlayer.stop(); // 順便把結束鈴聲停掉
      setState(() => _running = false);
    } else {
      // 開始
      _hasPlayedWarning = false;
      _endPlayer.stop();

      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_seconds <= 0) {
          t.cancel();
          setState(() {
            _running = false;
          });
          _onTimerFinished();
        } else {
          setState(() {
            _seconds--;
          });
          if (_enableWarningSound &&
              !_hasPlayedWarning &&
              _seconds <= _warningThreshold &&
              _seconds > 0
          ) {
            _playWarningSound();
          }
        }
      });

      setState(() => _running = true);
    }
  }

  // 重置：回到起始時間
  void _reset() {
    _timer?.cancel();
    _endPlayer.stop();
    _warnPlayer.stop();
    setState(() {
      _running = false;
      _seconds = widget.initSeconds;
      _hasPlayedWarning = false;

    });
  }

  // +30 秒
  void _add30Seconds() {
    setState(() {
      _seconds += 30;
      if(!_running){
        _toggle();
      }
    });
  }

  String _format() {
    final h = _seconds ~/ 3600;
    final m = (_seconds % 3600) ~/ 60;
    final s = _seconds % 60;
    return '${h.toString().padLeft(2, '0')}:'
        '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: colors.surface,
        body: Center(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                ),
                padding: const EdgeInsets.only(top: 5),
                child: GestureDetector(
                  child: Text(
                    _format(),
                    style: GoogleFonts.robotoMono(
                      fontSize: 36,
                      fontWeight: FontWeight.w500,
                      color: colors.onSurface,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // refresh -> 重置
                  Container(
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.refresh,
                        color: colors.outline,
                        size: 28,
                      ),
                      onPressed: _reset,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 播放 / 暫停
                  Container(
                    decoration: BoxDecoration(
                      color: _running
                          ? colors.secondaryContainer
                          : colors.tertiaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      icon: Icon(
                        _running ? Icons.pause : Icons.play_arrow,
                        color: _running
                            ? colors.onSecondaryContainer
                            : colors.onTertiaryContainer,
                        size: 28,
                      ),
                      onPressed: _toggle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // +30 秒
                  Container(
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.forward_30,
                        color: colors.outline,
                        size: 28,
                      ),
                      onPressed: _add30Seconds,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
