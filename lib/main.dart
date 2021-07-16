import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_chat_parser/data/date_manager.dart';
import 'package:flutter_whatsapp_chat_parser/models/chat_message.dart';

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
        primarySwatch: Colors.blue,
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
  bool fileOpen = false;
  List<ChatMessage> allMessages = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? ''),
      ),
      body: Center(
        child: fileOpen
            ? Scrollbar(
                thickness: 15,
                child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    itemBuilder: (context, index) => Card(
                        color: allMessages[index].sender == MessageSender.system
                            ? Colors.green
                            : Colors.white,
                        child: Column(
                          crossAxisAlignment:
                              allMessages[index].sender == MessageSender.system
                                  ? CrossAxisAlignment.center
                                  : CrossAxisAlignment.start,
                          children: [
                            Text(allMessages[index].iNTLNormalizedTime),
                            Text(allMessages[index].userName ?? ''),
                            Text(allMessages[index].message!),
                          ],
                        )),
                    separatorBuilder: (context, index) => SizedBox(
                          height: 20,
                        ),
                    itemCount: allMessages.length),
              )
            : Text("Click the + button to add txt file"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final parserFile =
              ParserDataSourceImplementation(dateManager: DateManager());
          final File? pickedFIle = await parserFile.pickFile();
          allMessages.clear();
          if (pickedFIle != null) {
            final List<ChatMessage>? messages =
                await parserFile.parseFile(pickedFIle);
            if (messages != null) allMessages.addAll(messages);
            setState(() {
              if (allMessages.isNotEmpty) {
                allMessages.sort((a, b) => a.time!.compareTo(b.time!));
                fileOpen = true;
              }
            });
          }
        },
        tooltip: 'Add txt or zip file',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
