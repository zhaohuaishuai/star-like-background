import 'package:Shine_like_a_star/container/GeDan.dart';
import 'package:Shine_like_a_star/widget/StarScaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../storage/sgbStorage.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../type/sgbType.dart';

class MyGeDan extends GetView<GeDanController> {
  MyGeDan({Key? key}) : super(key: key);
  SgbStorage storage = SgbStorage();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String title = '';

  void showAddModal(BuildContext context){
    showModalBottomSheet (context: context, builder: (builder) {
      return AnimatedPadding(
        duration: Duration.zero,
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          height: 220,
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Center(
                child:  Text("创建歌单",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
              ),
              Form(
                key:_formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                  TextFormField(
                    autofocus: true,
                    maxLength: 10,
                    validator: (value) {
                      if (value == '') {
                        return '请输入标题';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "请输入歌单名称",
                      label: Text("歌单名称"),
                    ),
                    onChanged: (val){
                      title = val.toString();
                    },
                  ),
                  TextButton(onPressed: (){
                    controller.submit(formKey:_formKey,title: title);
                  }, child: Text("提交"))
                ],),
              ),
            ],
          ),
        ),
      );
    },isScrollControlled: true);
  }

  @override
  Widget build(BuildContext context) {
    return StarScaffold(
        actions: [
          IconButton(onPressed: (){
            showAddModal ( context);
          }, icon: Icon(Icons.add))
        ],
        child: Column(
          children: [
            SizedBox(height: 50,),
            Obx((){
              if(controller.songList.value.length == 0){
                return Container();
              }
              return Expanded(
                  child: Builder(builder: (builder){
                    return Padding(
                      padding:  EdgeInsets.only(left:10.0,right:0.0),
                      child: ListView.builder(
                          padding: EdgeInsets.only(top: 0),
                          itemCount: controller.songList.value.length,
                          itemBuilder:(builder,index){
                            var data = controller.songList.value[index];
                            return Slidable(
                              key:Key(data.id.toString()),
                              child: ListTile(
                                onTap: (){
                                  controller.currentSongId.value =  data.id as String;
                                  Get.toNamed(RouteName.MyGeDanDetail.value);
                                },
                                subtitle: Text(data.createdAt.toString(),style: TextStyle(color: Colors.white70),),
                                title: Row(
                                  children: [
                                    Text(data.title.toString(),style:TextStyle(color: Colors.white),softWrap: true),
                                    Expanded(child: Container()),
                                    IconButton(onPressed: (){}, icon: Icon(Icons.chevron_right,size:26),color: Colors.white,)

                                  ],
                                ),
                              ),
                              endActionPane:  ActionPane(
                                motion: ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (context){
                                      controller.deleteSongList(data,index);
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
                    );
                  }));

            }),

            TextButton(onPressed: (){
              showAddModal(context);
            },child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Container()),
                Text("创建歌单",style: TextStyle(color: Colors.white),),
                Icon(Icons.add,color: Colors.white,),
                Expanded(child: Container()),
            ],),),
            SizedBox(height: 30,),
          ],
        ));
  }
}
