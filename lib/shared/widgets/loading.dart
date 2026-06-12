import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/core/theme/theme_data.dart';

class LoadingWidget extends StatelessWidget {
  final double size;
  const LoadingWidget({super.key,this.size = 30});

  @override
  Widget build(BuildContext context) { 
    return  SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
                    color: context.isDarkMode
                        ? StarThemeData.loadingTextColor
                        : StarThemeData.primaryColor,
                  ),
    );
  }
}