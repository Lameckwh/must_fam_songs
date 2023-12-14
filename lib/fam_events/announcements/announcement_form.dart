import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../add_image_widget.dart';
import '../edit_image_widget.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

class AnnouncementForm extends StatefulWidget {
  final String? documentId;
  final String? title;
  final String? description;
  final DateTime? datePosted;
  final String? imageUrl;

  const AnnouncementForm({
    Key? key,
    this.documentId,
    this.title,
    this.description,
    this.datePosted,
    this.imageUrl,
  }) : super(key: key);

  @override
  State<AnnouncementForm> createState() => _AnnouncementFormState();
}

class _AnnouncementFormState extends State<AnnouncementForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool isPostSuccess = false;
  bool showAlert = false; // Added to control the visibility of the alert
  String title = '';
  String description = '';
  DateTime datePosted = DateTime.now();
  File? image;

  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      final imagePermanent = await saveImagePermanently(image.path);
      setState(() => this.image = imagePermanent);
    } on PlatformException catch (e) {
      logger.e("Failed to pick image: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    // Set the initial values in the form fields when editing
    title = widget.title ?? '';
    description = widget.description ?? '';
    datePosted = widget.datePosted ?? DateTime.now();
  }

  Future<File> saveImagePermanently(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final title = basename(imagePath);
    final image = File("${directory.path}/$title");

    return File(imagePath).copy(image.path);
  }

  Future<String?> uploadImageToFirebaseStorage(File imageFile) async {
    try {
      final storage = FirebaseStorage.instance;
      final storageRef = storage.ref().child('announcement_images');

      final originalExtension = imageFile.path.split('.').last;
      final imageName =
          '${DateTime.now().millisecondsSinceEpoch}.$originalExtension';

      final uploadTask = storageRef.child(imageName).putFile(imageFile);

      await uploadTask.whenComplete(() => null);
      return await storageRef.child(imageName).getDownloadURL();
    } catch (e) {
      logger.e("Error uploading image to Firebase Storage");

      return null;
    }
  }

  Future<void> uploadDataToFirebase() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
        isPostSuccess = false;
        showAlert = false; // Reset the showAlert state
      });

      _formKey.currentState?.save();

      final duplicateQuery = await FirebaseFirestore.instance
          .collection('announcements')
          .where('title', isEqualTo: title)
          .where('description', isEqualTo: description)
          .get();

      if (duplicateQuery.docs.isNotEmpty) {
        setState(() {
          isLoading = false;
        });

        logger.d("Duplicate document found. Please enter unique values.");
        return;
      }

      String? imageUrl;

      if (image != null) {
        imageUrl = await uploadImageToFirebaseStorage(image!);
        if (imageUrl == null) {
          setState(() {
            isLoading = false;
          });
          return;
        }
      }

      await FirebaseFirestore.instance.collection('announcements').add({
        'title': title,
        'description': description,
        'datePosted': datePosted,
        'imageUrl': imageUrl,
      });

      _formKey.currentState?.reset();

      setState(() {
        isLoading = false;
        isPostSuccess = true;
        showAlert = true; // Set showAlert to true to display the alert
      });
      logger.i("Announcement posted successfully!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Announcement'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    image != null
                        ? EditImageWidget(
                            image: image!,
                            onClicked: (source) => pickImage(source),
                          )
                        : AddImageWidget(
                            image: File('images/image-outline-filled.png'),
                            onClicked: (source) => pickImage(source),
                          ),
                    const Text(
                      "(Image upload is optional)",
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter announcement title',
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the title';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          title = value ?? '';
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter the description',
                        ),
                        maxLines: null,
                        minLines: 6,
                        keyboardType: TextInputType.multiline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the description';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          description = value ?? '';
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: isLoading ? null : uploadDataToFirebase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        minimumSize: Size(
                          200.w,
                          50.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : Text(
                              'Post',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Ubuntu",
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (showAlert)
            Center(
              child: AlertDialog(
                title: const Text('Success'),
                content: const Text('Announcement posted successfully!'),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showAlert = false; // Close the alert
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
