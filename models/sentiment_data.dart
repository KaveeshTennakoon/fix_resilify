import 'package:hive/hive.dart';

part 'sentiment_data.g.dart';

@HiveType(typeId: 2)
class SentimentData extends HiveObject {
  @HiveField(0)
  String sentimentId;

  @HiveField(1)
  DateTime time;

  @HiveField(2)
  double score;

  @HiveField(3)
  String prompt;

  SentimentData({required this.sentimentId, required this.time, required this.score, required this.prompt});

  SentimentData copyWith({double? score, String? prompt}) {
    return SentimentData(
      sentimentId: sentimentId,
      time: time,
      score: score ?? this.score,
      prompt: prompt ?? this.prompt,
    );
  }
}