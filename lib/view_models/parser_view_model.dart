import 'dart:collection';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_whatsapp_chat_parser/data/data_source.dart';
import 'package:flutter_whatsapp_chat_parser/data/date_manager.dart';
import 'package:flutter_whatsapp_chat_parser/error/app_exceptions.dart';
import 'package:flutter_whatsapp_chat_parser/models/chat_message.dart';
import 'package:flutter_whatsapp_chat_parser/widgets/view_state_builder.dart';
import 'package:intl/intl.dart';

class ParserViewModel extends ChangeNotifier {
  final ParserDataSource parserDataSource;

  ViewState appState = ViewState.idle;
  bool _disposed = false;
  String? errorMessage;
  ParserViewModel._(this.parserDataSource);
  static final instance = ParserViewModel._(
      ParserDataSourceImplementation(dateManager: DateManager()));
  @override
  void dispose() {
    super.dispose();
    _disposed = true;
  }

  List<ChatMessage> _allMessages = <ChatMessage>[];
  final _allMessagesGrouped = <String, Iterable<ChatMessage>>{};
  UnmodifiableMapView<String, Iterable<ChatMessage>> get allMessages =>
      UnmodifiableMapView(_allMessagesGrouped);

  setState({ViewState state = ViewState.idle, String? error}) {
    this.appState = state;
    this.errorMessage = error;
    if (!_disposed) notifyListeners();
  }

  void _addToMessagesList(Iterable<ChatMessage> list) {
    _allMessages.addAll(list);

    _allMessagesGrouped.clear();
    final uniqueDateStrings =
        _allMessages.map((message) => DateFormat.yMMMd().format(message.time!));

    for (var dateString in uniqueDateStrings) {
      _allMessagesGrouped[dateString] = _allMessages.where(
        (message) => DateFormat.yMMMd().format(message.time!) == dateString,
      );
    }
  }

  parseInit() async {
    setState(state: ViewState.busy);

    try {
      final File? pickedFIle = await parserDataSource.pickFile();
      _allMessages.clear();
      if (pickedFIle != null) {
        List<ChatMessage>? messages;
        try {
          messages = await parserDataSource.parseFile(pickedFIle);
        } on TxtFileNotFoundException catch (e) {
          errorMessage = e.message;
          setState(state: ViewState.error);
        } on InvalidFileException catch (e) {
          errorMessage = e.message;
          setState(state: ViewState.error);
        } catch (e) {
          errorMessage = 'There was an error parsing file';
          setState(state: ViewState.error);
          log("EXCEPTION $e");
        }
        if (messages != null && messages.isNotEmpty)
          _addToMessagesList(messages);
        if (_allMessages.isNotEmpty) {
          _allMessages.sort((a, b) => a.time!.compareTo(b.time!));
          setState(state: ViewState.done);
        }
      } else
        setState(state: ViewState.idle);
    } catch (e) {
      setState(state: ViewState.error);
    }
  }
}
