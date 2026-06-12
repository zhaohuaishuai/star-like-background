

String convertAssToAdvancedLyric(String assLyric, {
  String title = '',
  String artist = '',
  String album = '',
  String by = '',
  int offset = 0,
}) {
  final lines = assLyric.split('\n');
  final builder = StringBuffer(); 
  // 添加头部信息
  if (title.isNotEmpty) builder.writeln('[ti:$title]');
  if (artist.isNotEmpty) builder.writeln('[ar:$artist]');
  if (album.isNotEmpty) builder.writeln('[al:$album]');
  builder.writeln('[by:$by]');
  builder.writeln('[offset:$offset]');
  
  // 找到[Events]部分
  final eventsIndex = lines.indexWhere((line) => line.startsWith('[Events]'));
  if (eventsIndex == -1) {
    return builder.toString();
  }
  
  // 解析[Events]部分
  for (var i = eventsIndex; i < lines.length; i++) {
    final line = lines[i].trim();
    
    if (line.startsWith('Dialogue:')) {
      final lyricLine = _parseDialogueLine(line);
      if (lyricLine != null) {
        builder.writeln(lyricLine);
      }
    }
    
    // 如果遇到下一个section，结束解析
    if (line.startsWith('[') && line.endsWith(']') && line != '[Events]') {
      break;
    }
  }
  
  return builder.toString();
}

String? _parseDialogueLine(String line) {
  // 解析Dialogue行: Dialogue: 0,0:00:16.01,0:00:23.53,Default1,,0,0,0,,{\kf24}愿{\kf39}神{\kf36}的{\kf28}恩{\kf141}典{\kf54}降{\kf51}临{\kf36}到{\kf44}我{\kf27}里{\kf187}面
  final parts = line.split(',');
  if (parts.length < 10) return null;
  
  // 提取开始时间和结束时间
  final startTimeStr = parts[1];
  final endTimeStr = parts[2];
  
  // 提取文本内容（从第10个元素开始，因为前面可能有逗号）
  final text = parts.sublist(9).join(',');
  
  // 转换时间为毫秒
  final startTimeMs = _timeToMs(startTimeStr);
  final endTimeMs = _timeToMs(endTimeStr);
  final duration = endTimeMs - startTimeMs;
  
  // 解析文本中的卡拉OK效果标签
  final parsedData = _parseKaraokeTags(text, startTimeMs);
  
  if (parsedData.isEmpty) {
    // 如果没有卡拉OK标签，直接返回该行
    return '[$startTimeMs,$duration]$text';
  }
  
  // 构建高级歌词格式
  final builder = StringBuffer();
  builder.write('[$startTimeMs,$duration]');
  
  // 先添加完整歌词
  final fullLyric = parsedData.map((item) => '${item.char} (${item.startTime},${item.duration})').join('');
  builder.write(fullLyric);  
  return builder.toString();
}

int _timeToMs(String timeStr) {
  // 转换时间格式 0:00:00.00 到毫秒
  final parts = timeStr.split(':');
  if (parts.length != 3) return 0;
  
  final hours = int.tryParse(parts[0]) ?? 0;
  final minutes = int.tryParse(parts[1]) ?? 0;
  
  final secondsParts = parts[2].split('.');
  final seconds = int.tryParse(secondsParts[0]) ?? 0;
  final milliseconds = secondsParts.length > 1 
    ? int.tryParse(secondsParts[1].padRight(3, '0').substring(0, 3)) ?? 0
    : 0;
  
  return hours * 3600000 + minutes * 60000 + seconds * 1000 + milliseconds;
}

List<_KaraokeChar> _parseKaraokeTags(String text, int startTimeMs) {
  
  int currentPosition = startTimeMs;
  
  // 确保我们使用正确的正则表达式，只匹配一个字符
  final regex = RegExp(r'\{\\kf(\d+)\}([A-Za-z0-9_\.\u4E00-\u9FA5]*)'); 
  final matches = regex.allMatches(text);
  
  // 存储所有匹配的标签和字符位置
  final tagCharPairs = <_TagCharPair>[];
  
  for (final match in matches) {
    if (match.groupCount >= 2) {
      final durationStr = match.group(1);
      final char = match.group(2);
      
      if (durationStr != null && char != null && char.isNotEmpty) {
        final durationCentiseconds = int.tryParse(durationStr) ?? 0;
        // Aegisub中的{kf}持续时间是1/100秒(厘秒)，需要转换为毫秒
        final durationMs = durationCentiseconds * 10;
        
        // 计算字符的开始时间
        final charStartTime = currentPosition;
        
        // 添加标签和字符对
        tagCharPairs.add(_TagCharPair(char, charStartTime, durationMs));
        
        // 更新下一个字符的开始时间
        currentPosition += durationMs;
      }
    }
  }
  
  // 如果使用正则匹配失败，尝试手动解析
  if (tagCharPairs.isEmpty) {
    return _manualParseKaraokeTags(text, startTimeMs);
  }
  
  // 将标签和字符对转换为KaraokeChar对象
  return tagCharPairs.map((pair) => _KaraokeChar(pair.char, pair.startTime, pair.duration)).toList();
}

List<_KaraokeChar> _manualParseKaraokeTags(String text, int startTimeMs) {
  final chars = <_KaraokeChar>[];
  int currentPosition = startTimeMs;
  int pos = 0;
  
  while (pos < text.length) {
    // 查找{kf数字}标签的开始
    // ignore: unnecessary_string_escapes
    final tagStart = text.indexOf('{\kf', pos);
    if (tagStart == -1) break;
    
    // 查找标签中的数字结束位置
    final tagEnd = text.indexOf('}', tagStart);
    if (tagEnd == -1) break;
    
    // 提取数字部分
    final durationStr = text.substring(tagStart + 4, tagEnd);
    final durationCentiseconds = int.tryParse(durationStr) ?? 0;
    final durationMs = durationCentiseconds * 10;
    
    // 获取标签后面的字符
    final charPos = tagEnd + 1;
    if (charPos < text.length) {
      final char = text[charPos];
      chars.add(_KaraokeChar(char, currentPosition, durationMs));
      currentPosition += durationMs;
    }
    
    pos = charPos + 1;
  }
  
  return chars;
}

class _KaraokeChar {
  final String char;
  final int startTime;
  final int duration;
  
  _KaraokeChar(this.char, this.startTime, this.duration);
}

class _TagCharPair {
  final String char;
  final int startTime;
  final int duration;
  
  _TagCharPair(this.char, this.startTime, this.duration);
}
 