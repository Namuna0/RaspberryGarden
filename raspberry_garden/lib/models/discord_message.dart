class DiscordMessage {
  final String user;
  final String content;
  final DateTime time;
  final String? appUserId;
  final String? iconUrl;

  const DiscordMessage({
    required this.user,
    required this.content,
    required this.time,
    this.appUserId,
    this.iconUrl,
  });

  factory DiscordMessage.fromJson(Map<String, dynamic> json) {
    return DiscordMessage(
      user: json['user']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      time: DateTime.tryParse(json['time']?.toString() ?? '') ?? DateTime.now(),
      appUserId: json['appUserId']?.toString(),
      iconUrl: json['iconUrl']?.toString(),
    );
  }
}
