import 'package:flutter/material.dart';
import 'package:layout/layout.dart';

class LayoutBar extends StatelessWidget {
  const LayoutBar({super.key});

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    return Theme(
      data: ThemeData.dark(),
      child: Material(
        child: SafeArea(
          minimum: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${layout.size}',
                  maxLines: 1,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Expanded(
                child: Text(
                  '${layout.breakpoint}',
                  maxLines: 1,
                  textAlign: TextAlign.end,
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
