import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m/core/theme/theme_data.dart';
import 'package:m/core/utils/toast.dart';
import 'package:m/data/api/feedback.dart';
import 'package:m/features/pages/feedback/model.dart';

/// 反馈类型枚举
enum FeedbackType {
  bug('BUG反馈', 1),
  suggestion('功能建议', 2),
  other('其他', 3);

  const FeedbackType(this.label, this.value);
  final String label;
  final int value;
}

/// 反馈页面
class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  FeedbackType _selectedType = FeedbackType.bug;
  bool _isLoading = false;
  late final FeedbackProvider _provider = FeedbackProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('问题反馈'),
        centerTitle: true,
        backgroundColor: StarThemeData.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(StarThemeData.spacing),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 反馈类型选择
                Text('反馈类型',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                SizedBox(height: 8),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButton<FeedbackType>(
                        value: _selectedType,
                        isExpanded: true,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        items: FeedbackType.values.map((FeedbackType type) {
                          return DropdownMenuItem<FeedbackType>(
                            value: type,
                            child: Text(type.label),
                          );
                        }).toList(),
                        onChanged: (FeedbackType? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedType = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // 标题输入框（可选）
                Text('标题（可选）',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: '请输入反馈标题',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: StarThemeData.primaryColor, width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 8),

                // 反馈内容输入框（必填）
                Text('反馈内容*',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                SizedBox(height: 8),
                TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: false,
                  keyboardType: TextInputType.multiline,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: '请详细描述您的问题或建议',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: StarThemeData.primaryColor, width: 2),
                    ),
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
                SizedBox(height: 8),
                // 联系方式输入框（可选）
                Text('联系方式（可选）',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                SizedBox(height: 8),
                TextField(
                  controller: _contactController,
                  decoration: InputDecoration(
                    hintText: '请输入您的联系方式（QQ、微信等）',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: StarThemeData.primaryColor, width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 8),

                // 提交按钮
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitFeedback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StarThemeData.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('提交反馈', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 提交反馈
  void _submitFeedback() async {
    if (_contentController.text.trim().isEmpty) {
      Toast.showToast('反馈内容不能为空', ToastStatusEnum.error);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 创建反馈请求对象
      final request = FeedbackRequest(
        feedbackType: _selectedType.value,
        title: _titleController.text.isNotEmpty ? _titleController.text : null,
        content: _contentController.text,
        contact:
            _contactController.text.isNotEmpty ? _contactController.text : null,
      );

      // 调用API提交反馈

      final response = await _provider.submitFeedback(request);

      if (response != null && response.code == 200) {
        Toast.showToast('反馈提交成功', ToastStatusEnum.success);

        // 清空表单
        _titleController.clear();
        _contentController.clear();
        _contactController.clear();
        setState(() {
          _isLoading = false;
        });

        // 提交成功后退出当前页面
        Navigator.of(context).pop();
      } else {
        Toast.showToast(response?.msg ?? '提交失败，请稍后重试', ToastStatusEnum.error);
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      Toast.showToast('网络异常，请稍后重试', ToastStatusEnum.error);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _contactController.dispose();
    super.dispose();
  }
}
