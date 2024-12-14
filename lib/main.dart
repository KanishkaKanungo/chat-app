import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:chat_app/kanishka.dart';
import 'package:chat_app/pages/auth_page.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/pages/splash_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'amplifyconfiguration.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureAmplify();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  runApp(const MaterialApp(
    home: Tester(title: 'Test'),
  ));
}

Future<void> configureAmplify() async {
  try {
    final auth = AmplifyAuthCognito();
    final storage = AmplifyStorageS3();
    await Amplify.addPlugins([auth, storage]);
    print("Amplify configured successfully!");
  } catch (e) {
    print("Error configuring Amplify: $e");
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'FlutterChat',
        theme: ThemeData().copyWith(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 63, 17, 177)),
        ),
        home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SplashPage();
              }
              if (snapshot.hasData) {
                return const ChatPage();
              }
              return const AuthScreen();
            }));
  }
}
