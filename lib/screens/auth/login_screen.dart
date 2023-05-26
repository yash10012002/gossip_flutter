import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gossip_flutter/api/apis.dart';
import 'package:gossip_flutter/helper/dialogs.dart';
import 'package:gossip_flutter/screens/home_screen.dart';

import '../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  _handleGoogleBtnClick() {
    // show progress bar
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async {
      // for hiding progress bar
      Navigator.pop(context);
      if (user != null) {
        log("\nUser: ${user.user}");
        log("\nUserAdditionalInfo: ${user.additionalUserInfo}");
        if ((await APIs.userExists())) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup("google.com");
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log("\n_signInWithGoogle: $e");
      Dialogs.showSnackbar(context, "Something went wrong (Check Internet!)");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome to Gossip"),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
            top: mq.height * 0.15,
            left: _isAnimate ? mq.width * 0.25 : -mq.width * .5,
            width: mq.width * 0.5,
            duration: const Duration(seconds: 1),
            child: Image.asset("images/chat.png"),
          ),
          Positioned(
            bottom: mq.height * 0.15,
            left: mq.width * 0.1,
            width: mq.width * 0.8,
            height: mq.height * 0.07,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 22, 89, 184),
                  shape: const StadiumBorder(),
                  elevation: 1),
              onPressed: () {
                _handleGoogleBtnClick();
              },
              icon: Image.asset("images/google.png", height: 40),
              label: RichText(
                  text: const TextSpan(
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      children: [
                    TextSpan(text: "Sign In with "),
                    TextSpan(
                        text: "Google",
                        style: TextStyle(fontWeight: FontWeight.w500))
                  ])),
            ),
          ),
        ],
      ),
    );
  }
}
