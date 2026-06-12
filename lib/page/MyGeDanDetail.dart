import 'package:Shine_like_a_star/container/GeDan.dart';
import 'package:Shine_like_a_star/widget/StarScaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../storage/sgbStorage.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../type/sgbType.dart';
import '../widget/GeQuSelect.dart';
import '../widget/item_more_btn.dart';
// controller.submit(formKey:_formKey, title:title);
class MyGeDanDetail extends GetView<GeDanController> {
  MyGeDanDetail({Key? key}) : super(key: key);
  SgbStorage storage = SgbStorage();
  void selectGequ(){
    Get.to(() => GeQuSelect(
          onTap: (SgbData data, int index) {
              print('${data.title}');
              bool isSuccess = controller.addList(data.id);
              if(isSuccess){
                Get.snackbar('添加成功', data.full_title,
                    duration:
                    Duration(milliseconds: 700),
                    backgroundColor: Colors.white,
                    icon: Icon(Icons.star,
                        color: Colors.yellow));
              }


          },
        ),
        transition: Transition.downToUp);
  }

  @override
  Widget build(BuildContext context) {

    return StarScaffold(

        actions: [
          IconButton(onPressed: (){
            selectGequ ();
          }, icon: Icon(Icons.add)),
        ],
        child: Column(
          children: [
            SizedBox(height: 20,),
            Text(controller.currentSongData?.value.title ?? '',style: TextStyle(color: Colors.white),),
            Obx((){
              if(controller.historyList.value.length == 0){
                  return Container();
              }
              return Expanded(
                  child: Padding(
                    padding:  EdgeInsets.symmetric(vertical: 6),
                    child: ListView.builder(
                        padding: EdgeInsets.only(top: 0),
                        itemCount: controller.historyList.value.length,
                        itemBuilder:(builder,index){
                          var sgbData = controller.historyList.value[index];
                          return Slidable(
                            key:Key(sgbData.id.toString()),
                            child: ListTile(
                              onTap: (){
                                controller.sgbController.songLostToPlayerPage(false, sgbData, index, controller.historyList.value, () { });
                              },
                              title: Row(
                                mainAxisAlignment:MainAxisAlignment.start,
                                crossAxisAlignment:CrossAxisAlignment.center,
                                children: [
                                  Text(sgbData.xuhao.toString(),style: TextStyle(color:Colors.white38),),
                                  SizedBox(width: 10,),
                                  Expanded(
                                      child: Text(sgbData.title,style:TextStyle(color: Colors.white),softWrap: true)),
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
                                ],),
                            ),
                            endActionPane:  ActionPane(
                              motion: ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context){
                                    controller.deleteSgbData(sgbData.id);
                                  },
                                  backgroundColor: Color(0xFFFE4A49),
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: '删除',
                                )
                              ],
                            ),
                          );
                        }
                    ),
                  ));
            }),

            TextButton(onPressed: (){
              selectGequ();
            },child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Container()),
                Text("添加歌曲",style: TextStyle(color: Colors.white),),
                Icon(Icons.add,color: Colors.white,),
                Expanded(child: Container()),
            ],),),
            SizedBox(height: 30,),
          ],
        ));
  }
}
