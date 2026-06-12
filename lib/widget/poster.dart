import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_path_provider/android_path_provider.dart';
class PosterContainer extends StatefulWidget {
  final String title;
  final String lyric;
  final PosterStyle posterStyle;
  final String qrCodeUrl;
  const PosterContainer({
    super.key,
    required this.title,
    required this.lyric,
    required this.posterStyle,
    required this.qrCodeUrl});
  @override
  State<PosterContainer> createState() => _PosterContainer();
}

class _PosterContainer extends State<PosterContainer> {
  double canvasHeight = 300;
  ui.Image? image ;
  late ui.Image qrImage;
  late GlobalKey _repaintBoundaryKey = GlobalKey();
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedFile;
  @override
  void initState() {
    initImage();
  }

  void initImage() async {
    ui.Image cimage = await getImage("assets/images/wl.png");
    ui.Image cqrImage = await loadImage(widget.qrCodeUrl, true);
    setState(() {
      image =cimage;
      qrImage = cqrImage;
    });
  }

  Future<void> _capturePng() async {
    try {
      RenderRepaintBoundary boundary =
      _repaintBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();
      var status = await Permission.storage.status;
      if(!status.isGranted){
         await Permission.storage.request();
      }
      String downloadsPath =  await AndroidPathProvider.downloadsPath;
      final path = '$downloadsPath/${getCurrentTimestampInSeconds()}_star_share_image.png';
      final file = File(path);
      await file.writeAsBytes(pngBytes);
      print('Image saved to $path');
    } catch (e) {
      print(e);
    }
  }

  Future<void> _pickImage(BuildContext context) async {
    // 打开相册选择图片
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _pickedFile = image;
    });
    _cropImage();
  }

  Future<void> _cropImage() async {
    if (_pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _pickedFile!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Cropper',
          ),
        ],
      );
      if (croppedFile != null) {
        ui.Image ccmage = await loadImageFromFile(croppedFile.path);
        print("剪切后的图片" );
        print(ccmage.width.toString() + "x" + ccmage.height.toString());
        setState(() {
          image = ccmage;
          _repaintBoundaryKey = GlobalKey();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("海报制作"),
        actions: [
          IconButton(onPressed: (){
            _capturePng().then((value)  {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("图片已保存到相册"),
                  duration: Duration(seconds: 2), // Duration of the SnackBar
                ),
              );
            });

          }, icon: Icon(Icons.share))
        ],
      ),
      body: Scrollbar(
        child:SingleChildScrollView(
          child:  Column(
            children: [
              Builder(
                builder: (context) {
                  if(image ==null){
                    return Container();
                  }
                  return Stack(
                    children: [
                      RepaintBoundary(
                        key:_repaintBoundaryKey,
                        child: CustomPaint(
                          size: Size(MediaQuery.of(context).size.width,canvasHeight),
                          painter: PosterPainter(
                              image as ui.Image,
                              widget.lyric,
                              widget.posterStyle,
                              (Offset offset){
                                setState(() {
                                  canvasHeight = offset.dy;
                                });
                              },
                            widget.title,
                            qrImage
                          ),
                        ),
                      ),
                      Positioned(
                        right: widget.posterStyle.padding.right + 20,
                        top: widget.posterStyle.padding.top + 20,
                        child: InkWell(
                          child: Container(
                            width:60,height:60,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child:Center(child: Image.asset("assets/images/相机.png",width: 40,),),
                          ),
                          onTap: (){
                            _pickImage(context);
                          },
                      )),
                    ],
                  );
                }
              )
            ],
          ),
        )
      ),
    );
  }
}

class PosterPainter extends  CustomPainter  {
  ui.Image image;
  String lyric;
  void Function(Offset offset) layout;
  PosterStyle style;
  String title;
  ui.Image qrImage;
  PosterPainter(this.image,this.lyric,this.style,this.layout,this.title,this.qrImage);
  @override
  void paint(Canvas canvas, Size size) {
    print('paint');
    var rect = Offset.zero & size;
    //画图片
    Offset offset = drawImage(canvas,rect,image,style);
    //画文字
    Offset textOffset = drawText(canvas,rect,offset,lyric,style);
    // 画标题
    Offset titleOffset = drawTitle(canvas,rect,textOffset,title,style);
    //画底部
    Offset bottomOffset = drawBottom(canvas,rect,qrImage,style,titleOffset);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      layout(bottomOffset);
    });
    print("文字画好后的高度：$textOffset");

  }
  // 返回false, 后面介绍
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}


// 画图像
Offset drawImage(Canvas canvas, Rect rect,ui.Image image,PosterStyle style)  {
  var paint = Paint()
    ..style = PaintingStyle.fill //填充
    ..color = Colors.white;
  canvas.drawRect(rect, paint);
  final double pl = style.padding.left ;
  final double pt = style.padding.top ;
  final double pr = style.padding.right ;
  final double pb = style.padding.bottom ;
  final srcRect = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
  final dstRect = Rect.fromLTWH(pl, pt, rect.width - pt*2, rect.width - pt*2);
  canvas.drawImageRect(image, srcRect,dstRect, paint);
  return Offset(0, rect.width - 20);
}


