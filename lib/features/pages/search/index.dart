import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/shared/builder/sliver_persistent_header_builder.dart';
import 'package:m/shared/widgets/h1.dart';
import 'package:m/shared/widgets/search_text_field.dart';
import 'controller.dart';

class SearchPage extends GetView<SearchPageController> {
  final bool isPickeMode;
  final void Function(String)? onSelected;
  const SearchPage({super.key, this.isPickeMode = false, this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _build(context));
  }

  _build(BuildContext context) {
    return Obx(() {
      List<Widget> slivers = [
        SliverAppBar(
          pinned: true,
          title: SearchTextField(
            clean: true,
            autofocus: true,
            controller: controller.searchTextController,
          ),
        ),
      ];
      if (controller.hostoryList.isEmpty && controller.searchText.isEmpty) {
        slivers.add(_buildEmpty(context));
      }

      if (controller.searchText.isNotEmpty) {
      
        slivers.addAll(_buildSearchView(context));
      }

      if (controller.hostoryList.isNotEmpty && controller.searchText.isEmpty) {
        slivers.addAll(_buildHistoryList(context));
      }



      return CustomScrollView(
        slivers: slivers,
      );
    });
  }

  _buildHistoryList(BuildContext context) {
    return [
      SliverPersistentHeader(
        pinned: true,
        delegate: Sliverpersistentheaderbuilder(
            max: 50,
            min: 50,
            builder: (context, shrinkOffset, overlapsContent) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: H1(title: '历史记录'.tr)),
                  IconButton(
                      onPressed: () {
                        controller.delHistory();
                      },
                      icon: const Icon(Icons.delete_forever))
                ],
              );
            }),
      ),
      SliverList.builder(
        itemCount: controller.hostoryList.length,
        itemBuilder: (context, index) {
          String? title = controller.hostoryList[index]?.mulu;
          String? subtitle = controller.hostoryList[index]?.shijiName;
          return _buildListTile(
            controller.hostoryList[index]?.id ?? '',
            controller.hostoryList[index]!.ShijiTypeId,
            title: title,
            subtitle: subtitle,
          );
        },
      )
    ];
  }

  ListTile _buildListTile(
    String id,
    int shijiId, {
    String? title,
    String? subtitle,
    String? trailing,
    Widget? subtitleWidget,
  }) {
    return ListTile(
      onTap: () {
        if (isPickeMode) {
          onSelected?.call(id);
          return;
        }
        debugPrint('$id,$shijiId');
        controller.toPlayer(
          id,
          shijiId,
        );
      },
      title: Text(title ?? ''),
      trailing: Text(trailing ?? ''),
      subtitle: subtitle != null ? Text(subtitle) : subtitleWidget,
    );
  }

  _buildEmpty(BuildContext context) {
    return SliverFillRemaining(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.search_sharp,
                size: 120,
              ),
              Text(
                '请输入要搜索的内容\n可输入索引号或标题或歌词'.tr,
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSearchView(BuildContext context) {
    return [
    
      
      ..._buildTitleSearchView(context),
      
      ..._buildLyricSearchView(context),
     
      ..._buildDictSearchView(context),
      
     ..._buildVerseSearchView(context),
    ];
  }
 

  SliverPersistentHeader _buildTitle(String title) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: Sliverpersistentheaderbuilder(
          max: 50,
          min: 50,
          builder: (context, shrinkOffset, overlapsContent) {
            return Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: H1(
                title: title,
              ),
            );
          }),
    );
  }

  _buildTitleSearchView(BuildContext context) {
    final len = controller.searchTitleList.length;
     final title = _buildTitle('按标题索引搜索 $len条'.tr);
    final list = SliverList.builder(
      itemBuilder: (context, index) {
        String? title = controller.searchTitleList[index].mulu;
        String? subTitle = controller.searchTitleList[index].shijiName;
        return _buildListTile(
          controller.searchTitleList[index].id,
          controller.searchTitleList[index].ShijiTypeId,
          title: title,
          subtitle: subTitle,
        );
      },
      itemCount: len,
    );

    return [title,list];
  }

  _buildLyricSearchView(BuildContext context) {
    final title = _buildTitle('按歌词索引搜索 ${controller.searchLyricList.length}条'.tr);
    final len = controller.searchLyricList.length;
    final list = SliverList.builder(
      itemBuilder: (context, index) { 
        String id = controller.searchLyricList[index].id;
        String fullTitle = controller.searchLyricList[index].fullTitle;
        String shijiname = controller.searchLyricList[index].shijiname;
        int shijiId = controller.searchLyricList[index].shijiIndex;
        Widget subTitle =
            _buildRichText(controller.searchLyricList[index].dmtUrl.lyric ?? '');
        return _buildListTile(
          id,
          shijiId,
          title: fullTitle,
          subtitleWidget: subTitle,
          trailing: shijiname,
        ); 
      },
      itemCount: len,
    );
    return [title,list];
     
   
  }

  Widget _buildRichText(String? lyric) {
    if (lyric == null) return Container();
    
    String startSpan = '<span class="text-subtitle">';
    String boldStr =
        '<span class="!text-orange-500 lighten-1 font-weight-medium ">';
    String endSpan = '</span>';
    String brStr = '<br>'; 
    List<List<String>> list = lyric.split(brStr).map((item)=>item.replaceAll(RegExp('$startSpan|$boldStr|$endSpan'), '')).toList().map((item)=>item.split(controller.searchText)).toList();
    
    List<TextSpan> spanList = [];
    for(int i = 0 ; i < list.length; i++){ 
      for(int j = 0 ; j < list[i].length; j++){
        if(j>0){
          spanList.add(TextSpan(text: controller.searchText,style:const TextStyle(fontWeight: FontWeight.bold)),);
        }
        spanList.add(TextSpan(text: list[i][j]));
      }
      if(i < list.length -2){
        spanList.add(const TextSpan(text: '\n'));
      }
      
    }
  
    var span = TextSpan(children: spanList);
    return Text.rich(span);
  }
  
  _buildDictSearchView(BuildContext context) {
    List<String>? chapterDict = controller.bibleDictList; 
    if(chapterDict == null ) {
    return [const SliverToBoxAdapter(child: SizedBox(),)];
    }
    final title = _buildTitle('按经文目录搜索 ${chapterDict.length}条'.tr);
    final list = SliverList.builder(
      itemBuilder: (context, index) { 
        return ListTile(title: Text(chapterDict[index]),onTap: ()=>controller.toBible(chapterDict[index]),);
      },
      itemCount:chapterDict.length,
    );
    return [title,list];
  }

  _buildVerseSearchView(BuildContext context) {
    final title = _buildTitle('按经文搜索 ${controller.searchVerseList.length}条'.tr);

 

    final list = SliverList.builder(
      itemBuilder: (context, index) { 

// ignore: non_constant_identifier_names
                int ChapterSN = controller.searchVerseList[index].ChapterSN;
                 // ignore: non_constant_identifier_names
                int VerseSN = controller.searchVerseList[index].VerseSN;
                 // ignore: non_constant_identifier_names
                String Lection = controller.searchVerseList[index].Lection;
                 // ignore: non_constant_identifier_names
                String ShortName = controller.searchVerseList[index].ShortName;
                String id = '$ShortName$ChapterSN:$VerseSN';

                List<String> list = Lection.split(controller.searchText);

            
                List<TextSpan> spanList = [];
                for(int i = 0 ; i < list.length; i++){
                  if(i >0){
                    spanList.add(TextSpan(text: controller.searchText,style:const TextStyle(fontWeight: FontWeight.bold)),);
                  }
                  spanList.add(TextSpan(text: list[i]));
                }

                 var span = TextSpan(children: spanList);
                 return ListTile(
                  title: Text(id),
                  subtitle: Text.rich(span),
                  onTap: ()=>controller.toBible(id)
                 );


       },
      itemCount:controller.searchVerseList.length,
    );
    return [title,list];
}
}


