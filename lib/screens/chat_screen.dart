import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gossip_flutter/helper/my_date_util.dart';
import 'package:gossip_flutter/models/chat_user.dart';
import 'package:gossip_flutter/models/message.dart';
import 'package:gossip_flutter/screens/view_profile_screen.dart';
import 'package:gossip_flutter/widgets/message_card.dart';
import 'package:image_picker/image_picker.dart';

import '../api/apis.dart';
import '../main.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // for storing all messages;
  List<Message> _list = [];
  // for handling message text changes
  final _textController = TextEditingController();
  // showEmoji -- for storing value of showing or hiding emoji
  // isUploading -- for checking if image is uploading or not?
  bool _showEmoji = false, _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        if (_showEmoji) setState(() => _showEmoji = !_showEmoji);
      },
      // if emoji are shown & back button iss pressed then hide emojis
      // or else simple close current screen on back button click
      child: WillPopScope(
        onWillPop: () {
          FocusScope.of(context).unfocus();
          if (_showEmoji) {
            setState(() {
              _showEmoji = !_showEmoji;
            });
            return Future.value(false); // do nothing
          } else {
            return Future.value(true); // preform normal back button task
          }
        },
        child: Scaffold(
          appBar: AppBar(
            systemOverlayStyle: const SystemUiOverlayStyle(
                // statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light),
            backgroundColor: const Color.fromARGB(255, 14, 112, 193),
            automaticallyImplyLeading: false,
            flexibleSpace: _appBar(),
          ),
          backgroundColor: Colors.indigo.shade50,
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: APIs.getAllMessages(widget.user),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      // if data is loading
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const SizedBox();
                      // return const Center(child: CircularProgressIndicator());
                      // if some or all data  is loaded then show it
                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs;
                        _list = data
                                ?.map((e) => Message.fromJson(e.data()))
                                .toList() ??
                            [];

                        if (_list.isNotEmpty) {
                          return ListView.builder(
                              reverse: true,
                              padding: EdgeInsets.only(top: mq.height * 0.01),
                              physics: const BouncingScrollPhysics(),
                              itemCount: _list.length,
                              itemBuilder: (context, index) {
                                return MessageCard(message: _list[index]);
                                // Text("Message: ${_list[index]}");
                              });
                        } else {
                          return const Center(
                            child: Text(
                              "Say Hello!! 👋",
                              style: TextStyle(fontSize: 20),
                            ),
                          );
                        }
                    }
                  },
                ),
              ),
              // progress indicator for showing uploading
              if (_isUploading)
                const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )),
              _chatInput(),
              if (_showEmoji)
                SizedBox(
                  height: mq.height * 0.35,
                  child: EmojiPicker(
                    textEditingController: _textController,
                    config: Config(
                      bgColor: Colors.indigo.shade50,
                      columns: 8,
                      emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  // app bar widget
  Widget _appBar() {
    return SafeArea(
      child: InkWell(
          onTap: () {
            FocusScope.of(context).unfocus();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ViewProfileScreen(user: widget.user)));
          },
          child: StreamBuilder(
            stream: APIs.getUserInfo(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

              return Row(
                children: [
                  // back button
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * 0.03),
                    // backgroundColor: Colors.amber,
                    child: CachedNetworkImage(
                      width: mq.height * 0.05,
                      height: mq.height * 0.05,
                      fit: BoxFit.cover,
                      imageUrl:
                          list.isNotEmpty ? list[0].image : widget.user.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(CupertinoIcons.person)),
                    ),
                  ),
                  // for adding some space
                  const SizedBox(
                    width: 12,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // user name
                      Text(
                        list.isNotEmpty ? list[0].name : widget.user.name,
                        style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      ),
                      // for adding some space
                      const SizedBox(
                        height: 3,
                      ),
                      // last seen time of user
                      Text(
                        list.isNotEmpty
                            ? list[0].isOnline
                                ? "Online"
                                : MyDateUtil.getLastActiveTime(
                                    context: context,
                                    lastActive: list[0].lastActive)
                            : MyDateUtil.getLastActiveTime(
                                context: context,
                                lastActive: widget.user.lastActive),
                        style: TextStyle(fontSize: 13, color: Colors.white70),
                      )
                    ],
                  )
                ],
              );
            },
          )),
    );
  }

  // bottom chat input field
  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * 0.01, horizontal: mq.width * 0.025),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // input field & button
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // emoji button
                  IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() => _showEmoji = !_showEmoji);
                    },
                    icon: const Icon(
                      Icons.emoji_emotions_outlined,
                      color: Colors.blueGrey,
                    ),
                  ),

                  Expanded(
                    child: TextField(
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      onTap: () {
                        if (_showEmoji)
                          setState(() => _showEmoji = !_showEmoji);
                      },
                      decoration: const InputDecoration(
                          hintText: 'Type Something...',
                          hintStyle: TextStyle(color: Colors.blueGrey),
                          border: InputBorder.none),
                    ),
                  ),

                  // pick image from gallery button
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();

                      // Picking multiple images
                      final List<XFile> images =
                          await picker.pickMultiImage(imageQuality: 70);
                      // uploading & sending image one by one
                      for (var i in images) {
                        log("Image Path: ${i.path}");
                        setState(() => _isUploading = true);
                        await APIs.sendChatImage(widget.user, File(i.path));
                        setState(() => _isUploading = false);
                      }
                    },
                    icon: const Icon(
                      Icons.image,
                      color: Colors.blueGrey,
                      size: 26,
                    ),
                  ),

                  // take image from camera button
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();

                      // Pick an image
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 70);
                      if (image != null) {
                        log("Image Path: ${image.path}");
                        setState(() => _isUploading = true);
                        await APIs.sendChatImage(widget.user, File(image.path));
                        setState(() => _isUploading = false);
                      }
                    },
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.blueGrey,
                      size: 26,
                    ),
                  ),
                  SizedBox(
                    width: mq.width * 0.01,
                  )
                ],
              ),
            ),
          ),
          // send message button
          MaterialButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                if (_list.isEmpty) {
                  //on first message (add user to my_user collection of chat user)
                  APIs.sendFirstMessage(
                      widget.user, _textController.text, Type.text);
                } else {
                  //simply send message
                  APIs.sendMessage(
                      widget.user, _textController.text, Type.text);
                }
                _textController.text = '';
              }
            },
            minWidth: 0,
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: const CircleBorder(),
            color: const Color.fromARGB(255, 14, 112, 193),
            child: const Icon(
              Icons.send,
              color: Colors.white,
              size: 30,
            ),
          )
        ],
      ),
    );
  }
}
