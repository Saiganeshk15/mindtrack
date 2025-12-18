import 'package:flutter/material.dart';

class PageContainer extends StatelessWidget {
  final Widget child;

  const PageContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: child,
      ),
    );
  }
}
