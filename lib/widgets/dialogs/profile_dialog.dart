import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gossip_flutter/models/chat_user.dart';

import '../../main.dart';
import '../../screens/view_profile_screen.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});

  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.blue.shade50.withOpacity(1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: mq.width * 0.6,
        height: mq.height * 0.35,
        child: Stack(
          children: [
            //user profile picture
            Positioned(
              top: mq.height * 0.07,
              left: mq.width * 0.11,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .2),
                child: CachedNetworkImage(
                  width: mq.width * .55,
                  height: mq.width * .55,
                  fit: BoxFit.cover,
                  imageUrl: user.image,
                  errorWidget: (context, url, error) =>
                      const CircleAvatar(child: Icon(CupertinoIcons.person)),
                ),
              ),
            ),

            // user name
            Positioned(
              left: mq.width * 0.05,
              top: mq.height * 0.015,
              width: mq.width * 0.55,
              child: Text(
                user.name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            //info button
            Positioned(
              right: mq.width * 0.02,
              top: mq.height * 0.00,
              child: MaterialButton(
                onPressed: () {
                  //for hiding image dialog
                  Navigator.pop(context);

                  //move to view profile screen
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ViewProfileScreen(user: user)));
                },
                minWidth: 0,
                padding: const EdgeInsets.all(0),
                shape: const CircleBorder(),
                child: const Icon(Icons.info_outline,
                    color: Color.fromARGB(255, 14, 112, 193), size: 30),
              ),
            )
          ],
        ),
      ),
    );
  }
}
