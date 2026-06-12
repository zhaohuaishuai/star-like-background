// ignore_for_file: non_constant_identifier_names
 
import 'package:json_annotation/json_annotation.dart';
part 'bible_content.g.dart';
@JsonSerializable()
class BibleContent {
 
     final int ID;
 
     final int VolumeSN; 
  
     final  int ChapterSN; 
   
     final  int VerseSN;
 
     final String Lection;

     BibleContent({required this.ID, required this.VolumeSN, required this.ChapterSN, required this.VerseSN, required this.Lection});

     factory BibleContent.fromJson(Map<String, dynamic> json) => _$BibleContentFromJson(json);
     Map<String, dynamic> toJson() => _$BibleContentToJson(this);
}