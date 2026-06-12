import 'package:flutter/material.dart';
import 'package:m/core/theme/theme_data.dart';
import 'package:m/core/utils/utils.dart';

class EmptyWidget extends StatelessWidget {
  final Widget? child;
  final double? size;
  final String? desc;
  const EmptyWidget({super.key, this.child, this.size, this.desc});

  @override
  Widget build(BuildContext context) {
    Widget descWidget = Container();
    if (child != null) {
      descWidget = child!;
    } else if (desc != null) {
      descWidget = Text(desc!,
          style: const TextStyle(
            fontSize: 12,
          ),
          textAlign: TextAlign.center);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Icon(
            fill: 1,
            IconUtil.empty,
            size: size ?? 120,
            color: StarThemeData.primaryColor.withOpacity(0.5),
          ),
        ),
        SizedBox(height: StarThemeData.spacing),
        descWidget,
      ],
    );
  }
}
