import 'package:flutter/foundation.dart';
import 'package:m/core/theme/theme_data.dart';
import 'package:m/core/utils/utils.dart';
import 'package:m/features/pages/metronome/index.dart';
import 'package:m/features/pages/metronome/metronome_view.dart';
import 'package:m/shared/widgets/empty.dart';
import 'package:m/shared/widgets/loading.dart';
import 'package:m/shared/widgets/mini_player.dart';
import 'package:path/path.dart' as path;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:m/core/utils/down_file.dart';
import 'package:photo_view/photo_view.dart';

// ignore: must_be_immutable
class PlayGePuWidget extends StatefulWidget {
  String? url;
  bool isShow;
  void Function(PhotoViewScaleState)? scaleStateChangedCallback;
  PlayGePuWidget(
      {super.key,
      this.url,
      this.scaleStateChangedCallback,
      required this.isShow});

  @override
  State<PlayGePuWidget> createState() => _PlayGePuWidgetState();
}

class _PlayGePuWidgetState extends State<PlayGePuWidget> {
  String savePath = '';

  bool playerShow = false;
  bool loading = true;


  @override
  void initState() {
    super.initState();
     
    initData();
  }

  @override
  void didUpdateWidget(PlayGePuWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    initData();
  }


  void initData() async {
      if (!widget.isShow) {
      return;
    }
    loading = true;
     savePath = await DownFile.downloadFile(widget.url!,showLoading: false,background: false);
    
     savePath = kIsWeb ? savePath : _loadImage(savePath); 

     loading = false;
      setState(() { });
  }

  

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    if (!widget.isShow) {
      return const SizedBox();
    }
    if(loading){
      return const LoadingWidget(size: 60,);
    }
    if (widget.url == null || widget.url!.isEmpty) {
      return Center(
        child: ClipOval(
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(

                color: context.isDarkMode? Colors.black.withOpacity(0.6):Colors.white.withOpacity(0.6)
            ),
            child: const EmptyWidget(
              size: 60,
              desc: '暂无歌谱',
            ),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: (){ 
        setState(() {
           playerShow = !playerShow;
        }); 
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRect(
            child:  PhotoViewGestureDetectorScope(
                    axis: Axis.vertical,
                    child: PhotoView(
                        tightMode: true,
                        basePosition: Alignment.center,
                        wantKeepAlive: true,
                        initialScale: PhotoViewComputedScale.contained,
                        scaleStateChangedCallback: widget.scaleStateChangedCallback,
                        imageProvider:
                            kIsWeb || savePath.startsWith('http') ? NetworkImage(savePath) : FileImage(File(savePath)),
                        backgroundDecoration: const BoxDecoration(color: Colors.transparent),
                        loadingBuilder: (context, event) =>const Center(child: LoadingWidget(size: 60,)) ,
                        
                        
                        ),
                        
                  ),
          ),
        
          AnimatedPositioned(
            duration: const Duration(milliseconds: 100),
            bottom: padding.bottom + StarThemeData.spacing + (playerShow? 0: -120),left:0,right:0,child:  MiniPlayer(),),

         const Positioned(top:0.0,left:0.0,right:0.0,child: MetronomeView(),),

          Positioned(
            top: 16,
            right:0,
            child: IconButton(
            icon:const Icon(
              IconUtil.metronome,
              size: 30,
              
            ),
            onPressed: () async {
             
              Get.to(const MetronomePage());
            },
          ),)
          
        ],
      ),
    );
  }

  // 加载并处理图片
  _loadImage(String savePath) {
    if (!context.isDarkMode) {
      return savePath;
    }
    if (kIsWeb) {
      return savePath;
    }
    // 将处理后的图片保存到本地
    String newPath =
        '${path.basenameWithoutExtension(savePath)}_inverted${path.extension(savePath)}';

    String newSavePath = path.join(path.dirname(savePath), newPath);
    // 如果已经存在反色的图片，则直接返回
    if (File(newSavePath).existsSync()) {
      return newSavePath;
    }
    // 这里假设从本地加载图片
    // 你可以根据需求修改为从网络或文件加载图片
    final file = File(savePath);
    Uint8List imageBytes = file.readAsBytesSync();
    File(newSavePath).writeAsBytesSync(Utils.invertColor(imageBytes));
    return newSavePath;
  }
}
