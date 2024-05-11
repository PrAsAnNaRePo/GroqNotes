import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' show post;

Future<String> voiceToText(String filePath) async {
  final file = File(filePath);
  if (!await file.exists()) {
    throw Exception('Audio file not found: $filePath');
  }
  const String url =
      "https://api.deepgram.com/v1/listen?model=nova&punctuate=true";

  String? deepGramSecretKey = dotenv.env['DEEPGRAM_SECRET_KEY'];
  print(".........   $deepGramSecretKey");
  // encode to UTF-8
  final bytes = await file.readAsBytes();

  final response = await post(
    Uri.parse(url),
    headers: {
      HttpHeaders.contentTypeHeader: 'audio/wav',
      HttpHeaders.authorizationHeader: 'Token $deepGramSecretKey'
    },
    body: bytes,
  );
  final message = jsonDecode(response.body)['results']['channels'][0]
      ['alternatives'][0]['transcript'];
  return message;
}
