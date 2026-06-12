/// 反馈请求参数模型
class FeedbackRequest {
  /// 反馈类型：1-BUG反馈 2-功能建议 3-其他
  final int? feedbackType;
  
  /// 反馈标题
  final String? title;
  
  /// 反馈内容（必填）
  final String content;
  
  /// 联系方式
  final String? contact;

  FeedbackRequest({
    this.feedbackType,
    this.title,
    required this.content,
    this.contact,
  });

  /// 转换为JSON格式
  Map<String, dynamic> toJson() {
    return {
      'feedbackType': feedbackType,
      'title': title,
      'content': content,
      'contact': contact,
    };
  }
}

/// 反馈响应结果模型
class FeedbackResponse {
  /// 状态码
  final int code;
  
  /// 消息
  final String msg;
  
  /// 新增记录的数量
  final int? data;

  FeedbackResponse({
    required this.code,
    required this.msg,
    this.data,
  });

  /// 从JSON解析
  factory FeedbackResponse.fromJson(Map<String, dynamic> json) {
    return FeedbackResponse(
      code: json['code'] ?? 0,
      msg: json['msg'] ?? '',
      data: json['data'],
    );
  }
}