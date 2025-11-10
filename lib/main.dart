import 'dart:async';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/services.dart';

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

    return StatefulBuilder(
      builder: (context, setLocal) {
        return MouseRegion(
          onEnter: (_) => setLocal(() => hovering = true),
          onExit: (_) => setLocal(() {
            hovering = false;
            editing = false;
            focusNode.unfocus();
          }),
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
            },
            child: Container(
              width: 160,
              height: 160,
              margin: const EdgeInsets.only(left: 12, right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  if (hovering)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                ],
                border: Border.all(
                  color: hovering ? Colors.grey.shade400 : Colors.transparent,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  editing
                      ? RawKeyboardListener(
                    focusNode: focusNode,
                    onKey: (event) {
                      if (event is! RawKeyDownEvent) return;

                      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                        onChanged((value + 1).clamp(0, 99));
                        controller.text =
                            (value + 1).clamp(0, 99).toString().padLeft(2, '0');
                      } else if (event.logicalKey ==
                          LogicalKeyboardKey.arrowDown) {
                        onChanged((value - 1).clamp(0, 99));
                        controller.text =
                            (value - 1).clamp(0, 99).toString().padLeft(2, '0');
                      } else if (event.logicalKey ==
                          LogicalKeyboardKey.enter) {
                        final val = int.tryParse(controller.text) ?? value;
                        onChanged(val.clamp(0, 99));
                        controller.text =
                            val.clamp(0, 99).toString().padLeft(2, '0');
                        setLocal(() => editing = false);
                        focusNode.unfocus();
                      }
                    },
                    child: TextField(
                      controller: controller,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                      ),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  )
                      : Text(
                    value.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (hovering)
                    Positioned(
                      right: 6,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _arrowButton(Icons.keyboard_arrow_up, () {
                            onChanged((value + 1).clamp(0, 99));
                            controller.text =
                                (value + 1).clamp(0, 99).toString().padLeft(2, '0');
                          }),
                          const SizedBox(height: 6),
                          _arrowButton(Icons.keyboard_arrow_down, () {
                            onChanged((value - 1).clamp(0, 99));
                            controller.text =
                                (value - 1).clamp(0, 99).toString().padLeft(2, '0');
                          }),
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
                  Container(
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
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: EdgeInsets.only(left: 36,bottom: 10),
              child: Text(
                '已儲存的計時器',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 36),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        countDownHours = 0;
                        countDownMinutes = 5;
                        countDownSeconds = 0;
                        _controllerHour.text = '00';
                        _controllerMin.text = '05';
                        _controllerSec.text = '00';
                      });
                    },
                    onDoubleTap: (){
                      setState(() {
                        countDownHours = 0;
                        countDownMinutes = 1;
                        countDownSeconds = 30;
                        _controllerHour.text = '00';
                        _controllerMin.text = '01';
                        _controllerSec.text = '30';
                      });
                      _startFloatTimer();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      height: 50,
                      child: Center(
                        child: Text(
                          '00:05:00',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        countDownHours = 0;
                        countDownMinutes = 1;
                        countDownSeconds = 30;
                        _controllerHour.text = '00';
                        _controllerMin.text = '01';
                        _controllerSec.text = '30';
                      });
                    },
                    onDoubleTap: (){
                      setState(() {
                        countDownHours = 0;
                        countDownMinutes = 1;
                        countDownSeconds = 30;
                        _controllerHour.text = '00';
                        _controllerMin.text = '01';
                        _controllerSec.text = '30';
                      });
                      _startFloatTimer();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      height: 50,
                      child: Center(
                        child: Text(
                          '00:01:30',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(70, 100, 100, 255),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    height: 40,
                    width: 40,
                    child: Icon(
                        Icons.add,
                        color: Colors.white,
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
    setState(() {
      remaining = widget.initialDuration;
      running = false;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    blinkTimer?.cancel();
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
