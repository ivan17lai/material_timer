import 'dart:async';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(900,610),
    center: true,
    backgroundColor: Colors.white,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setResizable(false);
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const FloatTimerApp());
}

class FloatTimerApp extends StatelessWidget {
  const FloatTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SettingPage(),
    );
  }
}

//
// =======================
// 設定頁
// =======================
class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool alwaysOnTop = true;
  List<Duration> savedTimers = [];

  int countDownHours = 0;
  int countDownMinutes = 0;
  int countDownSeconds = 0;

  final _controllerHour = TextEditingController(text: "00");
  final _controllerMin = TextEditingController(text: "00");
  final _controllerSec = TextEditingController(text: "00");

  final _focusHour = FocusNode();
  final _focusMin = FocusNode();
  final _focusSec = FocusNode();


  bool hovering = false;
  bool editing = false;
  final _focusNode = FocusNode();
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = countDownHours.toString().padLeft(2, '0');
    _loadTimers();
  }

  Future<void> _saveTimers() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> stringList = savedTimers.map((d) => d.inSeconds.toString()).toList();
    await prefs.setStringList('saved_timers', stringList);
  }

  Future<void> _loadTimers() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? stringList = prefs.getStringList('saved_timers');
    if (stringList != null) {
      setState(() {
        savedTimers = stringList.map((s) => Duration(seconds: int.parse(s))).toList();
      });
    }
  }


  Widget _timeBox({
    required String label,
    required int value,
    required TextEditingController controller,
    required FocusNode focusNode,
    required Function(int) onChanged,
  }) {
    bool hovering = false;
    bool editing = false;
    bool isPressing = false;        // ✅ 按住箭頭期間，不要讓 onExit 把 hover 關掉
    Timer? holdTimer;               // ✅ 保持選中用計時器

    return StatefulBuilder(
      builder: (context, setLocal) {
        void updateValue(int newVal) {
          onChanged(newVal);
          controller.text = newVal.toString().padLeft(2, '0');
        }

        void keepSelectedFor(Duration d) {
          holdTimer?.cancel();
          setLocal(() => hovering = true); // 只要有操作就維持 hover
          holdTimer = Timer(d, () {
            // 2 秒到期才會把 hover 關掉；有焦點就繼續留著
            if (!focusNode.hasFocus && !isPressing) {
              setLocal(() {
                hovering = false;
                editing = false;
              });
            }
          });
        }

        return MouseRegion(
          onEnter: (_) => setLocal(() => hovering = true),
          onExit: (_) {
            // ✅ 只有不在按壓、也沒焦點時，才考慮關閉
            if (isPressing || focusNode.hasFocus) {
              // 什麼都不做，維持選中
              return;
            }
            // 給一個寬限時間；滑鼠離開也先撐 2 秒
            keepSelectedFor(const Duration(seconds: 2));
          },
          child: GestureDetector(
            onTap: () {
              setLocal(() {
                editing = true;
                focusNode.requestFocus();
                controller.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: controller.text.length,
                );
              });
              keepSelectedFor(const Duration(seconds: 2));
            },
            child: Container(
              width: 160,
              height: 160,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: hovering ? Colors.grey.shade400 : Colors.transparent,
                ),
                boxShadow: [
                  if (hovering)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // ===== 顯示 / 編輯 =====
                  editing
                      ? RawKeyboardListener(
                    focusNode: focusNode,
                    onKey: (event) {
                      if (event is! RawKeyDownEvent) return;
                      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                        updateValue((value + 1).clamp(0, 99));
                        keepSelectedFor(const Duration(seconds: 2));
                      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                        updateValue((value - 1).clamp(0, 99));
                        keepSelectedFor(const Duration(seconds: 2));
                      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
                        final val = int.tryParse(controller.text) ?? value;
                        updateValue(val.clamp(0, 99));
                        setLocal(() => editing = false);
                        focusNode.unfocus();
                        keepSelectedFor(const Duration(seconds: 2));
                      }
                    },
                    child: Focus(
                      onFocusChange: (hasFocus) {
                        if (!hasFocus) setLocal(() => editing = false);
                      },
                      child: TextField(
                        controller: controller,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Consolas',
                        ),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  )
                      : Text(
                    value.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Consolas',
                    ),
                  ),

                  // ===== 上下箭頭（穩定版）=====
                  if (hovering)
                    Positioned(
                      right: 6,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Listener(
                            onPointerDown: (_) {
                              isPressing = true;
                              focusNode.requestFocus();
                              setLocal(() => hovering = true);
                              updateValue((value + 1).clamp(0, 99));
                              keepSelectedFor(const Duration(seconds: 2));
                            },
                            onPointerUp: (_) {
                              isPressing = false;
                              keepSelectedFor(const Duration(seconds: 2));
                            },
                            child: _arrowButton(Icons.keyboard_arrow_up, () {}),
                          ),
                          const SizedBox(height: 6),
                          Listener(
                            onPointerDown: (_) {
                              isPressing = true;
                              focusNode.requestFocus();
                              setLocal(() => hovering = true);
                              updateValue((value - 1).clamp(0, 99));
                              keepSelectedFor(const Duration(seconds: 2));
                            },
                            onPointerUp: (_) {
                              isPressing = false;
                              keepSelectedFor(const Duration(seconds: 2));
                            },
                            child: _arrowButton(Icons.keyboard_arrow_down, () {}),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }






  Future<void> _startFloatTimer() async {
    final totalSeconds =
        countDownHours * 3600 + countDownMinutes * 60 + countDownSeconds;
    final duration = Duration(seconds: totalSeconds);

    await windowManager.setSize(const Size(300, 120));
    await windowManager.setAlwaysOnTop(alwaysOnTop);
    await windowManager.center();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => FloatTimerWindow(initialDuration: duration),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 230, 230, 230),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==== 可拖曳的頂欄 ====
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (_) async => await windowManager.startDragging(),
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    _macButton(
                      color: Colors.red,
                      icon: Icons.close_rounded,
                      iconColor: Colors.white,
                      onTap: () async => await windowManager.close(),
                    ),
                    const SizedBox(width: 8),
                    _macButton(
                      color: Colors.amber,
                      icon: Icons.remove_rounded,
                      iconColor: Colors.black,
                      onTap: () async => await windowManager.minimize(),
                    ),
                    const SizedBox(width: 8),
                    _macButton(
                      color: Colors.green,
                      icon: Icons.play_arrow_rounded,
                      iconColor: Colors.white,
                      onTap: _startFloatTimer,
                    ),


                    const Spacer(),
                    const Text(
                      'Material Timer',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const Spacer(),
                    _macButton(
                      color: Colors.grey,
                      icon: Icons.settings,
                      iconColor: Colors.white,
                      onTap: () async {

                      },
                    ),
                  ],
                ),
              ),
            ),

            // ==== 時間區域 ====
            Container(
              height: 350,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    margin: const EdgeInsets.only(left: 12, right: 12),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.arrow_left, size: 28),
                  ),

                  // ======== 小時 ========
                  _timeBox(
                    label: "時",
                    value: countDownHours,
                    controller: _controllerHour,
                    focusNode: _focusHour,
                    onChanged: (v) => setState(() => countDownHours = v),
                  ),

                  const Text(":", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

                  // ======== 分鐘 ========
                  _timeBox(
                    label: "分",
                    value: countDownMinutes,
                    controller: _controllerMin,
                    focusNode: _focusMin,
                    onChanged: (v) => setState(() => countDownMinutes = v),
                  ),

                  const Text(":", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

                  // ======== 秒數 ========
                  _timeBox(
                    label: "秒",
                    value: countDownSeconds,
                    controller: _controllerSec,
                    focusNode: _focusSec,
                    onChanged: (v) => setState(() => countDownSeconds = v),
                  ),

                  Container(
                    width: 50,
                    height: 50,
                    margin: const EdgeInsets.only(left: 12, right: 12),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.arrow_right, size: 28),
                  ),
                ],
              ),
            ),

            Container(
              width: 900,
              padding: EdgeInsets.only(left: 36,bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: _startFloatTimer,
                    focusColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    child: Container(
                      width: 45,
                      height: 45,
                      margin: EdgeInsets.only(top: 20),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(200, 100, 100, 255),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Center(
                        child:Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  InkWell(
                    focusColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onTap: (){
                      countDownHours = 0;
                      countDownMinutes = 0;
                      countDownSeconds = 0;
                      _controllerHour.text = '00';
                      _controllerMin.text = '00';
                      _controllerSec.text = '00';
                      setState(() {

                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      margin: EdgeInsets.only(top: 20),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(70, 100, 100, 255),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child:Icon(
                          Icons.refresh,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: EdgeInsets.only(left: 36,bottom: 10),
              child: Text(
                '已儲存的計時器 (按兩下直接開始)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 36),
              child: Row(
                children: [
                  // ==== 動態生成所有已儲存計時器 ====
                  ...savedTimers.map((d) {
                    final h = d.inHours.toString().padLeft(2, '0');
                    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
                    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            countDownHours = d.inHours;
                            countDownMinutes = d.inMinutes % 60;
                            countDownSeconds = d.inSeconds % 60;
                            _controllerHour.text = h;
                            _controllerMin.text = m;
                            _controllerSec.text = s;
                          });
                        },
                        onDoubleTap: () {
                          setState(() {
                            countDownHours = d.inHours;
                            countDownMinutes = d.inMinutes % 60;
                            countDownSeconds = d.inSeconds % 60;
                            _controllerHour.text = h;
                            _controllerMin.text = m;
                            _controllerSec.text = s;
                          });
                          _startFloatTimer();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              "$h:$m:$s",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),

                  // ==== 新增「＋」按鈕 ====
                  GestureDetector(
                    onTap: () async {
                      final total = countDownHours * 3600 +
                          countDownMinutes * 60 +
                          countDownSeconds;
                      if (total == 0) return;
                      final newDuration = Duration(seconds: total);

                      setState(() {
                        if (!savedTimers.contains(newDuration)) {
                          savedTimers.add(newDuration);
                        }
                      });

                      await _saveTimers(); //儲存到本地
                    },

                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(70, 100, 100, 255),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      height: 40,
                      width: 40,
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),


            const SizedBox(height: 20),
            // Container(
            //   padding: const EdgeInsets.all(12),
            //   margin: const EdgeInsets.all(12),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       const Text('設定',
            //           style:
            //           TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            //       const SizedBox(height: 10),
            //       Container(
            //         padding: const EdgeInsets.symmetric(horizontal: 18),
            //         height: 60,
            //         decoration: BoxDecoration(
            //           color: Colors.white,
            //           borderRadius: BorderRadius.circular(18),
            //         ),
            //         child: Row(
            //           children: const [
            //             Text('Always on Top', style: TextStyle(fontSize: 16)),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _arrowButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            )
          ],
        ),
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 16, color: Colors.black54),
      ),
    );
  }

  Widget _macButton({
    required Color color,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 10),
      ),
    );
  }
}


// =======================
// 浮動計時器視窗
// =======================

class FloatTimerWindow extends StatefulWidget {
  final Duration initialDuration;
  const FloatTimerWindow({super.key, required this.initialDuration});

  @override
  State<FloatTimerWindow> createState() => _FloatTimerWindowState();
}

class _FloatTimerWindowState extends State<FloatTimerWindow> {
  late Duration remaining;
  Timer? timer;
  Timer? blinkTimer;
  bool running = true;
  bool hoveringWindow = false;
  bool hoveringButtons = false;
  bool _isBlinking = false;
  bool _blinkVisible = true;

  final AudioPlayer _alarmPlayer = AudioPlayer();
  bool _isAlarmPlaying = false;

  Future<void> _playAlarm() async {
    if (_isAlarmPlaying) return; // 防止重複播放
    _isAlarmPlaying = true;

    await _alarmPlayer.setReleaseMode(ReleaseMode.loop); // 🔁 持續重複播放
    await _alarmPlayer.play(AssetSource('sounds/done.mp3')); // 播放你的音效
  }

  Future<void> _stopAlarm() async {
    if (_isAlarmPlaying) {
      await _alarmPlayer.stop(); // 立即停止
      _isAlarmPlaying = false;
    }
  }

  @override
  void initState() {
    super.initState();
    remaining = widget.initialDuration;
    _startCountdown();
  }

  // 啟動倒數計時
  void _startCountdown() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (remaining.inSeconds > 0 && running) {
        setState(() => remaining -= const Duration(seconds: 1));
      } else if (remaining.inSeconds <= 0) {
        timer?.cancel();
        setState(() => running = false);
        _startBlink();
        _playAlarm(); //播放提示音
      }




    });
  }

  void _startBlink() {
    if (_isBlinking) return;
    setState(() => _isBlinking = true);
    blinkTimer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      if (!mounted) return;
      setState(() => _blinkVisible = !_blinkVisible);
    });
  }

  void _stopBlink() {
    blinkTimer?.cancel();
    setState(() {
      _isBlinking = false;
      _blinkVisible = true;
    });
  }

  void _togglePause() {
    setState(() {
      running = !running;
      if (running && remaining.inSeconds > 0) {
        _stopBlink();
        _startCountdown();
      }
    });
  }

  void _reset() {
    timer?.cancel();
    _stopBlink();
    _stopAlarm(); // 關閉提示音
    setState(() {
      remaining = widget.initialDuration;
      running = false;
    });
  }


  @override
  void dispose() {
    timer?.cancel();
    blinkTimer?.cancel();
    _alarmPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String timeStr =
        "${remaining.inHours.toString().padLeft(2, '0')}:${(remaining.inMinutes % 60).toString().padLeft(2, '0')}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}";

    return MouseRegion(
      onEnter: (_) => setState(() => hoveringWindow = true),
      onExit: (_) => setState(() {
        hoveringWindow = false;
        hoveringButtons = false;
      }),
      child: GestureDetector(
        onPanStart: (details) async {
          if (details.localPosition.dy > 30) {
            await windowManager.startDragging();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: hoveringWindow
                ? const Color.fromARGB(255, 50, 50, 50)
                : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // mac 紅鍵
                  Row(
                    children: [
                      AnimatedOpacity(
                        opacity: hoveringWindow ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: GestureDetector(
                          onTap: () async {
                            _stopAlarm(); // 關閉提示音
                            await windowManager.setAlwaysOnTop(false);
                            await windowManager.setSize(const Size(900, 610));
                            await windowManager.center();
                            await Future.delayed(
                                const Duration(milliseconds: 150));
                            if (!mounted) return;
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (_) => const SettingPage()),
                                  (route) => false,
                            );
                          },
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded,
                                size: 10, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 時間顯示
                  AnimatedOpacity(
                    opacity: _blinkVisible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 36,
                        color:
                        hoveringWindow ? Colors.black12 : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Consolas',
                      ),
                    ),
                  ),

                  const Spacer(),
                ],
              ),

              // 中央浮動按鈕
              MouseRegion(
                onEnter: (_) => setState(() => hoveringButtons = true),
                onExit: (_) => setState(() => hoveringButtons = false),
                child: AnimatedOpacity(
                  opacity: hoveringButtons ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 暫停/繼續
                      GestureDetector(
                        onTap: _togglePause,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: running
                                ? const Color.fromARGB(255, 80, 80, 135)
                                : const Color.fromARGB(255, 100, 100, 255),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            running
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 重設
                      GestureDetector(
                        onTap: _reset,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color:
                            const Color.fromARGB(160, 100, 100, 100),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
