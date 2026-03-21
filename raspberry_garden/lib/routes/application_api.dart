import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class DiscordMessage {
  final String user;
  final String content;
  final DateTime time;

  DiscordMessage({
    required this.user,
    required this.content,
    required this.time,
  });

  factory DiscordMessage.fromJson(Map<String, dynamic> json) {
    return DiscordMessage(
      user: json['user']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      time: DateTime.tryParse(json['time']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

Future<void> sendDiscordMessage({
  required String baseUrl,
  required String apiKey,
  required String message,
}) async {
  final uri = Uri.parse('$baseUrl/api/discord/send');

  final res = await http.post(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'X-API-KEY': apiKey,
    },
    body: jsonEncode({
      'message': message,
    }),
  );

  if (res.statusCode != 200) {
    throw Exception('Failed: ${res.statusCode} ${res.body}');
  }
}

Future<List<DiscordMessage>> fetchDiscordMessages({
  required String baseUrl,
  required String apiKey,
}) async {
  final uri = Uri.parse('$baseUrl/api/discord/messages');

  final res = await http.get(
    uri,
    headers: {
      'X-API-KEY': apiKey,
    },
  );

  if (res.statusCode != 200) {
    throw Exception('Failed: ${res.statusCode} ${res.body}');
  }

  final data = jsonDecode(res.body) as List<dynamic>;
  return data
      .map((e) => DiscordMessage.fromJson(e as Map<String, dynamic>))
      .toList();
}