import 'dart:convert';

class VideoMessage {
  String message;
  List<Video> videos;

  VideoMessage({required this.message, required this.videos});

  VideoMessage copyWith({String? message, List<Video>? videos}) => VideoMessage(
    message: message ?? this.message,
    videos: videos ?? this.videos,
  );

  factory VideoMessage.fromRawJson(String str) =>
      VideoMessage.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory VideoMessage.fromJson(Map<String, dynamic> json) => VideoMessage(
    message: json["message"],
    videos: List<Video>.from(json["videos"].map((x) => Video.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "videos": List<dynamic>.from(videos.map((x) => x.toJson())),
  };
}

class Video {
  String videoId;
  String title;
  String description;
  String thumbnail;
  String? channelId;

  Video({
    required this.description,
    required this.thumbnail,
    required this.title,
    required this.videoId,
    this.channelId,
  });

  Video copyWith({
    String? videoId,
    String? title,
    String? description,
    String? thumbnail,
    String? channelId,
  }) => Video(
    description: description ?? this.description,
    title: title ?? this.title,
    videoId: videoId ?? this.videoId,
    thumbnail: thumbnail ?? this.thumbnail,
    channelId: channelId ?? this.channelId,
  );

  factory Video.fromRawJson(String str) => Video.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Video.fromJson(Map<String, dynamic> json) => Video(
    videoId: json["videoId"],
    title: json["title"],
    description: json["description"],
    thumbnail: json["thumbnail"],
    channelId: json["channelId"],
  );

  Map<String, dynamic> toJson() => {
    "videoId": videoId,
    "title": title,
    "description": description,
    "thumbnail": thumbnail,
    "channelId": channelId,
  };
}
