import 'package:Shine_like_a_star/widget/item_more_btn.dart';
import 'package:Shine_like_a_star/type/sgbType.dart';
import 'package:Shine_like_a_star/widget/StarScaffold.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:Shine_like_a_star/container/sgbContainer.dart';

class SgbAppPage extends GetView<SgbContainer> {
  int activeTabIndex = 0;
  int oldTabIndex = 0;
  bool isUpdateHistoryList = false;



  @override
  Widget build(BuildContext context) {
     return Obx((){
      var type = Get.parameters['type'];
      List<SgbDb> list = controller.sgbdb.value.where((element) => element.type == type).toList();
       return DefaultTabController(
         length: list.length,
         child: StarScaffold(
             actions: [
               IconButton(onPressed: (){
                 Get.toNamed(RouteName.SearchPage.value);
               }, icon: Icon(Icons.search))
             ],
             child: Builder(
               builder: (context) {
                 if(list.length == 0){
                   return Center(
                     child: CircularProgressIndicator(color:Colors.white),
                   );
                 }
                 return Column(
                   children: [
                     SizedBox(height: 48,),
                     Container(
                         padding: EdgeInsets.only(left: 10,right: 10),
                         child: TabBar(
                           indicator: UnderlineTabIndicator(
                             borderSide: BorderSide(color: Colors.white38, width: 2.0),
                           ),
                           isScrollable: true,
                           tabs: list.map((item)=>Text('${item.name}(${item.list?.length})')).toList(),
                           onTap: (_activeIndex){
                             if(activeTabIndex == _activeIndex){
                               isUpdateHistoryList = true;
                             }
                             oldTabIndex = activeTabIndex;
                             activeTabIndex = _activeIndex;
                             isUpdateHistoryList = false;
                           },
                         )),
                     Expanded(
                         child:  TabBarView(
                           children: list.map((e) {
                             return ListView.builder(
                               padding: EdgeInsets.zero,
                               itemCount: e.list?.length,
                               itemBuilder: (BuildContext context, int index) {
                                 List<SgbData>? sgbDataList = e.list;
                                 SgbData sgbData = sgbDataList![index];
                                 return ListTile(
                                   onTap: (){
                                     if(!sgbData.dmturl.isad){
                                       return;
                                     }
                                     controller.songLostToPlayerPage(isUpdateHistoryList, sgbData, index, e.list??[], () { });
                                   },
                                   title: StreamBuilder<int?>(
                                     stream: controller.player.value.currentIndexStream,
                                     builder: (context, snapshot) {
                                       return Row(
                                           mainAxisAlignment:MainAxisAlignment.start,
                                           crossAxisAlignment:CrossAxisAlignment.center,
                                         children: [
                                           Text(sgbData.xuhao.toString(),style: TextStyle(color:Colors.white38),),
                                           SizedBox(width: 10,),
                                           Expanded(
                                               child: Text(sgbData.title,style:TextStyle(color: Colors.white),softWrap: true)),
                                           SizedBox(width: 10,),
                                           StreamBuilder<bool>(
                                               stream: controller.player.value.playingStream,
                                               builder: (context, playingsnapshot){
                                                 bool playing = playingsnapshot.data ?? false;
                                                 if(snapshot.data == index && playing){
                                                   String cid = controller.player.value.sequenceState!.currentSource!.tag.id.toString();
                                                   if(sgbData.id == cid){
                                                     return Text('正在播放',style: TextStyle(color: Colors.white38,fontSize: 12));
                                                   }
                                                   return Container();
                                                 }
                                                 return Container();
                                               }
                                           ),
                                           SizedBox(width: 10,),
                                           Builder(builder: (con){
                                              if(!sgbData.dmturl.isad){
                                                return Text("暂无音频",style: TextStyle(color: Colors.white38,fontSize: 12), );
                                              }
                                              return Container();
                                           }),
                                           SizedBox(width: 10,),
                                           Text(sgbData.years,style: TextStyle(color: Colors.white38,fontSize: 12), ),
                                           SizedBox(width: 10,),
                                           ItemMoreBtn(sgbData: sgbData)
                                         ],);
                                     }
                                   ),
                                 );
                               },
                             );
                           }).toList()
                         ))
                   ],
                 );
               }
             )),
       );
      });
     }
  }




