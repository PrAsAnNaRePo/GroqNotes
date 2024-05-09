import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' show post;

Future<String> getResponse(String query) async {
  const String url = "https://api.groq.com/openai/v1/chat/completions";

  String? groqApiKey = dotenv.env['GROQ_API_KEY'];

  final response = await post(
    Uri.parse(url),
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $groqApiKey'
    },
    body: jsonEncode(
      {
        "model": "llama3-70b-8192",
        "messages": [
          {
            "role": "system",
            "content":
                "You are a helpful assistant. Given the instruction and the content, You have make edit on the content based on the instruction. Also return only the edited content (no other text or suggestions). If the user wants you to write your own contens without any instruction given, you can write your own content."
          },
          {
            "role": "user",
            "content":
                "Instruction: Make it more sounds like American tone and fix grammer.\ncontent: Just built a new feature for my app and have to take a look at it, how it works."
          },
          {
            "role": "assistant",
            "content":
                'I just built a new feature for my app and I need to take a look at how it works.'
          },
          {"role": "user", "content": query},
        ],
      },
    ),
  );
  final message = jsonDecode(response.body)["choices"][0]["message"]['content'];
  return message;
}
