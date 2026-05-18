import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/discord_message.dart';

Future<void> sendDiscordMessage({
  required String baseUrl,
  required String apiKey,
  required String message,
  required String appUserId,
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
      'appUserId': appUserId,
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

Future<List<String>> fetchSkillSuggestions({
  required String baseUrl,
  required String apiKey,
  required String query,
}) async {
  final uri = Uri.parse('$baseUrl/api/database/suggest').replace(
    queryParameters: {'q': query},
  );

  final res = await http.get(uri, headers: {'X-API-KEY': apiKey});

  if (res.statusCode != 200) {
    throw Exception('Failed: ${res.statusCode} ${res.body}');
  }

  final data = jsonDecode(res.body) as List<dynamic>;
  return data.map((e) => e.toString()).toList();
}

Future<String?> fetchSkillText({
  required String baseUrl,
  required String apiKey,
  required String id,
}) async {
  final uri = Uri.parse('$baseUrl/api/database/${Uri.encodeComponent(id)}');

  final res = await http.get(uri, headers: {'X-API-KEY': apiKey});

  if (res.statusCode == 404) return null;

  if (res.statusCode != 200) {
    throw Exception('Failed: ${res.statusCode} ${res.body}');
  }

  final data = jsonDecode(res.body) as Map<String, dynamic>;
  return data['text']?.toString();
}