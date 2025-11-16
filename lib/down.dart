import 'package:flutter/material.dart';
import 'util.dart';
import 'theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:async/async.dart';
import 'dart:async';
import 'countdown_widget.dart';

class DownPage extends StatefulWidget{
  const DownPage({super.key});

  @override
  State<DownPage> createState() => _DownPageState();
}

class _DownPageState extends State<DownPage>{

  List<int> pickTime = [0, 0, 0];
  int pickedIndex = 0;

  @override
  Widget build(BuildContext context){
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme colors = theme.colorScheme;
    final w = MediaQuery.of(context).size.width;

    Widget timePicker({
      required double size,
      required bool picked,
      required Color background,
      required TextStyle textStyle,
      required String text,
      required double borderRadius,
      required void Function(bool isUp) onTapHalf,
    }) {
      return GestureDetector(
        onTapDown: (details) {
          double half = size / 2;
          bool isUp = details.localPosition.dy < half;
          onTapHalf(isUp);
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          width: picked? size * 1.2 : size * 1,
          height: size,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          ),
          child: Center(
            child: Text(
              text,
              style: textStyle,
            ),
          ),
        ),
      );
    }


    return Scaffold(
      body: Center(
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TimePickerBox(
                  size: w * 0.12,
                  borderRadius: (pickedIndex==0)? 24 : 40,
                  picked: (pickedIndex==0)? true : false,
                  background: (pickedIndex==0)? colors.secondaryContainer : colors.surface,
                  textStyle: GoogleFonts.robotoMono(
                    fontSize: textTheme.displayLarge?.fontSize ?? 48,
                  ),
                  text: pickTime[0].toString().padLeft(2, '0'),
                  onTapHalf: (isUp) {
                    if(pickedIndex == 0){
                      if (isUp) {
                        if (pickTime[0] < 99) pickTime[0]++;
                      } else {
                        if (pickTime[0] > 0) pickTime[0]--;
                      }
                    }else{
                      pickedIndex = 0;
                    }
                    setState(() {});
                  },
                ),

                SizedBox(width: w * 0.01),
                TimePickerBox(
                  size: w * 0.12,
                  borderRadius: (pickedIndex==1)? 24 : 40,
                  picked: (pickedIndex==1)? true : false,
                  background: (pickedIndex==1)? colors.secondaryContainer : colors.surface,
                  textStyle: GoogleFonts.robotoMono(
                    fontSize: textTheme.displayLarge?.fontSize ?? 48,
                  ),
                  text: pickTime[1].toString().padLeft(2, '0'),
                  onTapHalf: (isUp) {
                    if(pickedIndex == 1){
                      if (isUp) {
                        if (pickTime[1] < 59) pickTime[1]++;
                      } else {
                        if (pickTime[1] > 0) pickTime[1]--;
                      }
                    }else{
                      pickedIndex = 1;
                    }
                    setState(() {});
                  },
                ),

                SizedBox(width: w * 0.01),
                TimePickerBox(
                  size: w * 0.12,
                  borderRadius: (pickedIndex==2)? 24 : 40,
                  picked: (pickedIndex==2)? true : false,
                  background: (pickedIndex==2)? colors.secondaryContainer : colors.surface,
                  textStyle: GoogleFonts.robotoMono(
                    fontSize: textTheme.displayLarge?.fontSize ?? 48,
                  ),
                  text: pickTime[2].toString().padLeft(2, '0'),
                  onTapHalf: (isUp) {
                    if(pickedIndex == 2){
                      if (isUp) {
                        if (pickTime[2] < 59) pickTime[2]++;
                      } else {
                        if (pickTime[2] > 0) pickTime[2]--;
                      }
                    }else{
                      pickedIndex = 2;
                    }
                    setState(() {});
                  },
                ),

              ],
            ),
            SizedBox(height: 30,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: IconButton(
                    icon: Icon(
                        Icons.refresh,
                        color: colors.outline,
                        size: 32
                    ),
                    onPressed: () {
                      pickTime = [0, 0, 0];
                      pickedIndex = 3;
                      setState(() {});
                    },
                  ),
                ),
                SizedBox(width: 10,),
                Container(
                  decoration: BoxDecoration(
                    color: colors.tertiaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    icon: Icon(
                        Icons.play_arrow,
                        color: colors.onTertiaryContainer,
                        size: 32
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierColor: Colors.black26,     // 背景半透明
                        barrierDismissible: true,
                        builder: (_) => const DraggableResizableWindow(
                          child: Center(
                            child: Text('這裡是自訂內容'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
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