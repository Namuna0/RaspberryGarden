import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/discord_message.dart';

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