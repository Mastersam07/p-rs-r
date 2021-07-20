import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_chat_parser/data/date_manager.dart';
import 'package:flutter_whatsapp_chat_parser/error/app_exceptions.dart';
import 'package:flutter_whatsapp_chat_parser/models/chat_message.dart';
import 'package:flutter_whatsapp_chat_parser/widgets/chat_bubble.dart';

import 'data/data_source.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter WhatsApp Chat Parser',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: MyHomePage(
        title: 'WhatsApp chat parser',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? errorMessage;
  bool fileOpen = false;
  bool loading = false;
  List<ChatMessage> allMessages = [];
  List<MessageBubble> buildMessages(List<ChatMessage> allMessages) {
    List<MessageBubble> allChatBubbles = [];
    //HANDLE FIRST WHERE
    if (allMessages.isNotEmpty) {
      String firstAuthor = allMessages
          .firstWhere((element) => element.sender == MessageSender.user)
          .userName!;
      String? cacheAuthor;
      allMessages.forEach((chatMessage) {
        if (cacheAuthor != chatMessage.userName) {
          cacheAuthor = chatMessage.userName;
          allChatBubbles.add(MessageBubble(
            message: chatMessage,
            isRight: firstAuthor == chatMessage.userName,
            showAuthor: true,
          ));
        } else {
          allChatBubbles.add(MessageBubble(
            message: chatMessage,
            isRight: firstAuthor == chatMessage.userName,
            showAuthor: false,
          ));
        }
      });
      return allChatBubbles;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[900],
      appBar: AppBar(
        title: Text(widget.title ?? ''),
      ),
      body: loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: Center(
                child: fileOpen
                    ? ListView(
                        //crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: buildMessages(allMessages),
                      )
                    : Text(
                        errorMessage ??
                            "Click the + button to add txt or zip file",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setState(() {
            loading = true;
          });
          final parserFile =
              ParserDataSourceImplementation(dateManager: DateManager());
          final File? pickedFIle = await parserFile.pickFile();
          allMessages.clear();
          if (pickedFIle != null) {
            List<ChatMessage>? messages;
            try {
              messages = await parserFile.parseFile(pickedFIle);
            } on TxtFileNotFoundException catch (e) {
              errorMessage = e.message;
            } on InvalidFileException catch (e) {
              errorMessage = e.message;
            } catch (e) {
              errorMessage = 'There was an error parsing file';
              log("EXCEPTION $e");
            }
            if (messages != null && messages.isNotEmpty)
              allMessages.addAll(messages);
            setState(() {
              if (allMessages.isNotEmpty) {
                allMessages.sort((a, b) => a.time!.compareTo(b.time!));
                fileOpen = true;
              }
            });
          }
          setState(() {
            loading = false;
          });
        },
        tooltip: 'Add txt or zip file',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
