import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:gossip_flutter/screens/globle.dart';

import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../helper/my_date_util.dart';
import '../main.dart';
import '../models/message.dart';

class MessageBottomSheet extends StatelessWidget {
  final Message message;
  const MessageBottomSheet({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == message.fromId;
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

        message.type == Type.text
            ?
            // Copy option
            _OptionItem(
                icon: const Icon(
                  Icons.copy_all_rounded,
                  color: Color.fromARGB(255, 14, 112, 193),
                ),
                name: "Copy Text",
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: message.msg))
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
                    log("Image Url: ${message.msg}");
                    await GallerySaver.saveImage(message.msg,
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
        if (message.type == Type.text && isMe)
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
            APIs.deleteMessage(message).then((value) {
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
              "Sent At: ${MyDateUtil.getMessageTime(context: context, time: message.sent)}",
          onTap: () {},
        ),
        // read time
        _OptionItem(
          icon: const Icon(
            Icons.remove_red_eye,
            color: Colors.green,
          ),
          name: message.read.isEmpty
              ? "Read At: Not seen yet"
              : "Read At: ${MyDateUtil.getMessageTime(context: context, time: message.read)}",
          onTap: () {},
        ),
      ],
    );
  }

  void _showMessageUpdateDialog() {
    String updatedMsg = message.msg;

    showDialog(
        context: GlobalVariable.appContext,
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
                      Navigator.pop(GlobalVariable.appContext);
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    )),
                MaterialButton(
                    onPressed: () {
                      Navigator.pop(GlobalVariable.appContext);
                      APIs.updateMessage(message, updatedMsg);
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
