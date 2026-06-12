import 'package:flutter/material.dart';
import './search.dart';
import 'package:get/get.dart';
import '../type/sgbType.dart';
import './search_page.dart';
class SgbSelect extends StatefulWidget {
  ValueChanged<SgbData>? onTap;
  SgbSelect({Key? key,this.onTap}) : super(key: key);
  @override
  SgbSelectState createState() {
    return SgbSelectState();
  }
}

class SgbSelectState extends State<SgbSelect> {
  FocusNode focusNode = new FocusNode();
  late OverlayEntry overlayEntry;
  LayerLink layerLink = new LayerLink();
  GlobalKey<SearchBarWidgetState> globalKey = new GlobalKey();
  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    super.dispose();
  }

  setText(String text){
    globalKey.currentState!.setText(text);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return InkWell(
      onTap: (){
        Get.to(
            () => GeQuSelect(
              onTap: (SgbData data, int index) {
                if(widget.onTap!=null){
                  setText(data.full_title);
                  widget.onTap!(data);
                }
                Get.back(result: data);
              },
            ),
            transition: Transition.downToUp);
      },
      child: SearchBarWidget(
        key:globalKey,
        enabled: false,
      ),
    );
  }
}
class GeQuSelect extends StatefulWidget {
  final onTap;
  GeQuSelect({Key? key, this.onTap}) : super(key: key);
  @override
  _GeQuSelectState createState() {
    return _GeQuSelectState();
  }
}

class _GeQuSelectState extends State<GeQuSelect> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  onTap(SgbData data, int index) {
    if (widget.onTap != null) {
      widget.onTap(data, index);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SearchPage(
      showHistory: false,
      showBackBtn: true,
      onTap: onTap,
    );
  }
}

