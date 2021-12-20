import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

enum ViewState { busy, idle, error, noInternet, done }

class ViewStateBuilder extends StatelessWidget {
  final ViewState state;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? noConnectionWidget;
  final Function()? retryCallback;
  final Widget initialWidget;
  final Widget? successWidget;
  // final bool allowNullState;
  final bool ignoreBuildForError;
  const ViewStateBuilder({
    Key? key,
    required this.state,
    this.loadingWidget,
    this.errorWidget,
    this.noConnectionWidget,
    this.retryCallback,
    // this.allowNullState = true,
    this.ignoreBuildForError = true,
    required this.initialWidget,
    this.successWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //if (state == null && allowNullState) return initialWidget ?? successWidget;
    switch (state) {
      case ViewState.done:
        return successWidget ?? initialWidget;

      case ViewState.busy:
        return loadingWidget ??
            //const AppLoadingIndicator();
            Stack(
              alignment: Alignment.center,
              children: [
                initialWidget,
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.3),
                ),
                CircularProgressIndicator(),
              ],
            );
      case ViewState.idle:
        return initialWidget;

      case ViewState.error:
        return ignoreBuildForError
            ? initialWidget
            : Center(
                child: errorWidget ??
                    //todo: edit base error widget
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: 'An error occured. ',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                          ),
                          children: retryCallback == null
                              ? null
                              : [
                                  TextSpan(
                                    text: 'Retry',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.redAccent,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = retryCallback,
                                  )
                                ],
                        ),
                      ),
                    ),
              );

      case ViewState.noInternet:
        return ignoreBuildForError
            ? initialWidget
            : noConnectionWidget ??
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'Could not connect. ',
                    style: const TextStyle(
                      //:todo edit base no internet widget
                      color: Colors.red,
                    ),
                    children: retryCallback == null
                        ? null
                        : [
                            TextSpan(
                              text: 'Retry',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = retryCallback,
                            )
                          ],
                  ),
                );

      default:
        return const SizedBox.shrink();
    }
  }
}
