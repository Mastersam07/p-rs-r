import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_whatsapp_chat_parser/data/constants.dart';
import 'package:flutter_whatsapp_chat_parser/data/date_manager.dart';

import '../models/chat_message.dart';

abstract class ParserDataSource {
  Future<File?> pickFile();
  Future<List<ChatMessage>> parseFile(File file);
}

class ParserDataSourceImplementation implements ParserDataSource {
  final DateManager dateManager;

  ParserDataSourceImplementation({required this.dateManager});
  @override
  Future<File?> pickFile() async {
    final pickerResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'zip'],
    );
    if (pickerResult != null) {
      return File(pickerResult.files.single.path!);
    } else {
      return null;
    }
  }

  @override
  Future<List<ChatMessage>> parseFile(File file) async {
    File? txtFile;
    List<ChatMessage> parsedMessages = [];
    //Read each line of the file and join detached lines
    List<String> allJoinedMessages = [];
    txtFile = file;
    String? currentMessage;
    await txtFile
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .forEach((messageLine) {
      if (AppConstants.regexParser.hasMatch(messageLine.trim())) {
        if (currentMessage != null) {
          allJoinedMessages.add(currentMessage!);
        }
        currentMessage = messageLine;
      } else if (AppConstants.regexParserSystem.hasMatch(messageLine)) {
        if (currentMessage != null) {
          allJoinedMessages.add(currentMessage!);
        }
        currentMessage = messageLine;
      } else {
        if (currentMessage != null) {
          currentMessage = currentMessage! + '\n' + messageLine;
        }
      }
    });
    // print("ALL JOINED MESSAGES");
    //log(allJoinedMessages.toString());
    dateManager.checkDateFormat(allJoinedMessages);
    allJoinedMessages.forEach((messageLine) {
      if (AppConstants.regexParser.hasMatch(messageLine.trim())) {
        parsedMessages.add(parseUserMessage(
          messageLine.trim(),
        ));
      } else if (AppConstants.regexParserSystem.hasMatch(messageLine)) {
        parsedMessages.add(
          parseSystemMessages(messageLine.trim()),
        );
      }
    });
    return parsedMessages;
  }

  ChatMessage parseUserMessage(String message) {
    RegExpMatch chatMatch = AppConstants.regexParser.allMatches(message).first;

    final listOfSplitString = chatMatch
        .groups(List<int>.generate(chatMatch.groupCount, (index) => index));
    final chatMessage = message;

    return ChatMessage(
      time: dateManager.normalizeDate(listOfSplitString),
      message: chatMessage,
      sender: MessageSender.user,
      userName: listOfSplitString[4]?.trim(),
    );
  }

  ChatMessage parseSystemMessages(String message) {
    RegExpMatch chatMatch =
        AppConstants.regexParserSystem.allMatches(message).first;
    final List<String?>? listOfSplitString = chatMatch
        .groups(List<int>.generate(chatMatch.groupCount, (index) => index));
    final chatMessage = message;
    print("NORMALIZED DATE ${dateManager.normalizeDate(listOfSplitString!)}");
    print("NORMALIZED YEAR ${dateManager.normalizeDate(listOfSplitString)}");

    return ChatMessage(
      message: chatMessage,
      time: dateManager.normalizeDate(listOfSplitString),
      sender: MessageSender.system,
    );
  }

  Future<List<File>> unarchiveZipFile(File zipFile) async {
    List<File> extractedFiles = [];
    final zipDecoder = ZipDecoder();
    final zipBytes = await zipFile.readAsBytes();
    final archive = zipDecoder.decodeBytes(zipBytes);
    for (var file in archive) {
      if (file.isFile) extractedFiles.add(File.fromRawPath(file.content));
    }

    return extractedFiles;
  }
}
