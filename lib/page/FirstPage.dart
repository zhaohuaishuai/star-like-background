import 'package:Shine_like_a_star/type/sgbType.dart';
import 'package:Shine_like_a_star/widget/StarScaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../container/First.dart';
import 'package:carousel_slider/carousel_slider.dart';
import './index.dart';
import 'package:Shine_like_a_star/container/sgbContainer.dart';
import '../widget/PlayerBottomBar.dart';
class FirstPage extends GetView<First> {
  FirstPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StarScaffold(
        leading: Text(""),
        actions: [
          UnconstrainedBox(
            alignment:Alignment.topCenter,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
              ),
              child: Obx((){
                if(controller.notices.value.length == 0){
                  return Container();
                }
                return CarouselSlider.builder(
                  itemCount: controller.notices.value.length,
                  options: CarouselOptions(
                    autoPlay: true,
                    scrollDirection: Axis.vertical,
                  ),

                  itemBuilder: (content, index, realIndex) {
                    {
                      return Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 10,
                        ),
                        child: InkWell(
                          onTap: (){
                            print("点击item:${index}");
                            Get.toNamed(RouteName.TichTextPage.value,parameters: {
                              'id':controller.notices.value[index].noticeId.toString()
                            });
                          },
                          child: Container(
                              alignment: Alignment.centerLeft,
                              child: new Text(
                                "${controller.notices.value[index].noticeTitle}",
                                style: TextStyle(color: Colors.white70,fontSize: 14),
                              )),
                        ),
                      );
                    }
                  },
                );
              }),
            ),
          ),
        ],
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: 42,),
                Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  margin: EdgeInsets.only(top: 10),
                  child: InkWell(
                    onTap: () {
                      Get.toNamed(RouteName.SearchPage.value);
                    },
                    child: Row(children: [
                      Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.1),
                              borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(20),
                              ),
                            ),
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(left: 20),
                            child:
                            Text("搜索歌曲", style: TextStyle(color: Colors.white54)),
                          )),
                      Container(
                          width: 40,
                          height: 40,
                          child: IconButton(
                            icon: Icon(
                              Icons.search,
                              color: Colors.white54,
                            ),
                            onPressed: () {
                              Get.toNamed("/search");
                            },
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.1),
                            borderRadius: BorderRadius.horizontal(
                              right: Radius.circular(20),
                            ),
                          )),
                    ]),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                ),
                Expanded(
                  child: GridView.count(
                    padding: EdgeInsets.only(top:0,),
                    crossAxisCount: 2,
                    childAspectRatio:1.4,
                    children: [
                      Center(
                        child: NavContainer(
                          icon: Icons.castle,
                          title: "诗歌本",
                          route: RouteName.SgbAppPage.value,
                          parameters: {"type":"sgb_type"},
                        ),
                      ),
                      Center(
                        child: NavContainer(
                          icon: Icons.accessibility_sharp,
                          title: "原创赞美",
                          route: RouteName.OriginalPoetryPage.value,
                          parameters: {"type":"original_type"},
                        ),
                      ),
                      Center(
                        child: NavContainer(
                          icon: Icons.library_music,
                          title: "我的歌单",
                          // route: RouteName.SongListPage.value,
                          route: RouteName.MyGeDan.value,
                        ),
                      ),
                      Center(
                        child: NavContainer(
                          icon: Icons.tune,
                          title: "吉他调音器",
                          route: RouteName.GuitarTuning.value,
                        ),
                      ),
                      Center(
                        child: NavContainer(
                          icon: Icons.book_outlined,
                          title: "经文查询",
                          route: RouteName.BiblePage.value,
                        ),
                      ),
                    ],
                  ),),
                Container(
                  margin: EdgeInsets.only(top: 20),
                ),
              ],
            ),
            Positioned(child: Row(
              children: [
                AppVersionBtn(sgbContainer: Get.find<SgbContainer>(),),
              ],
            ),right: 1,bottom: 130,),
            Positioned(child: PlayerBottomBarr(),left: 0,right:0,bottom: 40,),
          ],
        ));
  }
}

class NavContainer extends StatelessWidget {
  final String title;
  final String route;
  final IconData icon;
   Map<String,String>? parameters;
   NavContainer({
    Key? key,
    required this.title,
    required this.route,
    required this.icon,
    this.parameters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.toNamed(route,parameters: this.parameters);
      },
      child: Container(
        height: 120,
        width: 120,
        margin: EdgeInsets.only(top: 0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0),
          borderRadius: BorderRadius.circular(80),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(
            icon,
            color: Colors.white,
            size: 60,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ]),
      ),
    );
  }
}



class InfiniteOpacity extends StatefulWidget {
  Widget child;
  Duration duration;
  InfiniteOpacity({
    required this.child,
    required this.duration
});
  @override
  _InfiniteOpacityState createState() => _InfiniteOpacityState();
}

class _InfiniteOpacityState extends State<InfiniteOpacity> with SingleTickerProviderStateMixin {
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    Future(() async {
      while (true) {  // 无限循环
        await Future.delayed(widget.duration);  // 暂停一秒
        setState(() {
          _visible = !_visible;  // 切换可见状态
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: Duration(milliseconds: 500),
      child: widget.child
    );
  }
}

