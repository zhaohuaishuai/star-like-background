import 'package:flutter/material.dart';
import '../type/sgbType.dart';
import '../widget/player_v3_page_wigdet.dart';
import 'package:just_audio/just_audio.dart';
import '../container/sgbContainer.dart';
import 'package:get/get.dart';




class SharePlayer extends StatefulWidget {
  SharePlayer({Key? key}) : super(key: key);
  @override
  _SharePlayerState createState() {
    return _SharePlayerState();
  }
}


class _SharePlayerState extends State<SharePlayer> {
  final AudioPlayer player = Get.find<SgbContainer>().player.value;
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
    return Obx(() {
      List<SgbData> sgb = Get.find<SgbContainer>().sgb.value;
      if (sgb.length == 0) {
        return Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        );
      }
      var ids = Get.parameters['ids'];
 
      if (ids != null) {
       
        var list = ids.split(",").toList().map((id) {
          return sgb.firstWhere((element) => element.id == id);
        }).toList();

        Future<bool> update() async {
          await Get.find<SgbContainer>().updatePlayList(list);
          player.seek(Duration.zero, index: 0);
          return true;
        }

        return FutureBuilder(
            future: update(),
            builder: (BuildContext build, AsyncSnapshot snapshot) {
              if (snapshot.hasError) {
                return Container();
              }
              print("snapshot.data-->${snapshot.data}");
              if (snapshot.data != null) {
                return PlayerPage(
                  player: player,
                  backBtnType: BackBtnType.home,
                );
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            });
      } else {
        return PlayerPage(player: player);
      }
    });
  }
}
