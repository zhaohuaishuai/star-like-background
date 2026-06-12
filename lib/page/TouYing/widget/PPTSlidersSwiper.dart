import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_3/flutter_swiper_3.dart';
import 'package:hexcolor/hexcolor.dart';
class PPTSlidersSwiper extends StatefulWidget {
  String lyric;
  int row;
  int pageIndex;
  String bgColor;
  int fontSize ;
  String fontColor;
  int titleFontSize;
  String title;
  int lineHeight;
  String textAlign;
  void Function(int index) onIndexChanged;
  PPTSlidersSwiper(
      {
        Key? key,
        required this.lyric,
        required this.row,
        required this.pageIndex,
        required this.onIndexChanged,
        required this.bgColor,
        required this.fontSize,
        required this.fontColor,
        required this.titleFontSize,
        required this.title,
        required this.lineHeight,
        required this.textAlign,

      }
      ) : super(key: key);

  @override
  _PPTSlidersSwiperState createState() {
    return _PPTSlidersSwiperState();
  }
}

class _PPTSlidersSwiperState extends State<PPTSlidersSwiper> {
  List<List<String>> sliders = [];
  SwiperController _swiperController = new SwiperController();
  @override
  void initState() {


  }

  @override
  void dispose() {
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    List<String> list = widget.lyric.split("\n");
    List<List<String>> sliders = splitArray<String>(list, widget.row);
    _swiperController.move(widget.pageIndex);
    sliders.insert(0, [widget.title]);
    sliders.insert(0, []);
    print("widget.pageIndex--->${widget.pageIndex}");
    TextAlign _textAlign = TextAlign.center;
    switch(widget.textAlign){
      case "left":
        _textAlign = TextAlign.left;
        break;
      case "right":
        _textAlign = TextAlign.right;
        break;
    }
    return
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 230,
          child: Swiper(
              itemBuilder: (_,int index){
                if(index == 1){
                  return Container(
                    child: Center(
                      child: Text(
                        sliders[index].join("\n"),
                        textAlign: _textAlign,
                        style: TextStyle(
                          fontSize: widget.titleFontSize.toDouble() /10,
                          fontWeight: FontWeight.w800,
                          color: HexColor(widget.fontColor),
                        ),
                      ),
                    ),
                    decoration: BoxDecoration(
                        color: HexColor(widget.bgColor)
                    ),
                  );
                }
                return
                  Container(
                    child: Center(
                      child: Text(
                        sliders[index].join("\n"),
                        textAlign: _textAlign,
                        style: TextStyle(
                          fontSize: widget.fontSize.toDouble() / 10,
                          fontWeight: FontWeight.w800,
                          color: HexColor(widget.fontColor),
                          height: widget.lineHeight / 100,
                        ),
                      ),
                    ),
                    decoration: BoxDecoration(
                        color: HexColor(widget.bgColor)
                    ),
                  );
              },
              itemCount: sliders.length,
              pagination:
              new SwiperPagination(
                  alignment: Alignment.topLeft,
                  builder: SwiperPagination.fraction
              ),
              control: new SwiperControl(
                  iconPrevious:Icons.skip_previous,
                  iconNext: Icons.skip_next,
                  color: HexColor("#F9F871"),
                  disableColor: HexColor("#AE0081")
              ),
              loop: false,
              controller: _swiperController,
              onIndexChanged:(int index){
                widget.onIndexChanged!(index);
              }
          ),
        ),
      );
  }

  List<List<T>> splitArray<T>(List<T> arr, int size) {
    List<List<T>> result = [];
    for (int i = 0; i < arr.length; i += size) {
      List<T> chunk = arr.sublist(i, i + size > arr.length ? arr.length : i + size);
      result.add(chunk);
    }
    return result;
  }

}

