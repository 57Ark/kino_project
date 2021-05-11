import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize FlutterFire:
  await Firebase.initializeApp();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
      },
      title: 'Kino Locations',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final CollectionReference locations =
      FirebaseFirestore.instance.collection('kino-locations');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kino Locations"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Authorisation',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Auth()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder(
          future:
              locations.doc('counter').get().then((value) => value['count']),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
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
                  Future<List<String>> imageURLs =
                      storage.ref("/$i").list().then(
                    (imageRefs) async {
                      List<String> rtrn = [];
                      for (final ref in imageRefs.items) {
                        rtrn.add(await ref.getDownloadURL());
                      }
                      return rtrn;
                    },
                  );
                  PageController pageController = PageController();
                  return Card(
                    child: Container(
                      padding: EdgeInsets.all(32),
                      height: 480,
                      child: Row(
                        children: [
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
                            child: FutureBuilder(
                              future: imageURLs,
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
                                  List<String> images = snapshot.data;
                                  return PhotoViewGallery.builder(
                                    pageController: pageController,
                                    backgroundDecoration: BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    itemCount: images.length,
                                    builder: (context, img) {
                                      return PhotoViewGalleryPageOptions(
                                        imageProvider:
                                            NetworkImage(images[img]),
                                      );
                                    },
                                  );
                                }

                                return Center(
                                    child: CircularProgressIndicator());
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
                          Expanded(
                            child: FutureBuilder(
                              future: locations.doc(i.toString()).get(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<dynamic> snapshot) {
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text(
                                      "ERROR",
                                    ),
                                  );
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  Map<String, dynamic> locs =
                                      snapshot.data.data();
                                  String roomsEnding = 'а';
                                  if ((11 <= locs['rooms'] &&
                                          locs['rooms'] <= 14) ||
                                      locs['rooms'] % 10 == 0 ||
                                      locs['rooms'] % 10 >= 5) {
                                    roomsEnding = '';
                                  } else if (locs['rooms'] % 10 != 1) {
                                    roomsEnding = 'ы';
                                  }
                                  return Stack(children: [
                                    Align(
                                      alignment: Alignment.topCenter,
                                      child: Text(
                                        locs['title'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textScaleFactor: 2,
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        '${locs['rooms']} комнат$roomsEnding общей площадью ${locs['square']} м\u00B2 за ${locs['price']} \u20BD/месяц',
                                        textScaleFactor: 1.5,
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Text(
                                        locs['address'] +
                                            ', этаж ${locs['floor']}/${locs['overall floor']}',
                                        textScaleFactor: 1.5,
                                      ),
                                    ),
                                  ]);
                                }

                                return Center(
                                    child: CircularProgressIndicator());
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
