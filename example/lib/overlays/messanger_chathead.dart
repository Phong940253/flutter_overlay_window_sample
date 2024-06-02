import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class MessangerChatHead extends StatefulWidget {
  const MessangerChatHead({Key? key}) : super(key: key);

  @override
  State<MessangerChatHead> createState() => _MessangerChatHeadState();
}

class _MessangerChatHeadState extends State<MessangerChatHead> {
  Color color = const Color(0xFFFFFFFF);
  BoxShape _currentShape = BoxShape.circle;
  static const String _kPortNameOverlay = 'OVERLAY';
  static const String _kPortNameHome = 'UI';
  final _receivePort = ReceivePort();
  SendPort? homePort;
  String? messageFromOverlay;

  @override
  void initState() {
    super.initState();
    if (homePort != null) return;
    final res = IsolateNameServer.registerPortWithName(
      _receivePort.sendPort,
      _kPortNameOverlay,
    );
    log("$res : HOME");
    _receivePort.listen((message) async {
      log("message from UI: $message");
      setState(() {
        messageFromOverlay = '$message';
      });
      // homePort?.send('expand');
      await FlutterOverlayWindow.resizeOverlay(
        200,
        (MediaQuery.of(context).size.height).toInt(),
        true,
      );

      // delay 3 seconds
      await Future.delayed(const Duration(seconds: 3));
      log('Try to dismiss');
      await FlutterOverlayWindow.resizeOverlay(
        80,
        (MediaQuery.of(context).size.height).toInt(),
        true,
      );
      setState(() {
        messageFromOverlay = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 0.0,
      child: GestureDetector(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
              // shape: _currentShape,
              ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    //button close
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                          child: Image.asset(
                            'assets/icons/robot.png',
                            width: 50.0,
                            height: 50.0,
                          ),
                        ),
                        Positioned(
                          right: 30,
                          top: -13,
                          child: IconButton(
                            onPressed: () async {
                              log('Try to close');
                              await FlutterOverlayWindow.closeOverlay().then(
                                  (value) => log('STOPPED: alue: $value'));
                            },
                            icon: const Icon(Icons.cancel, color: Colors.red),
                          ),
                        ),
                      ],
                    ),

                    // message shape
                    messageFromOverlay == null
                        ? const SizedBox.shrink()
                        : Container(
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              color: color,
                              border: Border.all(
                                color: Colors.black,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                              shape: BoxShape.rectangle,
                            ),
                            child: Text(
                              messageFromOverlay!,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20.0,
                              ),
                            ),
                          )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
