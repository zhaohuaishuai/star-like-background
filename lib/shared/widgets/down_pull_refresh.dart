import 'package:flutter/material.dart';
import 'package:m/core/theme/theme_data.dart';

class DownPullRefresn extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  const DownPullRefresn({super.key, required this.child, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        color: StarThemeData.primaryColor, onRefresh: onRefresh, child: child);
  }
}
