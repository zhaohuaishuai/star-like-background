// ignore_for_file: non_constant_identifier_names
 
import 'package:json_annotation/json_annotation.dart';
part 'bible_search_content.g.dart';
@JsonSerializable()
class BibleSearchContent {
 
     final int ID; 
     final int VolumeSN;  
     final int ChapterSN;  
     final int VerseSN; 
     final String Lection;
     final String ShortName;

     BibleSearchContent({required this.ID, required this.VolumeSN, required this.ChapterSN, required this.VerseSN, required this.Lection, required this.ShortName});

     factory BibleSearchContent.fromJson(Map<String, dynamic> json) => _$BibleSearchContentFromJson(json);
     Map<String, dynamic> toJson() => _$BibleSearchContentToJson(this);
}