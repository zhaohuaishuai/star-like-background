import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchTextField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool autofocus;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool clean;

  const SearchTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.readOnly = false,
    this.onTap,
    this.clean = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: TextField(
        onTap: onTap,
        style: const TextStyle(
          fontSize: 12,
        ),
        controller: controller,
        autofocus: autofocus,
        focusNode: focusNode,
        readOnly: readOnly,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: '请输入要搜索的内容'.tr,
          contentPadding: const EdgeInsets.symmetric(horizontal: 0),
          suffixIcon: clean && controller!.value.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller?.clear();
                  },
                )
              : null,
        ),
      ),
    );
  }
}
