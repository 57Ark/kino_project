import 'dart:typed_data';
import 'package:mime/mime.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:image_picker/image_picker.dart';

class AddLocation extends StatefulWidget {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final CollectionReference locations =
      FirebaseFirestore.instance.collection('kino-locations');

  @override
  _AddLocationState createState() => _AddLocationState();
}

class _AddLocationState extends State<AddLocation> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> loc = Map<String, dynamic>();
  ImagePicker imagePicker = ImagePicker();
  List<Map<String, dynamic>> images = [];
  PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final Future<int> counter =
        widget.locations.doc('counter').get().then((value) => value['count']);
    return Scaffold(
      appBar: AppBar(
        title: Text("Kino Locations"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Личный кабинет',
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            if (images.length == 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Загрузите хотя бы одно фото"),
                ),
              );
            } else {
              _formKey.currentState!.save();
              counter.then(
                (cnt) {
                  widget.locations.doc((cnt).toString()).set(loc);
                  return cnt;
                },
              ).then((cnt) {
                for (int i = 0; i < images.length; ++i) {
                  widget.storage
                      .ref(cnt.toString() +
                          '/' +
                          i.toString() +
                          '.' +
                          images[i]['extention'])
                      .putData(
                        images[i]['bytes'],
                        SettableMetadata(
                          contentType: 'image/' + images[i]['extention'],
                        ),
                      );
                }
                return cnt;
              }).then(
                (cnt) => widget.locations
                    .doc("counter")
                    .set({"count": cnt + 1})
                    .then((_) => Navigator.pop(context))
                    .catchError(
                      (error) => print("Failed to add user: $error"),
                    ),
              );
            }
          }
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.cyan,
      ),
      body: Center(
        child: Card(
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    hintText: 'What do people call you?',
                    labelText: 'Name',
                  ),
                  onSaved: (String? value) {
                    // This optional block of code can be used to run
                    // code when the user saves the form.
                  },
                  validator: (String? value) {
                    return (value != null && value.contains('@'))
                        ? 'Do not use the @ char.'
                        : null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    hintText: 'What do people call you?',
                    labelText: 'Address',
                  ),
                  onSaved: (String? value) {
                    loc['address'] = value;
                  },
                  validator: (String? value) {
                    return (value != null && value.contains('@'))
                        ? 'Do not use the @ char.'
                        : null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    hintText: 'What do people call you?',
                    labelText: 'floor',
                  ),
                  onSaved: (String? value) {
                    // This optional block of code can be used to run
                    // code when the user saves the form.
                  },
                  validator: (String? value) {
                    return (value != null && value.contains('@'))
                        ? 'Do not use the @ char.'
                        : null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    hintText: 'What do people call you?',
                    labelText: 'Overallfloor',
                  ),
                  onSaved: (String? value) {
                    // This optional block of code can be used to run
                    // code when the user saves the form.
                  },
                  validator: (String? value) {
                    return (value != null && value.contains('@'))
                        ? 'Do not use the @ char.'
                        : null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    hintText: 'What do people call you?',
                    labelText: 'price',
                  ),
                  onSaved: (String? value) {
                    // This optional block of code can be used to run
                    // code when the user saves the form.
                  },
                  validator: (String? value) {
                    return (value != null && value.contains('@'))
                        ? 'Do not use the @ char.'
                        : null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    hintText: 'What do people call you?',
                    labelText: 'rooms',
                  ),
                  onSaved: (String? value) {
                    // This optional block of code can be used to run
                    // code when the user saves the form.
                  },
                  validator: (String? value) {
                    return (value != null && value.contains('@'))
                        ? 'Do not use the @ char.'
                        : null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    hintText: 'What do people call you?',
                    labelText: ' Square',
                  ),
                  onSaved: (String? value) {
                    // This optional block of code can be used to run
                    // code when the user saves the form.
                  },
                  validator: (String? value) {
                    return (value != null && value.contains('@'))
                        ? 'Do not use the @ char.'
                        : null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    hintText: 'What do people call you?',
                    labelText: 'title',
                  ),
                  onSaved: (String? value) {
                    // This optional block of code can be used to run
                    // code when the user saves the form.
                  },
                  validator: (String? value) {
                    return (value != null && value.contains('@'))
                        ? 'Do not use the @ char.'
                        : null;
                  },
                ),
                Visibility(
                  visible: images.length > 0,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(32),
                      height: 480,
                      child: Row(children: [
                        IconButton(
                          iconSize: 50,
                          icon: Icon(
                            Icons.keyboard_arrow_left_outlined,
                          ),
                          onPressed: () => pageController.previousPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.ease,
                          ),
                        ),
                        SizedBox(
                          width: 640,
                          child: PhotoViewGallery.builder(
                            pageController: pageController,
                            backgroundDecoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            itemCount: images.length,
                            builder: (context, img) {
                              return PhotoViewGalleryPageOptions(
                                imageProvider:
                                    MemoryImage(images[img]['bytes']),
                              );
                            },
                          ),
                        ),
                        IconButton(
                          iconSize: 50,
                          icon: Icon(
                            Icons.keyboard_arrow_right_outlined,
                          ),
                          onPressed: () => pageController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.ease,
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
                Card(
                  elevation: 0,
                  child: Row(children: [
                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.cyan)),
                      onPressed: () async {
                        PickedFile? newImage = await imagePicker.getImage(
                            source: ImageSource.gallery);
                        if (newImage != null) {
                          Uint8List bytes = await newImage.readAsBytes();
                          String? mime = lookupMimeType('', headerBytes: bytes);
                          if (mime != null) {
                            String ext = extensionFromMime(mime);
                            print(ext);
                            if (ext == 'jpe') ext = 'jpeg';
                            if (ext == 'jpeg' || ext == 'png') {
                              setState(() {
                                images.add({"bytes": bytes, "extention": ext});
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      "Фото должны быть в формате jpg или png"),
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "Фото должны быть в формате jpg или png"),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Загрузить фото'),
                    ),
                    Visibility(
                      visible: images.length > 0,
                      child: TextButton(
                        onPressed: () {
                          if (images.length > 0) {
                            setState(() {
                              images.removeAt(pageController.page!.round());
                            });
                          }
                        },
                        child: Text(' Удалить',
                            style: TextStyle(color: Colors.redAccent)),
                      ),
                    )
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
