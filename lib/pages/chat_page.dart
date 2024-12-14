import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8
            ),
            child: TextButton.icon(
              onPressed: FirebaseAuth.instance.signOut, 
              icon: Icon(Icons.logout,color:Theme.of(context).colorScheme.primary ,),
              label:const Text(
                "Log out",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16
                ),
              ),
            ),
          )
        ],
      ),
      body: const Center(
        child:  Text("text"),
      ),
    );
  }
}