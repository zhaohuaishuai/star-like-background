import 'package:json_annotation/json_annotation.dart';
part 'captcha_image.g.dart';

@JsonSerializable()
class CaptchaImage {
  final String img;
  final String uuid;
  CaptchaImage({required this.img, required this.uuid});

  factory CaptchaImage.fromJson(Map<String, dynamic> json) =>
      _$CaptchaImageFromJson(json);

  Map<String, dynamic> toJson() => _$CaptchaImageToJson(this);
}
