import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Generative App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RandomFactScreen(),
    );
  }
}

class RandomFactScreen extends StatefulWidget {
  const RandomFactScreen({super.key});

  @override
  _RandomFactScreenState createState() => _RandomFactScreenState();
}

class _RandomFactScreenState extends State<RandomFactScreen> {
  /// These are the fields you can play around with
  /// systemPrompt -> THE CONTEXT OF THE SYSTEM
  /// userPrompt -> WHAT USER WILL ENTER TO INTERACT WITH THE SYSTEM
  /// apiKey -> GET YOUR API KEY FROM OPEN AI (https://platform.openai.com/account/api-keys)
  String systemPrompt =
      "You are a Flutter Super App which is integrated with OpenAI, randomly generate some amazing output value for the reader which makes them go wow output limit is under 5 lines.";
  String userPrompt = "Hello! Generate some amazing text based outputs for me.";
  String apiKey = "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";

  bool isLoading = false;
  String randomFact = '';
  String apiUrl = "https://api.openai.com/v1/chat/completions";

  Future<String> makeAPICall() async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userPrompt},
        ],
      }),
    );

    debugPrint(response.body.toString());

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      String completion = data['choices'][0]['message']['content'];
      String tokens = data['usage']['total_tokens'].toString();
      debugPrint(
          "Got Response form Open AI ${data.toString()}\n\n💰 Tokens Used : $tokens");
      return completion;
    } else {
      throw Exception('API request failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : randomFact.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Text(
                      randomFact,
                      style: const TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  )
                : const Text(
                    'Tap the FAB to fetch a random fact',
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (isLoading == true) {
            // If already loading, we don't make more request calls.
            return;
          }
          setState(() {
            isLoading = true;
          });
          String response = await makeAPICall();
          setState(() {
            randomFact = response;
            isLoading = false;
          });
        },
        child: isLoading == true
            ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.refresh),
      ),
    );
  }
}
