import 'package:m/features/pages/feedback/model.dart';

import 'package:m/data/api/dio_common.dart';

/// 反馈API提供者
class FeedbackProvider {
  /// 提交反馈
  Future<FeedbackResponse?> submitFeedback(FeedbackRequest request) async {
    final result = await dioCommon.post('/no-auth/star/h5/feedback/submit',
        data: request.toJson());

    if (result.body != null && result.body['code'] != null) {
      return FeedbackResponse.fromJson(result.body);
    } else {
      return null;
    }
  }
}
