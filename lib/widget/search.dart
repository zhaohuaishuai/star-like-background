
import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final ValueChanged<String>? onchangeValue;
  final VoidCallback? onEditingComplete;
  final VoidCallback? onClear;
  final VoidCallback? onTap;
  bool? enabled;
  bool? autofocus;
  final FocusNode? focusNode;
  SearchBarWidget({
    this.onchangeValue,
    this.onEditingComplete,
    this.onClear,
    this.autofocus,
    this.focusNode,
    this.onTap,
    this.enabled,
    Key? key})
      : super(key: key);

  @override
  SearchBarWidgetState createState() => SearchBarWidgetState();
}

class SearchBarWidgetState extends State<SearchBarWidget> {

  setText(String value){
    _controller.text = value;
  }
  ///编辑控制器
  late TextEditingController _controller;

  ///是否显示删除按钮
  bool _hasDeleteIcon = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  Widget buildTextField() {
    //theme设置局部主题
    return TextField(
      controller: _controller,
      focusNode: widget.focusNode !=null? widget.focusNode:null,
      textInputAction: TextInputAction.search,
      keyboardType: TextInputType.text,
      maxLines: 1,
      decoration: InputDecoration(
        //输入框decoration属性
        contentPadding:
        const EdgeInsets.symmetric(vertical: 5.0, horizontal: 1.0),
        //设置搜索图片
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 0.0),
          child: SizedBox(
            width: 26,
            height: 26,
            child: Image.asset(
              'assets/images/seacher_icon.png',
            ),
          ),
        ),
        prefixIconConstraints: BoxConstraints(
          //设置搜索图片左对齐
          minWidth: 30,
          minHeight: 25,
        ),
        border: InputBorder.none, //无边框
        hintText: "搜索索引号、赞美名称或着歌词",

        hintStyle: new TextStyle(fontSize: 16, color:  Color.fromARGB(155, 0, 22, 84)),
        //设置清除按钮
        suffixIcon: Container(
          padding: EdgeInsetsDirectional.only(
            start: 2.0,
            end: _hasDeleteIcon ? 0.0 : 0,
          ),
          child: _hasDeleteIcon
              ? new InkWell(
            onTap: (() {
              setState(() {
                /// 保证在组件build的第一帧时才去触发取消清空内容
                WidgetsBinding.instance
                    .addPostFrameCallback((_) {
                  _controller.clear();
                  widget.onClear!();
                  if(widget.onTap !=null){
                    widget.onClear!();
                  }
                });
                _hasDeleteIcon = false;
              });
            }),
            child: Icon(
              Icons.cancel,
              size: 18.0,
              color: Colors.grey,
            ),
          )
              : new Text(''),
        ),
      ),
      enabled: widget.enabled == null ? false:widget.enabled,
      autofocus: widget.autofocus == null?false:widget.autofocus as bool,
      onTap:(){
        print("点击");
        widget.onTap!();
      },
      onChanged: (value) {
        setState(() {
          if (value.isEmpty) {
            _hasDeleteIcon = false;
          } else {
            _hasDeleteIcon = true;
          }
          if(widget.onchangeValue !=null){
            widget.onchangeValue!(_controller.text);
          }

        });
      },
      onEditingComplete: () {
        if(widget.focusNode !=null){
          FocusScope.of(context).requestFocus(widget.focusNode);
        }
        if(widget.onEditingComplete !=null ){
          widget.onEditingComplete!();
        }
      },
      style: new TextStyle(fontSize: 13, color: Colors.black),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //背景与圆角
      decoration: new BoxDecoration(
       //边框
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Color.fromARGB(120, 166, 166, 166),
                offset: Offset(5.0, 5.0),
                blurRadius: 6.0),
          ]

      ),
      alignment: Alignment.center,
      height: 40,
      padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
      child: buildTextField(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

