import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kino_project/main.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_location.dart';
import 'auth.dart';

class Profile extends StatefulWidget {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final CollectionReference locations =
      FirebaseFirestore.instance.collection('kino-locations');
  final FirebaseAuth auth = FirebaseAuth.instance;
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    User? user = widget.auth.currentUser;
    String _email = '';
    if (user != null) {
      String? tmpEmail = user.email;
      if (tmpEmail != null) _email = tmpEmail;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Kino Locations"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Добавить локацию',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddLocation()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Выход из аккаунта',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Auth()),
              );
            },
          ),
        ],
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              tooltip: 'Фильтры',
            );
          },
        ),
      ),
      body: Center(
        child: Row(children: [
          Align(
            alignment: Alignment.topLeft,
            child: Column(children: [
              Container(
                height: 50,
                child: Card(
                  child: Center(
                      child: Text(
                    '  ' + _email + '   ',
                    textScaleFactor: 1.5,
                  )),
                ),
              ),
              Container(
                child: Card(
                  child: Center(
                      child: Text(
                    ' Дополнительная \n информация: ',
                    textScaleFactor: 1.3,
                  )),
                ),
              ),
            ]),
          ),
          VerticalDivider(
            color: Colors.deepPurple,
            thickness: 5,
          ),
          Expanded(
            child: Container(
              child: Column(children: [
                Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      child: Text(
                        '     Мои локации:',
                        textScaleFactor: 1.7,
                      ),
                    )),
                Expanded(
                  child: Container(
                    child: FutureBuilder(
                      future: widget.locations
                          .doc('counter')
                          .get()
                          .then((value) => value['count']),
                      builder: (BuildContext context,
                          AsyncSnapshot<dynamic> snapshot) {
                        if (snapshot.hasError) {
                          print(snapshot.error);
                          return Text(
                            "ERROR",
                          );
                        }
                        if (snapshot.connectionState == ConnectionState.done) {
                          return ListView.builder(
                            cacheExtent: 4800,
                            padding: const EdgeInsets.all(8),
                            itemCount: snapshot.data,
                            itemBuilder: (context, i) {
                              return FutureBuilder(
                                future:
                                    widget.locations.doc(i.toString()).get(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<dynamic> snapshot) {
                                  if (snapshot.hasError) {
                                    print(snapshot.error);
                                    return Center(
                                      child: Text(
                                        "ERROR",
                                      ),
                                    );
                                  }

                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    Map<String, dynamic> loc =
                                        snapshot.data.data();

                                    if (loc['contact'] != null &&
                                        loc['contact'] != '' &&
                                        loc['contact'] == _email) {
                                      Future<List<String>> imageURLs =
                                          widget.storage.ref("/$i").list().then(
                                        (imageRefs) async {
                                          List<String> rtrn = [];
                                          for (final ref in imageRefs.items) {
                                            rtrn.add(
                                                await ref.getDownloadURL());
                                          }
                                          return rtrn;
                                        },
                                      );
                                      String floor = '';
                                      if (loc['floor'] != 0 &&
                                          loc['overall floor'] != 0)
                                        floor =
                                            ', этаж ${loc['floor']}/${loc['overall floor']}';
                                      else if (loc['floor'] != 0)
                                        floor = ', этаж ${loc['floor']}';

                                      String contact = '';
                                      if (loc['name'] != '' &&
                                          loc['name'] != null)
                                        contact = loc['name'] + ' - ';
                                      if (loc['contact'] != '' &&
                                          loc['contact'] != null)
                                        contact += loc['contact'];

                                      PageController pageController =
                                          PageController();
                                      String roomsEnding = 'а';
                                      if ((11 <= loc['rooms'] &&
                                              loc['rooms'] <= 14) ||
                                          loc['rooms'] % 10 == 0 ||
                                          loc['rooms'] % 10 >= 5) {
                                        roomsEnding = '';
                                      } else if (loc['rooms'] % 10 != 1) {
                                        roomsEnding = 'ы';
                                      }

                                      String room = '';
                                      if (loc['rooms'] != 0)
                                        room = '${loc['rooms']} комнат' +
                                            roomsEnding;

                                      return Card(
                                        child: Container(
                                          padding: EdgeInsets.all(32),
                                          height: 480,
                                          child: Row(
                                            children: [
                                              IconButton(
                                                iconSize: 50,
                                                icon: Icon(
                                                  Icons
                                                      .keyboard_arrow_left_outlined,
                                                ),
                                                onPressed: () =>
                                                    pageController.previousPage(
                                                  duration: Duration(
                                                      milliseconds: 500),
                                                  curve: Curves.ease,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 640,
                                                child: FutureBuilder(
                                                  future: imageURLs,
                                                  builder:
                                                      (BuildContext context,
                                                          AsyncSnapshot<dynamic>
                                                              snapshot) {
                                                    if (snapshot.hasError) {
                                                      print(snapshot.error);
                                                      return Center(
                                                        child: Text(
                                                          "ERROR",
                                                        ),
                                                      );
                                                    }

                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState.done) {
                                                      List<String> images =
                                                          snapshot.data;
                                                      return PhotoViewGallery
                                                          .builder(
                                                        pageController:
                                                            pageController,
                                                        backgroundDecoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                        ),
                                                        itemCount:
                                                            images.length,
                                                        builder:
                                                            (context, img) {
                                                          return PhotoViewGalleryPageOptions(
                                                            imageProvider:
                                                                NetworkImage(
                                                                    images[
                                                                        img]),
                                                          );
                                                        },
                                                      );
                                                    }

                                                    return Center(
                                                        child:
                                                            CircularProgressIndicator());
                                                  },
                                                ),
                                              ),
                                              IconButton(
                                                iconSize: 50,
                                                icon: Icon(
                                                  Icons
                                                      .keyboard_arrow_right_outlined,
                                                ),
                                                onPressed: () =>
                                                    pageController.nextPage(
                                                  duration: Duration(
                                                      milliseconds: 500),
                                                  curve: Curves.ease,
                                                ),
                                              ),
                                              Expanded(
                                                child: Stack(
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.topCenter,
                                                      child: Text(
                                                        loc['title'],
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        textScaleFactor: 2,
                                                      ),
                                                    ),
                                                    Center(
                                                      child: Text(
                                                        '$room общей площадью ${loc['square']} м\u00B2 за ${loc['price']} \u20BD/сутки',
                                                        textScaleFactor: 1.5,
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment: Alignment
                                                          .bottomCenter,
                                                      child: Text(
                                                        loc['address'] +
                                                            floor +
                                                            '\n' +
                                                            contact,
                                                        textScaleFactor: 1.5,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    } else {
                                      return Container();
                                    }
                                  }
                                  return Container();
                                },
                              );
                            },
                          );
                        }
                        return Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
