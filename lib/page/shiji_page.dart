import 'package:Shine_like_a_star/container/sgbContainer.dart';
import 'package:flutter/material.dart';
import '../config/color.dart';
import 'package:get/get.dart';
import '../widget/shiji_box.dart';
import '../widget/loading.dart';
import '../widget/title_header.dart';
import '../type/sgbType.dart';
class ShiJiPage extends StatefulWidget {
  ShiJiPage({Key? key}) : super(key: key);

  @override
  _ShiJiPageState createState() {
    return _ShiJiPageState();
  }
}

class _ShiJiPageState extends State<ShiJiPage> {
  SgbContainer sgbContainer = Get.find<SgbContainer>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        body: SafeArea(
      child: Container(
        decoration: BoxDecoration(gradient: AppColor.appBackgroundGradient),
        child: Column(
          children: [
            Container(
              child: Row(
                children: [
                  BackButton(
                    color:Colors.white,
                    onPressed: (){
                      Get.toNamed(RouteName.firstPage.value);
                  },)
                ],
              ),
            ),
            SizedBox(height: 10,),
            TitleHeader(title: '诗集列表',icon: Icons.add_business,lookMore:false),
            Expanded(
              child: Obx(
                () {
                  if (sgbContainer.sgbdb.value.length == 0) {
                    return Loading();
                  }
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                              itemCount: sgbContainer.sgbdb.value.length,
                              itemBuilder: (_, i) {
                                var item = sgbContainer.sgbdb.value[i];
                                return ShiJiBox(
                                    imagePath: item.thumbnails ?? '',
                                    title: item.name ?? '',
                                    id: item.id as int);
                              }),
                        ),

                      ],
                    ),
                  );
                },
              ),
            ),

          ],
        ),
      ),
    ));
  }
}
