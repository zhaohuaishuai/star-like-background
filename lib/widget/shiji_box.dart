import 'package:flutter/material.dart';
import '../container/sgbContainer.dart';
import 'package:get/get.dart';
import './imgage_loading.dart';
class ShiJiBox extends StatelessWidget {
  final String imagePath;
  final String title;
  final int id;

  ShiJiBox(
      {Key? key,
        required this.imagePath,
        required this.title,
        required this.id})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      height: 72,
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
          color: Color.fromARGB(255, 232, 232, 255),
          borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () {
            Get.find<SgbContainer>().updateActiveIndex(id);
            Get.toNamed('/playerTypeList');
          },
          child: Row(
            children: [
              ClipRRect(
                  child: Container(
                    width: 55,
                    height: 55,
                    child: Stack(
                      children: [
                        ImageLoading(imagePath: imagePath),
                        Center(
                          child: Image.asset(
                            "assets/images/playIcon.png",
                            width: 13,
                            height: 14,
                          ),
                        )
                      ],
                    ),
                  ),
                  borderRadius: BorderRadius.circular(10)),
              SizedBox(
                width: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 57, 77, 120)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
