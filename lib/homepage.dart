import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:wizgpt/feature_box.dart';
import 'package:wizgpt/openai_service.dart';
import 'package:wizgpt/pallete.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _textController = TextEditingController();
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  final OpenAIService openAIService = OpenAIService();
  String lastWords = '';
  String? generatedContent;
  String? generatedImageUrl;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  // Each time to start a speech recognition session
  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  Future<void> systemSpeak(String content) async {
    flutterTts.speak(content);
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
    print('Recognized words: $lastWords');
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'WizGPT',
          style: TextStyle(
            color: Pallete.mainFontColor,
          ),
        ),
        leading: const Icon(Icons.menu),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Title image
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 4),
                      height: 100,
                      width: 100,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/images/wizgpt.png',
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Greeting bubble
                  Visibility(
                    visible: generatedImageUrl == null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      margin:
                          const EdgeInsets.symmetric(horizontal: 40).copyWith(
                        top: 30,
                      ),
                      decoration: BoxDecoration(
                        color: generatedContent == null
                            ? Colors.transparent
                            : Pallete.firstSuggestionBoxColor,
                        border: Border.all(
                          color: Pallete.borderColor,
                        ),
                        borderRadius: BorderRadius.circular(20).copyWith(
                          topLeft: Radius.zero,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          generatedContent == null
                              ? 'Hello, How may I be of Assisstance?'
                              : generatedContent!,
                          style: TextStyle(
                              color: Pallete.mainFontColor,
                              fontSize: generatedContent == null ? 20 : 18,
                              fontFamily: 'Cera Pro'),
                        ),
                      ),
                    ),
                  ),
                  // show generated image
                  if (generatedImageUrl != null)
                    ZoomIn(
                      child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(generatedImageUrl!))),
                    ),
                  // Features texts
                  Visibility(
                    visible:
                        generatedContent == null && generatedImageUrl == null,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.only(
                        top: 20,
                        left: 22,
                      ),
                      child: const Text(
                        'What I can do:',
                        style: TextStyle(
                          fontFamily: 'Cera Pro',
                          fontSize: 20,
                          color: Pallete.mainFontColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Features list
                  Visibility(
                    visible:
                        generatedContent == null && generatedImageUrl == null,
                    child: Column(
                      children: const [
                        FeatureBox(
                          color: Pallete.firstSuggestionBoxColor,
                          headerText: 'ChatGPT',
                          descriptionText:
                              'I can fetch your desired queries from chatGPT',
                        ),
                        FeatureBox(
                          color: Pallete.secondSuggestionBoxColor,
                          headerText: 'Dall-E',
                          descriptionText:
                              'I can fetch your desired image result from Dall-E',
                        ),
                        FeatureBox(
                          color: Pallete.thirdSuggestionBoxColor,
                          headerText: 'Smart Voice Prompt',
                          descriptionText:
                              'All you have to do is speak your desired query!',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ) //end
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 00,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Pallete.backgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                      child: Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Type your message here...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        filled: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                      onFieldSubmitted: (value) async {
                        if (_formKey.currentState!.validate()) {
                          final String enteredText = _textController.text;
                          if (enteredText.isNotEmpty) {
                            _textController.clear();
                            if (speechToText.isNotListening) {
                              final response = await openAIService
                                  .isArtPromptAPI(enteredText);
                              if (response.contains('https')) {
                                generatedImageUrl = response;
                                generatedContent = null;
                              } else {
                                generatedImageUrl = null;
                                generatedContent = response;
                                await systemSpeak(response);
                              }
                              setState(() {});
                            }
                          }
                        }
                      },
                    ),
                  )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipOval(
                      child: FloatingActionButton(
                        backgroundColor: Pallete.popColor,
                        onPressed: () async {
                          if (await speechToText.hasPermission &&
                              speechToText.isNotListening) {
                            await startListening();
                          } else if (speechToText.isListening) {
                            final speech =
                                await openAIService.isArtPromptAPI(lastWords);
                            if (speech.contains('https')) {
                              generatedImageUrl = speech;
                              generatedContent = null;
                              setState(() {});
                            } else {
                              generatedImageUrl = null;
                              generatedContent = speech;
                              setState(() {});
                              await systemSpeak(speech);
                            }
                            await stopListening();
                          } else {
                            initSpeechToText();
                          }
                        },
                        child: Icon(
                            speechToText.isListening ? Icons.stop : Icons.mic),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
