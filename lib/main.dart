import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faker/faker.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: 'AIzaSyCTDSPZxPEwmvK3UnDtrOynx07kqUEfAD0',
        appId: '1:306773851386:android:d575d0520e8aaba7f69d43',
        messagingSenderId: '306773851386',
        projectId: 'auth-a77b6',
        storageBucket: "auth-a77b6.appspot.com"),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String imageName = '';
  XFile? imagePath;
  final ImagePicker _picker = ImagePicker();
  TextEditingController descriptionController = TextEditingController();

  FirebaseFirestore firestoreRef = FirebaseFirestore.instance;
  FirebaseStorage storageRef = FirebaseStorage.instance;
  String collectionName = 'Image';

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    imageName == '' ? Container() : Text('${imageName}'),
                    OutlinedButton(
                      onPressed: () {
                        imagePicker();
                      },
                      child: Text('Select Image'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: descriptionController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // UPLOAD FUNCTION HERE
                        _uplaodImage();
                      },
                      child: Text('Upload'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  _uplaodImage() async {
    setState(() {
      _isLoading = true;
    });
    var uniqueKey = firestoreRef.collection(collectionName);
    String uploadFileName =
        DateTime.now().microsecondsSinceEpoch.toString() + '.jpg';
    Reference reference =
        storageRef.ref().child(collectionName).child(uploadFileName);
    UploadTask uploadTask = reference.putFile(File(imagePath!.path));

    uploadTask.snapshotEvents.listen((event) {
      print(event.bytesTransferred.toString() +
          '\t' +
          event.totalBytes.toString());
    });

    await uploadTask.whenComplete(() async {
      var uploadPath = await uploadTask.snapshot.ref.getDownloadURL();

//NOW HERE WILL INSERT REECORD ISIDE DATABASE REGARDING URL
      if (uploadPath.isNotEmpty) {
        firestoreRef.collection(collectionName).doc(uniqueKey.id).set({
          'discription': descriptionController.text,
          'image': uploadPath,
        }).then((value) => _showMessage('Record Inserted'));
      } else {
        _showMessage('Something While Uploading Image');
      }
      setState(() {
        _isLoading = false;
      });
    });
  }

  _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      duration: Duration(seconds: 3),
    ));
  }

  imagePicker() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        imagePath = image;
        imageName = image.name.toString();
        descriptionController.text = Faker().lorem.sentence();
      });
    }
  }
}
