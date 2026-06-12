import 'package:Shine_like_a_star/container/sgbContainer.dart';
import 'package:Shine_like_a_star/type/sgbType.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../widget/search_page.dart';
import '../storage/sgbStorage.dart';
import '../utils/utils.dart';
import 'package:matomo_tracker/matomo_tracker.dart';

class GeDanEdit extends StatefulWidget {
  GeDanEdit({Key? key}) : super(key: key);
  @override
  _GeDanEditState createState() {
    return _GeDanEditState();
  }
}

class _GeDanEditState extends State<GeDanEdit> with TraceableClientMixin {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String id = '';
  String title = '';
  String userId = '';
  get ids {
    return _selectList
        .map((e) {
          return e.id;
        })
        .toList()
        .join(",");
  }

  String content = '';
  String coverImg = '';
  bool isPut = true;
  String createdAt = '';
  String updatedAt = '';
  bool isUrl = true;
  List<SgbData> _selectList = [];
  final SgbStorage sgbStorage = SgbStorage();
  final SgbContainer sgbContainer = Get.find<SgbContainer>();
  get gequs {
    return _selectList
        .map((e) {
          return e.full_title;
        })
        .toList()
        .join(",");
  }

  bool isEdit = false;
  // TODO: implement traceName
  String get traceName => '${Get.parameters['id'] == null ? "增加歌单" : "编辑歌单"}';

  @override
  // TODO: implement traceTitle
  String get traceTitle => '${Get.parameters['id'] == null ? "增加歌单" : "编辑歌单"}';
  @override
  void initState() {
    super.initState();
    var nId = Get.parameters['id'];
    if (nId == null) {
      var uuid = Uuid();
      id = uuid.v4();
      isEdit = false;
    } else {
      isEdit = true;
      id = nId;
      var data = sgbStorage.getSongData(id);
      title = data.title as String;
      userId = data.userId as String;
      content = data.content as String;
      isPut = data.isPut as bool;
      createdAt = data.createdAt as String;
      coverImg = data.coverImg as String;
      try {
        _selectList = data.ids!.split(',').map((id) {
          return sgbContainer.sgb.value
              .firstWhere((SgbData element) => element.id == id);
        }).toList();
      } catch (err) {
        print(err);
      }
    }

    print("接收到的${Get.parameters['id']}");
  }

  @override
  void dispose() {
    super.dispose();
  }

  submit() async {
    if (_formKey.currentState!.validate()) {
      var userId = await Jutils.deviceDetails();
      var data = SongListData(
        id: id,
        ids: ids,
        title: title,
        content: content,
        coverImg: coverImg,
        isPut: false,
        createdAt: isEdit ? createdAt : DateTime.now().toString(),
        updatedAt: DateTime.now().toString(),
        userId: userId,
      );
      sgbStorage.addSongList(data);

      Get.back();
    }
    ;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
            // gradient: AppColor.appBackgroundGradient
            ),
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.all(8.0),
            child: Column(children: [
              Row(
                children: [
                  BackButton(
                    color: Colors.black87,
                    onPressed: () {
                      print("历史记录导航数-->${Jutils.webHisLength()}");
                      Get.back();
                    },
                  )
                ],
              ),
              Expanded(
                  child: DefaultTextStyle(
                style: TextStyle(color: Colors.black87),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        validator: (value) {
                          if (value == '') {
                            return '请输入标题';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelStyle: TextStyle(color: Colors.black87),
                          labelText: '歌单名称',
                        ),
                        onChanged: (val) {
                          print(val);
                          title = val.toString();
                        },
                        initialValue: title,
                      ),
                      Row(
                        children: [
                          Text("展示图片上传方式：${isUrl ? '链接' : '上传本地图片'}"),
                          Switch(
                              value: isUrl,
                              onChanged: (value) {
                                print(value);
                                setState(() {
                                  isUrl = value;
                                });
                              })
                        ],
                      ),
                      isUrl
                          ? TextFormField(
                              initialValue: coverImg,
                              decoration: InputDecoration(
                                labelStyle: TextStyle(color: Colors.black87),
                                labelText: '图片链接',
                              ),
                              onChanged: (val) {
                                coverImg = val.toString();
                              },
                            )
                          : Container(),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          child: Text("选择歌曲",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 19,
                              )),
                          onPressed: () {
                            Get.to(
                                () => GeQuSelect(
                                      onTap: (SgbData data, int index) {
                                        setState(() {
                                          _selectList.add(data);
                                          Get.snackbar('添加成功', data.full_title,
                                              duration:
                                                  Duration(milliseconds: 700),
                                              backgroundColor: Colors.white,
                                              icon: Icon(Icons.star,
                                                  color: Colors.yellow));
                                        });
                                      },
                                    ),
                                transition: Transition.downToUp);
                          },
                        ),
                      ),
                      Wrap(
                        alignment: WrapAlignment.start,
                        children: [
                          ...List.generate(_selectList.length, (index) {
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  margin: EdgeInsets.all(8.0),
                                  padding: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius:
                                          BorderRadius.circular(20.0)),
                                  child: Text(
                                    _selectList[index].full_title,
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.white),
                                  ),
                                ),
                                Positioned(
                                    right: -1,
                                    top: -1,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectList.removeAt(index);
                                          print(_selectList.length.toString());
                                        });
                                      },
                                      child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: Colors.redAccent,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            'x',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16),
                                          )),
                                    ))
                              ],
                            );
                          }),
                        ],
                      ),
                      TextFormField(
                        initialValue: content,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelStyle: TextStyle(color: Colors.black87),
                          labelText: '简介',
                        ),
                        onChanged: (val) {
                          content = val.toString();
                        },
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(onPressed: submit, child: Text("提交"))
                        ],
                      )
                    ],
                  ),
                ),
              ))
            ]),
          ),
        ),
      ),
    );
  }
}

class GeQuSelect extends StatefulWidget {
  final onTap;
  GeQuSelect({Key? key, this.onTap}) : super(key: key);
  @override
  _GeQuSelectState createState() {
    return _GeQuSelectState();
  }
}

class _GeQuSelectState extends State<GeQuSelect> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  onTap(SgbData data, int index) {
    if (widget.onTap != null) {
      widget.onTap(data, index);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SearchPage(
      showHistory: false,
      showBackBtn: true,
      onTap: onTap,
    );
  }
}
