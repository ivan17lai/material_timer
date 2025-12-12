import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';

import 'util.dart';
import 'theme.dart';
import 'down.dart';
import 'countdown_windows.dart';
import 'config.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:file_selector/file_selector.dart';
import 'dart:io';
import 'timer.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (args.isNotEmpty && args[0] == 'multi_window') {

    final int windowId = int.tryParse(args[1]) ?? 0;

    Map<String, dynamic> argument = {};
    if (args.length > 2 && args[2].isNotEmpty) {
      try {
        argument = jsonDecode(args[2]) as Map<String, dynamic>;
      } catch (e) {
        argument = {};
      }
    }

    runApp(
      MiniTimerWindow(
        windowId: windowId,
        args: argument,
      ),
    );
  } else {

    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;

    TextTheme textTheme = createTextTheme(context, "ABeeZee", "ABeeZee");
    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: brightness == Brightness.light ? theme.light() : theme.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final double baseSize = 16.0;
  bool _isHoverLeft = false;

  // ---- 聲音相關設定（與 config 對應） ----
  AppConfig _config = AppConfig.defaults();
  bool _endSoundEnabled = true; // 結束提示音
  bool _warningSoundEnabled = true; // 即將結束提示音
  int _warningThreshold = 10; // 提示秒數（之後可以做 UI 調整）

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    final cfg = await loadConfig();
    setState(() {
      _config = cfg;
      _endSoundEnabled = cfg.endSoundEnabled;
      _warningSoundEnabled = cfg.warningSoundEnabled;
      _warningThreshold = cfg.warningThreshold;
    });
  }

  Future<void> _saveConfig({String? customPath}) async {
    _config = AppConfig(
      endSoundEnabled: _endSoundEnabled,
      warningSoundEnabled: _warningSoundEnabled,
      warningThreshold: _warningThreshold,
      customEndSoundPath: customPath ?? _config.customEndSoundPath,
    );
    await saveConfig(_config);
  }

  Future<void> _pickCustomEndSound() async {
    final typeGroup = XTypeGroup(
      label: 'audio',
      extensions: ['mp3', 'wav', 'ogg', 'm4a'],
    );

    final XFile? file = await openFile(
      acceptedTypeGroups: [typeGroup],
    );

    if (file == null) return;

    setState(() {
      _config = AppConfig(
        endSoundEnabled: _endSoundEnabled,
        warningSoundEnabled: _warningSoundEnabled,
        warningThreshold: _warningThreshold,
        customEndSoundPath: file.path,
      );
    });

    await saveConfig(_config);
  }

  String _customEndSoundLabel() {
    if (_config.customEndSoundPath == null || _config.customEndSoundPath!.isEmpty) {
      return '預設的提示音效：done.mp3';
    }
    // 只顯示檔名
    final path = _config.customEndSoundPath!;
    final slashIndex = path.replaceAll('\\', '/').lastIndexOf('/');
    final fileName = slashIndex >= 0 ? path.substring(slashIndex + 1) : path;
    return '目前的提示音效：$fileName';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme colors = theme.colorScheme;

    return Scaffold(
      extendBody: true,
      body: Row(
        children: [
          MouseRegion(
            onEnter: (_) => setState(() => _isHoverLeft = true),
            onExit: (_) => setState(() => _isHoverLeft = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: _isHoverLeft ? 400 : 300,
              child: Container(
                padding: const EdgeInsets.all(24.0),
                color: colors.surfaceContainer,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Material Timer',
                      style: textTheme.headlineSmall,
                    ),
                    SizedBox(height: baseSize),
                    Container(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        '版本',
                        style: textTheme.labelMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    SizedBox(height: baseSize / 2),
                    AnimatedContainer(
                      height: 45,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: _isHoverLeft ? 220 : 180,
                      decoration: BoxDecoration(
                        color: colors.tertiaryContainer,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'v1.0.0',
                              style: textTheme.labelSmall?.copyWith(
                                color: colors.onTertiaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              ' 測試版',
                              style: textTheme.labelSmall?.copyWith(
                                color: colors.onTertiaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: baseSize),
                    Container(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        '聲音設定',
                        style: textTheme.labelMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    SizedBox(height: baseSize / 2),

                    // ====== 聲音設定卡片：結束提示音 ======
                    Container(
                      padding: const EdgeInsets.only(
                        left: 24,
                        right: 18,
                        top: 16,
                        bottom: 18,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                          bottomLeft: Radius.circular(5),
                          bottomRight: Radius.circular(5),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.notifications_on,
                                color: colors.onSurfaceVariant,
                                size: 24,
                              ),
                              SizedBox(width: baseSize),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '結束提示音',
                                      style: textTheme.labelLarge?.copyWith(
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      '倒數結束時是否播放音效',
                                      maxLines: 1,
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _endSoundEnabled,
                                activeColor: colors.secondaryContainer,
                                onChanged: (bool value) async {
                                  setState(() {
                                    _endSoundEnabled = value;
                                  });
                                  await _saveConfig();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: baseSize / 4),

                    // ====== 自訂結束提示音（只有在「結束提示音」開啟時顯示） ======
                    if (_endSoundEnabled)
                      GestureDetector(
                        onTap: _pickCustomEndSound,
                        child: Container(
                          padding: const EdgeInsets.only(
                            left: 24,
                            right: 18,
                            top: 16,
                            bottom: 18,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(5),
                              topRight: Radius.circular(5),
                              bottomLeft: Radius.circular(5),
                              bottomRight: Radius.circular(5),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.music_note,
                                    color: colors.onSurfaceVariant,
                                    size: 24,
                                  ),
                                  SizedBox(width: baseSize),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '自訂結束提示音',
                                          style:
                                          textTheme.labelLarge?.copyWith(
                                            color: colors.onSurfaceVariant,
                                          ),
                                        ),
                                        Text(
                                          _customEndSoundLabel(),
                                          maxLines: 1,
                                          softWrap: false,
                                          overflow: TextOverflow.ellipsis,
                                          style: textTheme.bodySmall?.copyWith(
                                            color: colors.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Icon(
                                    Icons.chevron_right,
                                    color: colors.onSurfaceVariant,
                                    size: 24,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (_endSoundEnabled)
                      SizedBox(height: baseSize / 4),

                    // ====== 即將結束提示音 ======
                    Container(
                      padding: const EdgeInsets.only(
                        left: 24,
                        right: 18,
                        top: 16,
                        bottom: 18,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5),
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.timelapse,
                                color: colors.onSurfaceVariant,
                                size: 24,
                              ),
                              SizedBox(width: baseSize),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '即將結束提示音',
                                      maxLines: 1,
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.labelLarge?.copyWith(
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      '時間剩餘${_warningThreshold}秒時播放提示音',
                                      maxLines: 1,
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _warningSoundEnabled,
                                activeColor: colors.secondaryContainer,
                                onChanged: (bool value) async {
                                  setState(() {
                                    _warningSoundEnabled = value;
                                  });
                                  await _saveConfig();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: colors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 5,
                    spreadRadius: 0,
                    offset: const Offset(-8, 0),
                  ),
                ],
              ),
              child: PageView(
                controller: _pageController,
                children: const [
                  DownPage(),
                  TimerPage(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: 70,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colors.secondaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    decoration: BoxDecoration(
                      color: (_currentPage == 0)
                          ? colors.primaryContainer
                          : colors.surfaceVariant,
                      borderRadius: BorderRadius.circular(
                        (_currentPage == 0) ? 24 : 16,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.alarm,
                        color: (_currentPage == 0)
                            ? colors.onPrimaryContainer
                            : colors.onSurfaceVariant,
                        size: 30,
                      ),
                      onPressed: () {
                        _pageController.animateToPage(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                        setState(() {
                          _currentPage = 0;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: baseSize / 2),
                  Container(
                    width: 80,
                    decoration: BoxDecoration(
                      color: (_currentPage == 1)
                          ? colors.primaryContainer
                          : colors.surfaceVariant,
                      borderRadius: BorderRadius.circular(
                        (_currentPage == 1) ? 24 : 16,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.timer_outlined,
                        color: (_currentPage == 1)
                            ? colors.onPrimaryContainer
                            : colors.onSurfaceVariant,
                        size: 30,
                      ),
                      onPressed: () {
                        _pageController.animateToPage(
                          1,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                        setState(() {
                          _currentPage = 1;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
