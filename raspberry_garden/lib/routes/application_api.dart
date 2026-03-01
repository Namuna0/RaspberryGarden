import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

Future<void> sendDiscordMessage({
  required String baseUrl,
  required String apiKey,
}) async {
  final uri = Uri.parse('$baseUrl/api/discord/send');

  final res = await http.post(
    uri,
    headers: {
      'X-API-KEY': apiKey,
    },
  );

  if (res.statusCode != 200) {
    throw Exception('Failed: ${res.statusCode} ${res.body}');
  }
}
