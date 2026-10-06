import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HoverTracker extends StatefulWidget {
  SystemMouseCursor cursor;
  bool enabled;
  final Widget Function(bool isHovered) builder;

  HoverTracker({required this.builder, this.enabled = true,this.cursor = SystemMouseCursors.click});

  @override
  State<HoverTracker> createState() => _HoverTrackerState();
}

class _HoverTrackerState extends State<HoverTracker> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.builder(false);
    }
    return MouseRegion(
      cursor:widget.cursor,

      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: widget.builder(_isHovered),
    );
  }
}
