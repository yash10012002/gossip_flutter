import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gossip_flutter/api/apis.dart';
import 'package:gossip_flutter/helper/dialogs.dart';
import 'package:gossip_flutter/main.dart';
import 'package:gossip_flutter/models/chat_user.dart';
import 'package:gossip_flutter/screens/auth/login_screen.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formkey = GlobalKey<FormState>();
  String? _image;
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return GestureDetector(
      // for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
            title: const Text(" Your Profile"),
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(
              bottom: 10,
            ),
            child: FloatingActionButton.extended(
              backgroundColor: Colors.red.shade400,
              onPressed: () async {
                // for showing progress dialog
                Dialogs.showProgressBar(context);

                await APIs.updateActiveStatus(false);
                // sign out from app
                await APIs.auth.signOut().then((value) async {
                  await GoogleSignIn().signOut().then((value) {
                    // for hiding progress dialog
                    Navigator.pop(context);

                    // for moving to home screen
                    Navigator.pop(context);

                    APIs.auth = FirebaseAuth.instance;

                    // replacing home screen with login screen
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()));
                  });
                });
              },
              icon: const Icon(
                Icons.logout,
              ),
              label: const Text(
                "Logout",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          body: Form(
            key: _formkey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.width * 0.04),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // to add some space
                    SizedBox(
                      width: mq.width,
                      height: mq.height * 0.04,
                    ),
                    Stack(
                      children: [
                        // profile picture
                        _image != null
                            ? ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * 0.25),
                                // backgroundColor: Colors.amber,
                                child: Image.file(
                                  File(_image!),
                                  width: mq.width * 0.4,
                                  height: mq.width * 0.4,
                                  fit: BoxFit.cover,
                                ),
                              )
                            :
                            // image from server
                            ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * 0.25),
                                // backgroundColor: Colors.amber,
                                child: CachedNetworkImage(
                                  width: mq.width * 0.4,
                                  height: mq.width * 0.4,
                                  fit: BoxFit.cover,
                                  imageUrl: widget.user.image,
                                  errorWidget: (context, url, error) =>
                                      const CircleAvatar(
                                          child: Icon(CupertinoIcons.person)),
                                ),
                              ),
                        //edit image button
                        Positioned(
                          bottom: -5,
                          right: -10,
                          child: MaterialButton(
                            elevation: 0.5,
                            onPressed: () {
                              _showBottomSheet();
                            },
                            shape: const CircleBorder(),
                            color: Colors.white,
                            child: const Icon(Icons.edit, color: Colors.blue),
                          ),
                        )
                      ],
                    ),
                    // to add some space
                    SizedBox(
                      height: mq.height * 0.025,
                    ),
                    Text(
                      widget.user.email,
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                    SizedBox(
                      height: mq.height * 0.05,
                    ),
                    TextFormField(
                      initialValue: widget.user.name,
                      onSaved: (val) => APIs.me.name = val ?? "",
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : "Required field",
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Colors.blue,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: "eg. yash patel",
                        label: const Text("Name"),
                      ),
                    ),

                    SizedBox(
                      height: mq.height * 0.03,
                    ),

                    TextFormField(
                      initialValue: widget.user.about,
                      onSaved: (val) => APIs.me.about = val ?? "",
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : "Required field",
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.info_outline_rounded,
                          color: Colors.blue,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: "eg. yash patel",
                        label: const Text("About"),
                      ),
                    ),

                    SizedBox(
                      height: mq.height * 0.05,
                    ),

                    ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 14, 112, 193),
                            shape: const StadiumBorder(),
                            minimumSize:
                                Size(mq.width * 0.5, mq.height * 0.06)),
                        onPressed: () {
                          if (_formkey.currentState!.validate()) {
                            _formkey.currentState!.save();
                            APIs.updateUserInfo().then((value) {
                              Dialogs.showSnackbar(
                                  context, "Profile Updated successfully!");
                            });
                          }
                        },
                        icon: const Icon(
                          Icons.update,
                          size: 28,
                        ),
                        label: const Text(
                          "Update",
                          style: TextStyle(fontSize: 20),
                        ))
                  ],
                ),
              ),
            ),
          )),
    );
  }

  // bottom sheet for picking a profile picture for user
  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .03),
            children: [
              //pick profile picture label
              const Text('Pick Profile Picture',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),

              //for adding some space
              SizedBox(height: mq.height * .02),

              //buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //pick from gallery button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 3,
                          padding: const EdgeInsets.all(5),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          fixedSize: Size(mq.width * .2, mq.height * .1)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery, imageQuality: 80);
                        if (image != null) {
                          log('Image Path: ${image.path}');
                          setState(() {
                            _image = image.path;
                          });

                          APIs.updateProfilePicture(File(_image!));
                          // for hiding bottom sheet
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('images/gallery.png')),

                  //take picture from camera button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 3,
                          padding: const EdgeInsets.all(5),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          fixedSize: Size(mq.width * .2, mq.height * .1)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 80);
                        if (image != null) {
                          log('Image Path: ${image.path}');
                          setState(() {
                            _image = image.path;
                          });

                          APIs.updateProfilePicture(File(_image!));
                          // for hiding bottom sheet
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('images/camera.png')),
                ],
              )
            ],
          );
        });
  }
}
