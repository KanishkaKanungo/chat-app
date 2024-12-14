// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'dart:io';
import 'dart:typed_data';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
//import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_core/amplify_core.dart';
import 'package:amplify_secure_storage/amplify_secure_storage.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'amplifyconfiguration.dart';

/*import 'amplify_outputs.dart';*/

final AmplifyLogger _logger = AmplifyLogger('MyStorageApp');

class Tester extends StatefulWidget {
  const Tester({super.key, required this.title});

  final String title;

  // This widget is the root of your application.
  @override
  State<Tester> createState() => _TesterState();
}

class _TesterState extends State<Tester> {
  // static final _router = GoRouter(
  //   routes: [
  //     GoRoute(
  //       path: '/',
  //       builder: (BuildContext _, GoRouterState __) => const HomeScreen(),
  //     ),
  //   ],
  // );
  File? _pickedImageFile;
  Uint8List? kanishka;
  @override
  void initState() {
    super.initState();
    configureAmplify();
    //  _checkAuthStatus();
    // _listAllPublicFiles();
  }

  Future<void> configureAmplify() async {
    // final auth = AmplifyAuthCognito(
    //   // FIXME: In your app, make sure to remove this line and set up
    //   /// Keychain Sharing in Xcode as described in the docs:
    //   /// https://docs.amplify.aws/lib/project-setup/platform-setup/q/platform/flutter/#enable-keychain
    //   secureStorageFactory: AmplifySecureStorage.factoryFrom(
    //     macOSOptions:
    //         // ignore: invalid_use_of_visible_for_testing_member
    //         MacOSSecureStorageOptions(useDataProtection: false),
    //   ),
    //);
    final storage = AmplifyStorageS3();

    try {
      await Amplify.addPlugins([storage]);
      await Amplify.configure(amplifyconfig);
      _logger.debug('Successfully configured Amplify');
    } on Exception catch (error) {
      _logger.error('Something went wrong configuring Amplify: $error');
    }
  }

  List<StorageItem> list = [];
  var imageUrl = '';

  //@override
  // void initState() {
  //   super.initState();

  // }

  // sign out of the app
  Future<void> _signOut() async {
    try {
      await Amplify.Auth.signOut();
      _logger.debug('Signed out');
    } on AuthException catch (e) {
      _logger.error('Could not sign out - ${e.message}');
    }
  }

  // check if the user is signed in
  Future<void> _checkAuthStatus() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      _logger.debug('Signed in: ${session.isSignedIn}');
    } on AuthException catch (e) {
      _logger.error('Could not check auth status - ${e.message}');
    }
  }

  // upload a file to the S3 bucket
  Future<void> _uploadFile() async {
    // final platformFile = files.single;

    try {
      await Amplify.Storage.uploadFile(
        localFile: AWSFile.fromStream();
        //  path: StoragePath.fromString('public/${platformFile.name}'),
        onProgress: (p) =>
            _logger.debug('Uploading: ${p.transferredBytes}/${p.totalBytes}'),
        key: '',
      ).result;
      //  await _listAllPublicFiles();
    } on StorageException catch (e) {
      _logger.error('Error uploading file - ${e.message}');
    }
  }

  void _pickImage() async {
    final pickImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 150,
    );
    if (pickImage == null) {
      return;
    }
    kanishka = await pickImage.readAsBytes();
    setState(() {
      _pickedImageFile = File(pickImage.path);
    });

    //widget.onSelectImage(_pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Amplify Storage Example'),
        ),
        body: Column(
          children: [
            Text("data"),
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey,
              foregroundImage: _pickedImageFile != null
                  ? FileImage(_pickedImageFile!)
                  : null,
            ),
            if (_pickedImageFile == null)
              TextButton.icon(
                onPressed: _pickImage,
                label: const Text("Add Image"),
                icon: const Icon(Icons.image),
              ),
            const SizedBox(
              height: 8,
            ),
            ElevatedButton(
                onPressed: _pickedImageFile == null
                    ? null
                    : () async {
                        await _uploadFile();
                      },
                child: Text("upload"))
          ],
        ));
  }
}
