import 'dart:core';

class LyricLine {
  final Duration startTime;
  final Duration endTime;
  final String text;

  LyricLine({
    required this.startTime,
    required this.endTime,
    required this.text,
  });

  double getProgress(Duration currentPosition) {
    if (currentPosition < startTime) return 0.0;
    if (currentPosition > endTime) return 1.0;
    final duration = endTime - startTime;
    if (duration.inMilliseconds == 0) return 1.0;
    return (currentPosition - startTime).inMilliseconds / duration.inMilliseconds;
  }
}

class LrcParser {
  static List<LyricLine> parse(String lrc, Duration totalDuration) {
    final lines = lrc.split('\n');
    final List<Map<String, dynamic>> rawLines = [];

    // More flexible regex to handle [mm:ss], [mm:ss.xx], [mm:ss.xxx], [mm:ss:xx]
    final regExp = RegExp(r'\[(\d{1,3}):(\d{2})(?:[:\.](\d{2,3}))?\](.*)');

    for (var line in lines) {
      final match = regExp.firstMatch(line);
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final fractionStr = match.group(3);
        
        int milliseconds = 0;
        if (fractionStr != null) {
          final fraction = int.parse(fractionStr);
          milliseconds = fractionStr.length == 2 ? fraction * 10 : fraction;
        }
        
        final startTime = Duration(
          minutes: minutes,
          seconds: seconds,
          milliseconds: milliseconds,
        );
        final text = match.group(4)!.trim();
        rawLines.add({'start': startTime, 'text': text});
      }
    }

    if (rawLines.isEmpty) return [];

    // Sort by start time just in case
    rawLines.sort((a, b) => (a['start'] as Duration).compareTo(b['start'] as Duration));

    final List<LyricLine> result = [];
    for (var i = 0; i < rawLines.length; i++) {
      final startTime = rawLines[i]['start'] as Duration;
      final text = rawLines[i]['text'] as String;
      
      // End time is the start time of the next line, or total duration for the last line
      final nextStartTime = i < rawLines.length - 1 
          ? rawLines[i + 1]['start'] as Duration 
          : totalDuration;

      // If there's a long gap (> 15s) between this line and the next, 
      // we assume the singing ends after a reasonable time and show a music icon.
      if (i < rawLines.length - 1 && (nextStartTime - startTime).inSeconds > 15 && text.isNotEmpty) {
        final singingDuration = const Duration(seconds: 10);
        final breakStartTime = startTime + singingDuration;
        
        // Add the singing part
        result.add(LyricLine(
          startTime: startTime,
          endTime: breakStartTime,
          text: text,
        ));
        
        // Add the instrumental part
        result.add(LyricLine(
          startTime: breakStartTime,
          endTime: nextStartTime,
          text: "", // Empty string triggers music icon
        ));
      } else {
        result.add(LyricLine(
          startTime: startTime,
          endTime: nextStartTime,
          text: text,
        ));
      }
    }

    return result;
  }
}
