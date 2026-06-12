
import 'package:flutter/cupertino.dart';
import '../type/sgbType.dart';
import '../widget/search_page.dart';

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
