import 'package:flutter/material.dart';
import 'util.dart';
import 'theme.dart';
import 'package:flutter/cupertino.dart';

import 'down.dart';
import 'dart:convert';
import 'countdown_windows.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';


Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // print('main args: $args');

  if (args.isNotEmpty && args[0] == 'multi_window') {

    final int windowId = int.tryParse(args[1]) ?? 0;

    Map<String, dynamic> argument = {};
    if (args.length > 2 && args[2].isNotEmpty) {
      try {
        argument = jsonDecode(args[2]) as Map<String, dynamic>;
      } catch (e) {
        // print('json decode error: $e');
        argument = {};
      }
    }

    runApp(MiniTimerWindow(
      windowId: windowId,
      args: argument,
    ));
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

  PageController _pageController = PageController();
  int _currentPage = 0;
  final double base_Size = 16.0;
  bool _isHoverLeft = false;


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
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: _isHoverLeft ? 350 : 300,
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
                    SizedBox(height: base_Size),
                    Container(
                      height: 60,
                      width: 200,
                      decoration: BoxDecoration(
                        color: colors.tertiaryContainer,
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    SizedBox(height: base_Size),
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    SizedBox(height: base_Size),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
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
                  Center(child: Text('Timer Page', style: TextStyle(fontSize: 24))),
                  DownPage(),
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
              padding: EdgeInsets.all(10),
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
                          (_currentPage == 0) ? 24 : 16
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.timer_outlined,
                        color: (_currentPage == 0)
                            ? colors.onPrimaryContainer
                            : colors.onSurfaceVariant,
                        size: (_currentPage == 0) ? 30 : 30,
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
                  SizedBox(width: base_Size/2,),
                  Container(
                    width: 80,
                    decoration: BoxDecoration(
                      color: (_currentPage == 1)
                          ? colors.primaryContainer
                          : colors.surfaceVariant,
                      borderRadius: BorderRadius.circular(
                          (_currentPage == 1) ? 24 : 16
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.alarm,
                        color: (_currentPage == 1)
                            ? colors.onPrimaryContainer
                            : colors.onSurfaceVariant,
                        size: (_currentPage == 1) ? 30 : 30,
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
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}