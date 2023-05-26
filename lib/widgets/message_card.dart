import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_bubbles/bubbles/bubble_normal_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:gossip_flutter/api/apis.dart';
import 'package:gossip_flutter/helper/dialogs.dart';
import 'package:gossip_flutter/helper/my_date_util.dart';
import 'package:gossip_flutter/models/message.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';

import '../main.dart';

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
        onTap: () => FocusScope.of(context).unfocus(),
        onLongPress: () {
          _showBottomsheet(isMe);
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
  void _showBottomsheet(bool isMe) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          children: [
            // black divider
            Container(
              height: 4,
              margin: EdgeInsets.symmetric(
                  vertical: mq.height * 0.015, horizontal: mq.width * 0.4),
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(10)),
            ),

            widget.message.type == Type.text
                ?
                // Copy option
                _OptionItem(
                    icon: const Icon(
                      Icons.copy_all_rounded,
                      color: Color.fromARGB(255, 14, 112, 193),
                    ),
                    name: "Copy Text",
                    onTap: () async {
                      await Clipboard.setData(
                              ClipboardData(text: widget.message.msg))
                          .then((value) {
                        // for hiding bottom sheet
                        Navigator.pop(context);

                        Dialogs.showSnackbar(context, "Text Copied");
                      });
                    },
                  )
                : _OptionItem(
                    icon: const Icon(
                      Icons.download_rounded,
                      color: Color.fromARGB(255, 14, 112, 193),
                    ),
                    name: "Save image",
                    onTap: () async {
                      try {
                        log("Image Url: ${widget.message.msg}");
                        await GallerySaver.saveImage(widget.message.msg,
                                albumName: "Gossip")
                            .then((success) {
                          // for hiding bottom sheet
                          Navigator.pop(context);
                          if (success != null && success) {
                            Dialogs.showSnackbar(
                                context, "Image Successfully Saved!");
                          }
                        });
                      } catch (e) {
                        log("ErrorwhilesavingImage:$e");
                      }
                    },
                  ),
            if (isMe)
              Divider(
                color: Colors.black54,
                endIndent: mq.width * .025,
                indent: mq.width * .025,
              ),
            // edit option
            if (widget.message.type == Type.text && isMe)
              _OptionItem(
                icon: const Icon(
                  Icons.edit,
                  color: Colors.blue,
                ),
                name: "Edit Message",
                onTap: () {
                  // for hiding bottom sheet
                  Navigator.pop(context);
                  _showMessageUpdateDialog();
                },
              ),
            // delete option
            if (isMe)
              _OptionItem(
                icon: const Icon(
                  Icons.delete_forever,
                  color: Colors.red,
                ),
                name: "Delete Message",
                onTap: () {
                  APIs.deleteMessage(widget.message).then((value) {
                    // for hiding bottom sheet
                    Navigator.pop(context);
                  });
                },
              ),
            Divider(
              color: Colors.black54,
              endIndent: mq.width * .025,
              indent: mq.width * .025,
            ),
            // sent time
            _OptionItem(
              icon: const Icon(
                Icons.remove_red_eye,
                color: Colors.blue,
              ),
              name:
                  "Sent At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}",
              onTap: () {},
            ),
            // read time
            _OptionItem(
              icon: const Icon(
                Icons.remove_red_eye,
                color: Colors.green,
              ),
              name: widget.message.read.isEmpty
                  ? "Read At: Not seen yet"
                  : "Read At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}",
              onTap: () {},
            ),
          ],
        );
      },
    );
  }

  void _showMessageUpdateDialog() {
    String updatedMsg = widget.message.msg;

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: const [
                  Icon(
                    Icons.message,
                    color: Colors.blue,
                    size: 28,
                  ),
                  Text(" Update Message")
                ],
              ),
              content: TextFormField(
                initialValue: updatedMsg,
                maxLines: null,
                onChanged: (value) => updatedMsg = value,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
              ),
              actions: [
                MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    )),
                MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                      APIs.updateMessage(widget.message, updatedMsg);
                    },
                    child: const Text(
                      "Update",
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    )),
              ],
            ));
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: EdgeInsets.only(
            left: mq.width * .05,
            top: mq.height * .015,
            bottom: mq.height * .015),
        child: Row(
          children: [
            icon,
            Text(
              "   $name",
              style: const TextStyle(
                  fontSize: 16, color: Colors.black54, letterSpacing: 0.5),
            )
          ],
        ),
      ),
    );
  }
}
