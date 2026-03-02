import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

Future<void> sendDiscordMessage({
  required String baseUrl,
  required String apiKey,
  required String message,
}) async {
  final uri = Uri.parse('$baseUrl/api/discord/send');

  final res = await http.post(
    uri,
    headers: {
      'Content-Type': 'application/json', // ★必須
      'X-API-KEY': apiKey,
    },
    body: jsonEncode({
      'message': message, // ★C#の MessageRequest.Message に対応
    }),
  );

  if (res.statusCode != 200) {
    throw Exception('Failed: ${res.statusCode} ${res.body}');
  }
}