Offset drawText(Canvas canvas, Rect rect,Offset offset,String text,PosterStyle style){

  final double pl = style.padding.left ;
  final double pt = style.padding.top ;
  final double pr = style.padding.right ;
  final double pb = style.padding.bottom ;
   final textSpan = TextSpan(
     text:text,
     style: TextStyle(
       color: style.color,
       fontSize:style.fontSize,
     )
   );

   final textPinter = TextPainter(
     text:textSpan,
     textAlign: TextAlign.left,
     textDirection: TextDirection.ltr,
   );
  textPinter.layout(minWidth: rect.width - (pl+ pr),maxWidth: rect.width - (pl+ pr));
  final coffset = Offset(pl,offset.dy + pt);
  textPinter.paint(canvas,coffset);
  return Offset(0,textPinter.height + coffset.dy + pb);
}

Offset drawTitle(Canvas canvas, Rect rect,Offset offset,String text,PosterStyle style){
  final double pl = style.padding.left ;
  final double pt = style.padding.top ;
  final double pr = style.padding.right ;
  final double pb = style.padding.bottom ;
  final textSpan = TextSpan(
      text:text,
      style: TextStyle(
        color: style.color,
        fontSize:style.fontSize,
      )
  );

  final textPinter = TextPainter(
    text:textSpan,
    textAlign: TextAlign.left,
    textDirection: TextDirection.ltr,
  );
  textPinter.layout(minWidth: rect.width - 265 - pr,maxWidth: rect.width - 265 - pr);
  final coffset = Offset(265,offset.dy + 10);
  textPinter.paint(canvas,coffset);
  final paint = Paint()
    ..color = Colors.black38
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 0.8;

  double dy = coffset.dy  + (style.fontSize/2 + 5);
  // 绘制一条直线
  canvas.drawLine(
    Offset(180, dy), // 起点
    Offset(260, dy), // 终点
    paint, // 画笔
  );

  return Offset(0,textPinter.height + coffset.dy );
}


Offset drawBottom(Canvas canvas, Rect rect,ui.Image image,PosterStyle style,Offset offset){
  var paint = Paint();
  final double pl = style.padding.left ;
  final double pt = style.padding.top ;
  final double pr = style.padding.right ;
  final double pb = style.padding.bottom ;
  double qrCodeSize = 80;
  // 绘制二维码
  final srcRect = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
  final dstRect = Rect.fromLTWH(pl,offset.dy + pt, qrCodeSize, qrCodeSize);
  canvas.drawImageRect(image, srcRect,dstRect, paint);
  // 绘制文案
  final textSpan = TextSpan(
    text: "长按识别二维码播放\nhttps://star.top237.top",
    style: TextStyle(
      color: style.color,
      fontSize: style.fontSize - 5,
    )
  );

  final textPainter =  TextPainter(
    text: textSpan,
    textAlign: TextAlign.left,
    textDirection: TextDirection.ltr,
  );

  textPainter.layout(maxWidth: 200);

  textPainter.paint(canvas, Offset(
    pl + qrCodeSize + 2,
    offset.dy + qrCodeSize/2
  ));

  return Offset(0, offset.dy + pt + 80 + pb);
}

Future<ui.Image> getImage(String asset) async {
  ByteData data = await rootBundle.load(asset);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
  ui.FrameInfo fi = await codec.getNextFrame();
  return fi.image;
}

Future<ui.Image> loadImageFromFile(String filePath) async {
  // 读取文件字节数据
  final file = File(filePath);
  final byteData = await file.readAsBytes();

  // 解码字节数据
  final codec = await ui.instantiateImageCodec(byteData);
  final frame = await codec.getNextFrame();
  return frame.image;
}
Future<ui.Image> loadImage(var path, bool isUrl) async {
    ImageStream stream;
    if (isUrl) {
    stream = NetworkImage( "https://star.top237.top/ry-api/start/qrcode?msg=$path").resolve(ImageConfiguration.empty);
    } else {
    stream = AssetImage(path, bundle: rootBundle)
        .resolve(ImageConfiguration.empty);
    }
    Completer<ui.Image> completer = Completer<ui.Image>();
    void listener(ImageInfo frame, bool synchronousCall) {
    final ui.Image image = frame.image;
    completer.complete(image);
    stream.removeListener(ImageStreamListener(listener));
}

stream.addListener(ImageStreamListener(listener));
return completer.future;
}


class PosterStyle {
  final EdgeInsets padding;
  double fontSize ;
  Color color;

  PosterStyle(
    this.padding,
    this.fontSize, this.color,
  );
}

int getCurrentTimestampInSeconds() {
  return DateTime.now().millisecondsSinceEpoch ~/ 1000;
}
