import 'dart:math';
import 'package:flutter/material.dart';

class DraggableResizableWindow extends StatefulWidget {
  final Widget child;

  const DraggableResizableWindow({
    super.key,
    required this.child,
  });

  @override
  State<DraggableResizableWindow> createState() => _DraggableResizableWindowState();
}

class _DraggableResizableWindowState extends State<DraggableResizableWindow> {
  Offset position = const Offset(100, 100);
  double width = 400;
  double height = 260;

  // 拖曳時記錄起始位置
  Offset _dragStart = Offset.zero;
  Offset _positionStart = Offset.zero;

  // 調整大小
  Offset _resizeStart = Offset.zero;
  double _widthStart = 0;
  double _heightStart = 0;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        // 透明層，點旁邊可以關閉
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(color: Colors.transparent),
          ),
        ),

        // 浮動視窗
        Positioned(
          left: position.dx,
          top: position.dy,
          child: Material(
            elevation: 12,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Column(
                children: [
                  // ⭐ 上方標題列：可拖曳
                  GestureDetector(
                    onPanStart: (details) {
                      _dragStart = details.globalPosition;
                      _positionStart = position;
                    },
                    onPanUpdate: (details) {
                      final delta = details.globalPosition - _dragStart;
                      setState(() {
                        position = Offset(
                          (_positionStart.dx + delta.dx)
                              .clamp(0, max(0.0, screenSize.width - width)),
                          (_positionStart.dy + delta.dy)
                              .clamp(0, max(0.0, screenSize.height - height)),
                        );
                      });
                    },
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '懸浮視窗',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ⭐ 中間自訂內容
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: widget.child,
                    ),
                  ),

                  // ⭐ 右下角拖曳點：改變大小
                  Align(
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onPanStart: (details) {
                        _resizeStart = details.globalPosition;
                        _widthStart = width;
                        _heightStart = height;
                      },
                      onPanUpdate: (details) {
                        final delta = details.globalPosition - _resizeStart;
                        setState(() {
                          width = (_widthStart + delta.dx).clamp(260, screenSize.width);
                          height = (_heightStart + delta.dy).clamp(180, screenSize.height);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.drag_handle,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
