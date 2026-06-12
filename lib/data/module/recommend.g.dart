// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommend.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recommend _$RecommendFromJson(Map<String, dynamic> json) => Recommend(
      id: json['id'] as num,
      title: json['title'] as String,
      linkUrl: json['linkUrl'] as String,
      imgUrl: json['imgUrl'] as String,
    );

Map<String, dynamic> _$RecommendToJson(Recommend instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'linkUrl': instance.linkUrl,
      'imgUrl': instance.imgUrl,
    };
