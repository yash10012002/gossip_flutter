import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';

import 'package:gossip_flutter/api/apis.dart';

import 'package:gossip_flutter/helper/my_date_util.dart';
import 'package:gossip_flutter/models/message.dart';

import 'package:gossip_flutter/widgets/messagebottomsheet.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';

import '../main.dart';

import '../screens/globle.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});
  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
        onTap: () {
          FocusScope.of(context).unfocus();
          // if (_showEmoji) setState(() => _showEmoji = !_showEmoji);
        },
        onLongPress: () {
          FocusScope.of(context).unfocus();
          // WidgetsBinding.instance.addPostFrameCallback(
          //   (timeStamp) {

          //   },
          // );
          _showBottomsheet(isMe, context);
          // Future.delayed(Duration(seconds: 2), () {
          //   // if (!mounted)

          // });
        },
        child: isMe ? _blueMessage() : _whiteMessage());
  }

  // sender or another user message
  Widget _whiteMessage() {
    // update last read message if sender and receiver are different
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
      log("message are updated");
    }
    return widget.message.type == Type.text
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              // message content
              Flexible(
                child: Container(
                  padding: EdgeInsets.all(widget.message.type == Type.image
                      ? mq.width * .03
                      : mq.width * .04),
                  margin: EdgeInsets.symmetric(
                      horizontal: mq.width * .04, vertical: mq.height * .01),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.blueGrey),
                      //making borders curved
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20))),
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    children: [
                      Text(
                        widget.message.msg,
                        style: const TextStyle(
                            fontSize: 15, color: Colors.black87),
                        softWrap: true,
                      ),

                      //message time
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 2),
                        child: Text(
                          MyDateUtil.getFormattedTime(
                              context: context, time: widget.message.sent),
                          style: const TextStyle(
                              fontSize: 13, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: mq.width * 0.2,
              )
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.all(widget.message.type == Type.image
                          ? mq.width * .04
                          : mq.width * .04),
                      margin: EdgeInsets.symmetric(
                          horizontal: mq.width * .04,
                          vertical: mq.height * .01),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.blueGrey),
                          //making borders curved
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              bottomRight: Radius.circular(20))),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: InstaImageViewer(
                            child: CachedNetworkImage(
                              // width: mq.width * 0.4,
                              // height: mq.width * 0.4,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              // fit: BoxFit.cover,
                              imageUrl: widget.message.msg,
                              errorWidget: (context, url, error) => const Icon(
                                Icons.image,
                                size: 70,
                              ),
                            ),
                          )),
                    ),
                    Positioned(
                      bottom: 9.0,
                      right: 30,
                      child: Row(
                        children: [
                          Text(
                            MyDateUtil.getFormattedTime(
                                context: context, time: widget.message.sent),
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black),
                          ),
                          // //double tick blue icon for message read
                          // if (widget.message.read.isNotEmpty)
                          //   const Icon(Icons.done_all_rounded,
                          //       color: Colors.blue, size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: mq.width * 0.2,
              ),
            ],
          );
  }

  // out or user message
  Widget _blueMessage() {
    return
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     //message time
        //     Row(
        //       children: [
        //         //for adding some space
        //         SizedBox(width: mq.width * .04),

        //         //double tick blue icon for message read
        //         if (widget.message.read.isNotEmpty)
        //           const Icon(Icons.done_all_rounded, color: Colors.blue, size: 20),

        //         //for adding some space
        //         const SizedBox(width: 2),

        //         //sent time
        //         Text(
        //           MyDateUtil.getFormattedTime(
        //               context: context, time: widget.message.sent),
        //           style: const TextStyle(fontSize: 13, color: Colors.black54),
        //         ),
        //       ],
        //     ),

        //     //message content
        //     Flexible(
        //       child: Container(
        //         padding: EdgeInsets.all(widget.message.type == Type.image
        //             ? mq.width * .03
        //             : mq.width * .04),
        //         margin: EdgeInsets.symmetric(
        //             horizontal: mq.width * .04, vertical: mq.height * .01),
        //         decoration: BoxDecoration(
        //             color: const Color.fromARGB(255, 218, 255, 176),
        //             border: Border.all(color: Colors.lightGreen),
        //             //making borders curved
        //             borderRadius: const BorderRadius.only(
        //                 topLeft: Radius.circular(30),
        //                 topRight: Radius.circular(30),
        //                 bottomLeft: Radius.circular(30))),
        //         child: widget.message.type == Type.text
        //             ?
        //             //show text
        //             Text(
        //                 widget.message.msg,
        //                 style: const TextStyle(fontSize: 15, color: Colors.black87),
        //               )
        //             :
        //             //show image
        //             ClipRRect(
        //                 borderRadius: BorderRadius.circular(15),
        //                 child: CachedNetworkImage(
        //                   imageUrl: widget.message.msg,
        //                   placeholder: (context, url) => const Padding(
        //                     padding: EdgeInsets.all(8.0),
        //                     child: CircularProgressIndicator(strokeWidth: 2),
        //                   ),
        //                   errorWidget: (context, url, error) =>
        //                       const Icon(Icons.image, size: 70),
        //                 ),
        //               ),
        //       ),
        //     ),
        //   ],
        // );
        widget.message.type == Type.text
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: mq.width * 0.2,
                  ),
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.all(widget.message.type == Type.image
                          ? mq.width * .03
                          : mq.width * .04),
                      margin: EdgeInsets.symmetric(
                          horizontal: mq.width * .04,
                          vertical: mq.height * .01),
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 221, 245, 255),
                          border: Border.all(
                              color: const Color.fromARGB(255, 14, 112, 193)),
                          //making borders curved
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              bottomLeft: Radius.circular(20))),
                      child: Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 3.0,
                        children: <Widget>[
                          widget.message.type == Type.text
                              ? Text(
                                  widget.message.msg,
                                  style: const TextStyle(
                                      fontSize: 15, color: Colors.black87),
                                  softWrap: true,
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    width: mq.width * 0.4,
                                    height: mq.width * 0.4,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    fit: BoxFit.cover,
                                    imageUrl: widget.message.msg,
                                    errorWidget: (context, url, error) =>
                                        const Icon(
                                      Icons.image,
                                      size: 70,
                                    ),
                                  ),
                                ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0, top: 2),
                            child: Text(
                              MyDateUtil.getFormattedTime(
                                  context: context, time: widget.message.sent),
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black54),
                            ),
                          ),

                          //double tick blue icon for message read
                          if (widget.message.read.isNotEmpty)
                            const Icon(Icons.done_all_rounded,
                                color: Colors.blue, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: mq.width * 0.2,
                  ),
                  Flexible(
                    child: Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.all(
                              widget.message.type == Type.image
                                  ? mq.width * .04
                                  : mq.width * .04),
                          margin: EdgeInsets.symmetric(
                              horizontal: mq.width * .04,
                              vertical: mq.height * .01),
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 221, 245, 255),
                              border: Border.all(
                                  color:
                                      const Color.fromARGB(255, 14, 112, 193)),
                              //making borders curved
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                  bottomLeft: Radius.circular(20))),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: InstaImageViewer(
                                child: CachedNetworkImage(
                                  // width: mq.width * 0.4,
                                  // height: mq.width * 0.4,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  // fit: BoxFit.cover,
                                  imageUrl: widget.message.msg,
                                  errorWidget: (context, url, error) =>
                                      const Icon(
                                    Icons.image,
                                    size: 70,
                                  ),
                                ),
                              )),
                        ),
                        Positioned(
                          bottom: 7.0,
                          right: 20,
                          child: Row(
                            children: [
                              Text(
                                MyDateUtil.getFormattedTime(
                                    context: context,
                                    time: widget.message.sent),
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.black),
                              ),
                              //double tick blue icon for message read
                              if (widget.message.read.isNotEmpty)
                                const Icon(Icons.done_all_rounded,
                                    color: Colors.blue, size: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              );
  }

  // bottom sheet for modifying message details
  void _showBottomsheet(bool isMe, BuildContext ctx) {
    showModalBottomSheet(
      context: GlobalVariable.appContext,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      builder: (_) {
        return MessageBottomSheet(
          message: widget.message,
        );
      },
    );
  }
}
