
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/core/utils/toast.dart';
import 'package:m/features/pages/bible/bible_dict.dart';
import 'package:m/features/pages/bible/book_mark_util.dart';
import 'package:m/shared/widgets/empty.dart';
 
 

class BookMark extends StatefulWidget {
  final Color color;
  final BookMarkUtil bookMarkUtil;
  final void Function(ZhangBibleDict q, JieBibleDict z, int j)? change;
  
  const BookMark({
    super.key,
    required this.bookMarkUtil,
    this.change,
    
    required this.color,
  });
  @override
  State<StatefulWidget> createState() => BookMarkState();
}

class BookMarkState extends State<BookMark> {
  late List<Map> bookMarkList = List.empty();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    List<Map> list = await widget.bookMarkUtil.queryList();
    setState(() {
      bookMarkList = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600,
      padding: const EdgeInsets.only(top: 0, bottom: 24, left: 10, right: 10),
      child: Column(
        children: [
          Padding(padding: const EdgeInsets.all(20), child: Text('书签管理'.tr)),
          Expanded(child: Builder(builder: (context) {
            if (bookMarkList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const EmptyWidget(),
                    Text(
                      '暂无数据'.tr,
                    ),
                    Text(
                      '请选择一条经文点击添加书签按钮'.tr,
                    )
                  ],
                ),
              );
            }

            return ListView.builder(
                itemBuilder: (context, index) {
                  return Dismissible(
                      key: ValueKey(bookMarkList[index]['_id']),
                      onDismissed: (direction) {
                        try {
                          widget.bookMarkUtil
                              .delete(bookMarkList[index]['_id']);
                          init();
                          Toast.showToast('删除成功'.tr);
                        } catch (err) {
                          Toast.showToast('删除失败'.tr);
                        }
                      },
                      background: Align(
                          alignment: Alignment.centerRight,
                          child: Text('删除书签'.tr)),
                      child: ListTile(
                        onTap: () {
                          ZhangBibleDict z = ZhangBibleDict.fromJson(jsonDecode(
                              bookMarkList[index]
                                  [widget.bookMarkUtil.columnZDict]));
                          JieBibleDict je = JieBibleDict.fromJson(jsonDecode(
                              bookMarkList[index]
                                  [widget.bookMarkUtil.columnJDict]));
                          int j = int.parse(bookMarkList[index]
                              [widget.bookMarkUtil.columnIndex]);
                          widget.change!(z, je, j);
                        },
                        title: Text(bookMarkList[index]['title']),
                        subtitle: Text(
                            "${bookMarkList[index]['create_date'].toString()} 创建"),
                      ));
                },
                itemCount: bookMarkList.length);
          }))
        ],
      ),
    );
  }
}