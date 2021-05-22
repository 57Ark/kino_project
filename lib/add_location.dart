import 'dart:typed_data';
import 'package:mime/mime.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth.dart';
import 'payment.dart';
import 'profile.dart';

class AddLocation extends StatefulWidget {
  final FirebaseAuth auth = FirebaseAuth.instance;
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

  bool isNumeric(String? s) {
    if (s == null) return false;
    return double.tryParse(s) != null;
  }

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
            onPressed: () {
              User? user = widget.auth.currentUser;
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profile()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Auth()),
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          User? user = widget.auth.currentUser;
          if (user != null) loc['contact'] = user.email;
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
                    .then((_) => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Payment()),
                        ))
                    .catchError(
                      (error) => print("Failed to add user: $error"),
                    ),
              );
            }
          }
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Card(
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.textsms),
                    hintText: 'Как ваше объявление будет называться?',
                    labelText: 'Название',
                  ),
                  onSaved: (String? value) {
                    loc['title'] = value;
                  },
                  validator: (String? value) {
                    if (value == '' || value == null)
                      return 'Пожалуйтса, заполните это поле';
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    hintText: 'Как вас зовут?',
                    labelText: 'Имя',
                  ),
                  onSaved: (String? value) {
                    loc['name'] = value;
                  },
                  validator: (String? value) {
                    if (value == '' || value == null)
                      return 'Пожалуйтса, заполните это поле';
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.attach_money),
                    hintText: 'Укажите цену за сутки в рублях',
                    labelText: 'Цена',
                  ),
                  onSaved: (String? value) {
                    if (value != null) loc['price'] = int.parse(value);
                  },
                  validator: (String? value) {
                    if (value == '' || value == null)
                      return 'Пожалуйтса, заполните это поле';
                    if (!isNumeric(value)) return 'Пожалуйста, введите число';
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.pin_drop),
                    hintText: 'Введите адрес вашей локации',
                    labelText: 'Адрес',
                  ),
                  onSaved: (String? value) {
                    loc['address'] = value;
                  },
                  validator: (String? value) {
                    if (value == '' || value == null)
                      return 'Пожалуйтса, заполните это поле';
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.network_cell),
                    hintText: 'На каком этаже находится локация?',
                    labelText: 'Этаж',
                  ),
                  onSaved: (String? value) {
                    if (value != null) loc['floor'] = int.parse(value);
                  },
                  validator: (String? value) {
                    if (value == '' || value == null)
                      return 'Пожалуйтса, заполните это поле';
                    if (!isNumeric(value))
                      return 'Пожалуйста, введите положительное число';
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.network_locked),
                    hintText: 'Сколько всего этажей в здании?',
                    labelText: 'Всего этажей',
                  ),
                  onSaved: (String? value) {
                    if (value != null) loc['overall floor'] = int.parse(value);
                  },
                  validator: (String? value) {
                    if (value == '' || value == null)
                      return 'Пожалуйтса, заполните это поле';
                    if (!isNumeric(value)) return 'Пожалуйста, введите число';
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.grid_on),
                    hintText: 'Укажите количество комнат в локации',
                    labelText: 'Количество комнат',
                  ),
                  onSaved: (String? value) {
                    if (value != null) loc['rooms'] = int.parse(value);
                  },
                  validator: (String? value) {
                    if (value == '' || value == null)
                      return 'Пожалуйтса, заполните это поле';
                    if (!isNumeric(value)) return 'Пожалуйста, введите число';
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.tab_unselected),
                    hintText: 'Введите площадь локации в м\u00B2',
                    labelText: 'Площадь',
                  ),
                  onSaved: (String? value) {
                    if (value != null) loc['square'] = int.parse(value);
                  },
                  validator: (String? value) {
                    if (value == '' || value == null)
                      return 'Пожалуйтса, заполните это поле';
                    if (!isNumeric(value)) return 'Пожалуйста, введите число';
                    return null;
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
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.deepPurple)),
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
                      child: const Text(
                        'Загрузить фото',
                        // style: TextStyle(color: Colors.deepPurple),
                      ),
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
