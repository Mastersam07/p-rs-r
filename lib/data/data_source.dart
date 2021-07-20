import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_whatsapp_chat_parser/error/app_exceptions.dart';
import 'package:flutter_whatsapp_chat_parser/utils/utilities.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../models/chat_message.dart';
import 'constants.dart';
import 'date_manager.dart';

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
    List<File>? attachments;
    List<ChatMessage> parsedMessages = [];
    //Read each line of the file and join detached lines
    List<String> allJoinedMessages = [];
    if (isZipFile(file.path)) {
      List<File> allZipFiles = await unarchiveZipFile(file);
      print(
          "TXT FILE AVAILABLE ${allZipFiles.any((extract) => isTxtFile(extract.path))}");
      if (allZipFiles.any((extract) => isTxtFile(extract.path))) {
        txtFile = allZipFiles.firstWhere((element) => isTxtFile(element.path));
        attachments =
            allZipFiles.where((element) => !isTxtFile(element.path)).toList();
      }
    } else if (isTxtFile(file.path)) {
      txtFile = file;
    } else {
      throw InvalidFileException();
    }

    String? currentMessage;
    if (txtFile != null) {
      txtFile.readAsLinesSync().forEach((messageLine) {
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
      dateManager.checkDateFormat(allJoinedMessages);
      allJoinedMessages.forEach((messageLine) {
        if (AppConstants.regexParser.hasMatch(messageLine.trim())) {
          parsedMessages.add(parseUserMessage(
            messageLine.trim(),
            attachments: attachments,
          ));
        } else if (AppConstants.regexParserSystem.hasMatch(messageLine)) {
          parsedMessages.add(
            parseSystemMessages(messageLine.trim()),
          );
        }
      });
      return parsedMessages;
    } else {
      throw TxtFileNotFoundException();
    }
  }

  ChatMessage parseUserMessage(String message, {List<File>? attachments}) {
    RegExpMatch chatMatch = AppConstants.regexParser.allMatches(message).first;
    File? attachedFile;
    final listOfSplitString = chatMatch
        .groups(List<int>.generate(chatMatch.groupCount, (index) => index));
    String chatMessage =
        normalizeMessage(message, listOfSplitString.last!, null);
    if (attachments != null) {
      if (AppConstants.regexAttachment.hasMatch(message)) {
        RegExpMatch attachmentMatch =
            AppConstants.regexAttachment.allMatches(message).first;
        final attachmentMatchList = attachmentMatch.groups(
            List<int>.generate(attachmentMatch.groupCount, (index) => index));
        final String? attachmentName = attachmentMatchList.last?.trim();
        if (attachmentName != null) {
          if (attachments
              .any((element) => basename(element.path) == attachmentName)) {
            attachedFile = attachments.firstWhere(
                (element) => basename(element.path) == attachmentName);
            chatMessage = chatMessage.replaceAll(
                '${attachmentMatchList.first?.trim()}', '');
          }
        }
      }
    }
    return ChatMessage(
      time: dateManager.normalizeDate(listOfSplitString),
      message: chatMessage.trim(),
      sender: MessageSender.user,
      userName: listOfSplitString[4]?.trim(),
      attachedFile: attachedFile,
      attachmentType:
          attachedFile != null ? determineAttachmentType(attachedFile) : null,
    );
  }

  ChatMessage parseSystemMessages(String message) {
    RegExpMatch chatMatch =
        AppConstants.regexParserSystem.allMatches(message).first;
    final List<String?>? listOfSplitString = chatMatch
        .groups(List<int>.generate(chatMatch.groupCount, (index) => index));
    String chatMessage = normalizeMessage(
        message, listOfSplitString!.last, listOfSplitString[2]);
    if (chatMessage.startsWith('-') || chatMessage.startsWith(' ')) {
      chatMessage = chatMessage.substring(2);
    }
    return ChatMessage(
      message: chatMessage.trim(),
      time: dateManager.normalizeDate(listOfSplitString),
      sender: MessageSender.system,
    );
  }

  Future<List<File>> unarchiveZipFile(File zipFile) async {
    List<File> extractedFiles = [];
    final _dir = await getTemporaryDirectory();
    final zipDecoder = ZipDecoder();
    final zipBytes = await zipFile.readAsBytes();
    final archive = zipDecoder.decodeBytes(zipBytes);
    for (var file in archive) {
      var fileName = '${_dir.path}/${file.name}';
      if (file.isFile) {
        var outFile = File(fileName);
        outFile = await outFile.create(recursive: true);
        final extractedFile = await outFile.writeAsBytes(file.content);
        extractedFiles.add(extractedFile);
      }
    }
    return extractedFiles;
  }

  String normalizeMessage(
    String message,
    String? author,
    String? messageTime,
  ) {
    if (author != null) {
      final chatMessageIndex = message.indexOf(author);
      return message.substring(chatMessageIndex + author.length + 1).trim();
    } else if (messageTime != null) {
      final chatMessageIndex = message.indexOf(messageTime);
      return message
          .substring(chatMessageIndex + messageTime.length + 1)
          .trim();
    } else {
      return message;
    }
  }
}
