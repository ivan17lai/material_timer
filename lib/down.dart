import 'package:flutter/material.dart';
import 'util.dart';
import 'theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:async/async.dart';
import 'dart:async';
import 'dart:convert';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'config.dart';

class DownPage extends StatefulWidget {
  const DownPage({super.key});

  @override
  State<DownPage> createState() => _DownPageState();
}

class _DownPageState extends State<DownPage> {
  List<int> pickTime = [0, 0, 0];
  int pickedIndex = 0;

  /// ✅ 儲存的 timer（秒），最多三個（由 config.dart 的 loadSavedTimers 保證）
  List<int> savedTimes = [];

  /// ✅ 刪除模式：true 時點擊 Saved Timer 會刪除
  bool _deleteMode = false;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final list = await loadSavedTimers();
    if (!mounted) return;
    setState(() => savedTimes = list);
  }

  int _toSeconds(List<int> hms) {
    return hms[0] * 3600 + hms[1] * 60 + hms[2];
  }

  void _applySecondsToPicker(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;

    setState(() {
      pickTime = [h, m, s];
      pickedIndex = 3;
    });
  }

  String _formatSeconds(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return '${h.toString().padLeft(2, '0')}:'
        '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';
  }

  Future<void> _saveCurrentTimer() async {
    final totalSeconds = _toSeconds(pickTime);
    if (totalSeconds <= 0) return;

    await saveTimer(totalSeconds);
    final list = await loadSavedTimers();
    if (!mounted) return;
    setState(() => savedTimes = list);
  }

  Future<void> _removeSavedTimer(int seconds) async {
    await removeTimer(seconds);
    final list = await loadSavedTimers();
    if (!mounted) return;

    setState(() {
      savedTimes = list;

      // ✅ 如果刪到沒東西了，自動離開刪除模式（可選，但體驗好）
      if (savedTimes.isEmpty) {
        _deleteMode = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme colors = theme.colorScheme;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),

            // =========================
            // 上方：時間選擇（H/M/S）
            // =========================
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TimePickerBox(
                  size: w * 0.12,
                  borderRadius: (pickedIndex == 0) ? 24 : 40,
                  picked: pickedIndex == 0,
                  background: (pickedIndex == 0)
                      ? colors.secondaryContainer
                      : colors.surface,
                  textStyle: GoogleFonts.robotoMono(
                    fontSize: textTheme.displayLarge?.fontSize ?? 48,
                  ),
                  text: pickTime[0].toString().padLeft(2, '0'),
                  onTapHalf: (isUp) {
                    if (pickedIndex == 0) {
                      if (isUp) {
                        if (pickTime[0] < 99) pickTime[0]++;
                      } else {
                        if (pickTime[0] > 0) pickTime[0]--;
                      }
                    } else {
                      pickedIndex = 0;
                    }
                    setState(() {});
                  },
                ),
                SizedBox(width: w * 0.01),
                TimePickerBox(
                  size: w * 0.12,
                  borderRadius: (pickedIndex == 1) ? 24 : 40,
                  picked: pickedIndex == 1,
                  background: (pickedIndex == 1)
                      ? colors.secondaryContainer
                      : colors.surface,
                  textStyle: GoogleFonts.robotoMono(
                    fontSize: textTheme.displayLarge?.fontSize ?? 48,
                  ),
                  text: pickTime[1].toString().padLeft(2, '0'),
                  onTapHalf: (isUp) {
                    if (pickedIndex == 1) {
                      if (isUp) {
                        if (pickTime[1] < 59) pickTime[1]++;
                      } else {
                        if (pickTime[1] > 0) pickTime[1]--;
                      }
                    } else {
                      pickedIndex = 1;
                    }
                    setState(() {});
                  },
                ),
                SizedBox(width: w * 0.01),
                TimePickerBox(
                  size: w * 0.12,
                  borderRadius: (pickedIndex == 2) ? 24 : 40,
                  picked: pickedIndex == 2,
                  background: (pickedIndex == 2)
                      ? colors.secondaryContainer
                      : colors.surface,
                  textStyle: GoogleFonts.robotoMono(
                    fontSize: textTheme.displayLarge?.fontSize ?? 48,
                  ),
                  text: pickTime[2].toString().padLeft(2, '0'),
                  onTapHalf: (isUp) {
                    if (pickedIndex == 2) {
                      if (isUp) {
                        if (pickTime[2] < 59) pickTime[2]++;
                      } else {
                        if (pickTime[2] > 0) pickTime[2]--;
                      }
                    } else {
                      pickedIndex = 2;
                    }
                    setState(() {});
                  },
                ),
              ],
            ),

            const SizedBox(height: 30),

            // =========================
            // 中間：控制按鈕
            // =========================
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // refresh -> 重置
                Container(
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: colors.outline,
                      size: 32,
                    ),
                    onPressed: () {
                      pickTime = [0, 0, 0];
                      pickedIndex = 3;
                      setState(() {});
                    },
                  ),
                ),

                const SizedBox(width: 10),

                // play -> 開小窗（並且自動存到 saved timers）
                Container(
                  decoration: BoxDecoration(
                    color: colors.tertiaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.play_arrow,
                      color: colors.onTertiaryContainer,
                      size: 32,
                    ),
                    onPressed: () async {
                      final int totalSeconds = _toSeconds(pickTime);

                      if (totalSeconds <= 0) return;

                      // ✅ 開窗前也存起來（最新在最前，最多三個）
                      await saveTimer(totalSeconds);
                      final list = await loadSavedTimers();
                      if (mounted) setState(() => savedTimes = list);

                      await openNewWindow(
                        type: "timer",
                        title: "Material Timer",
                        data: {
                          "initSeconds": totalSeconds,
                          "mainWindowId": 0,
                        },
                        position: const Offset(1400, 200),
                        size: const Size(280, 170),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 16),

                // bookmark_add -> 只儲存（不開窗）
                Container(
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.bookmark_add,
                      color: colors.outline,
                      size: 28,
                    ),
                    onPressed: () async {
                      await _saveCurrentTimer();
                    },
                  ),
                ),
              ],
            ),

            const Spacer(),

            // =========================
            // 下方：Saved Timer（最多三個）
            // 1) 右側編輯 icon：切換刪除模式
            // 2) 刪除模式時點 chip 刪除；非刪除模式點 chip 套用
            // =========================
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 4),
                    Text(
                      "Saved Timer",
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(width: 6),
                  ],
                ),
                const SizedBox(height: 10),

                if (savedTimes.isEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    child: Text(
                      "沒有已儲存的計時器",
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: savedTimes.take(3).map((sec) {
                          return GestureDetector(
                            onTap: () async {
                              if (_deleteMode) {
                                await _removeSavedTimer(sec);
                              } else {
                                _applySecondsToPicker(sec);
                              }
                            },

                            onLongPress: () async {
                              await _removeSavedTimer(sec);
                            },

                            child: Container(
                              decoration: BoxDecoration(
                                color: _deleteMode? colors.errorContainer : colors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.only(
                                left: 18,
                                right: 18,
                                top: 8,
                                bottom: 8,
                              ),
                              child: Text(
                                _formatSeconds(sec),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.robotoMono(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: colors.onSurface,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(width: 8),
                      // 編輯/刪除模式按鈕
                      Container(
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: IconButton(
                          tooltip: _deleteMode ? '刪除模式' : '編輯',
                          icon: Icon(
                            _deleteMode ? Icons.clear : Icons.edit,
                            color: _deleteMode ? Colors.red : colors.outline,
                            size: 18,
                          ),
                          onPressed: () {
                            setState(() {
                              _deleteMode = !_deleteMode;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TimePickerBox extends StatefulWidget {
  final double size;
  final bool picked;
  final Color background;
  final TextStyle textStyle;
  final String text;
  final double borderRadius;
  final void Function(bool isUp) onTapHalf;

  const TimePickerBox({
    super.key,
    required this.size,
    required this.picked,
    required this.background,
    required this.textStyle,
    required this.text,
    required this.borderRadius,
    required this.onTapHalf,
  });

  @override
  State<TimePickerBox> createState() => _TimePickerBoxState();
}

class _TimePickerBoxState extends State<TimePickerBox> {
  Timer? _holdTimer;
  bool _isUp = true;

  void _startHoldTimer() {
    _holdTimer?.cancel();
    _holdTimer = Timer.periodic(
      const Duration(milliseconds: 100),
          (_) {
        widget.onTapHalf(_isUp);
      },
    );
  }

  void _stopHoldTimer() {
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  @override
  void dispose() {
    _stopHoldTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;

    return GestureDetector(
      onTapDown: (details) {
        final local = details.localPosition;
        _isUp = local.dy < size / 2;
        widget.onTapHalf(_isUp);
      },
      onLongPressStart: (details) {
        final local = details.localPosition;
        _isUp = local.dy < size / 2;
        _startHoldTimer();
      },
      onLongPressEnd: (_) => _stopHoldTimer(),
      onLongPressCancel: _stopHoldTimer,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        width: widget.picked ? size * 1.2 : size,
        height: size,
        decoration: BoxDecoration(
          color: widget.background,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: Center(
          child: Text(
            widget.text,
            style: widget.textStyle,
          ),
        ),
      ),
    );
  }
}

// open countdown window
Future<int> openNewWindow({
  required String type, // timer
  Map<String, dynamic>? data, // 傳給子視窗的資料
  Offset position = const Offset(1200, 200), // 預設位置
  Size size = const Size(280, 100), // 預設視窗大小
  String title = "New Window", // 視窗標題
}) async {
  final window = await DesktopMultiWindow.createWindow(
    jsonEncode({
      "type": type,
      "data": data ?? {},
    }),
  );

  window
    ..setFrame(position & size)
    ..setTitle(title)
    ..show();

  return window.windowId;
}
