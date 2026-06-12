import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './imgage_loading.dart';
import '../config/color.dart';
class GeDanBox extends StatelessWidget {
  final String? coverImg;
  final String title;
  final String content;
  final String id;
  final String ids;
  GeDanBox({
    Key? key,
    this.coverImg,
    required this.title,
    this.content = '暂无内容',
    required this.id,
    required this.ids
  }) : super(key: key);

  @override
  Widget build(BuildContext _) {
    // TODO: implement build
    return InkWell(
      onTap: (){
        if(ids != ''){
          Get.toNamed('/SongListPage',parameters: {"ids":ids,"title":title,"coverImg":coverImg??AppColor.defaultImag});
        } else {
          Get.snackbar('提示', "当前歌单没有相应曲目");
        }
      },
      child: Container(
          width: MediaQuery.of(_).size.width - 26,
          margin: EdgeInsets.only(bottom: 10),
          height: 148,
          decoration: BoxDecoration(
              color: Color.fromARGB(255, 232, 232, 255),
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment(0.3, 0),
                end: Alignment(1.1, 0),
                colors: [
                  Color.fromARGB(255, 232, 232, 255),
                  Color.fromARGB(1, 232, 232, 255),
                ],
              )),
          child: Padding(
            padding: EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800
                          ),
                        ),
                        SizedBox(height: 10,),
                        Text(
                          content,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 10
                          ),
                        ),
                      ],
                    )),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child:  SizedBox(
                      width: 112,
                      height: 112,
                      child: ImageLoading(imagePath:coverImg??'https://www.top237.top/lsky/2023/01/06/63b7bf356d8e4.jpg')
                      ),
                ),
              ],
            ),
          )),
    );
  }
}
