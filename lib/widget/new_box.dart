import 'package:flutter/material.dart';
import '../config/color.dart';

class NewBox extends StatelessWidget {
  final Widget child;
  const NewBox({Key? key, required this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColor.appBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade500,
              blurRadius: 15,
              offset: const Offset(5, 5)),
          const BoxShadow(
              color: Colors.white, blurRadius: 15, offset: Offset(-5, -5)),
        ],
      ),
      child: child,
    );
  }
}
