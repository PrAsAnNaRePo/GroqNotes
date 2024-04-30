import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' show post;

Future<String> getTasksList(String query) async {
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
                "You are a helpful assistant. User will provide you a content what they gonna do or their plan. You have read it completely and make a set of tasks from what they have provided. Make sure you have added all valid tasks and return only the list of tasks with new line seperation(no other text or suggestions). No Serial numbers or bullet points needed. Also make the Sequential of the tasks correct. Make the tasks simpler and easy to understand."
          },
          {
            "role": "user",
            "content":
                "Gotta heads up to the gym and buy some banana while returning to home and make some smoothie after reached."
          },
          {
            "role": "assistant",
            "content": "Go to the gym\nBuy bananas\nMake a smoothie"
          },
          {"role": "user", "content": query},
        ],
      },
    ),
  );
  final message = jsonDecode(response.body)["choices"][0]["message"]['content'];
  return message;
}
