import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth.dart';
import 'my_drawer.dart';
import 'add_location.dart';

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
        canvasColor: Colors.white,
        primaryColor: Colors.deepPurple,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final FilterSettings filterSettings = FilterSettings();
  final FirebaseStorage storage = FirebaseStorage.instance;
  final CollectionReference locations =
      FirebaseFirestore.instance.collection('kino-locations');
  final FirebaseAuth auth = FirebaseAuth.instance;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
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
                  MaterialPageRoute(builder: (context) => AddLocation()),
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
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: 'Фильтры',
            );
          },
        ),
      ),
      drawer: MyDrawer(this.setState, widget.filterSettings),
      body: Center(
        child: FutureBuilder(
          future: widget.locations
              .doc('counter')
              .get()
              .then((value) => value['count']),
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
                  return FutureBuilder(
                    future: widget.locations.doc(i.toString()).get(),
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

                      if (snapshot.connectionState == ConnectionState.done) {
                        Map<String, dynamic> loc = snapshot.data.data();
                        if (widget.filterSettings.filter(loc)) {
                          Future<List<String>> imageURLs =
                              widget.storage.ref("/$i").list().then(
                            (imageRefs) async {
                              List<String> rtrn = [];
                              for (final ref in imageRefs.items) {
                                rtrn.add(await ref.getDownloadURL());
                              }
                              return rtrn;
                            },
                          );
                          String floor = '';
                          if (loc['floor'] != 0 && loc['overall floor'] != 0)
                            floor =
                                ', этаж ${loc['floor']}/${loc['overall floor']}';
                          else if (loc['floor'] != 0)
                            floor = ', этаж ${loc['floor']}';

                          String contact = '';
                          if (loc['name'] != '' && loc['name'] != null)
                            contact = loc['name'] + ' - ';
                          if (loc['contact'] != '' && loc['contact'] != null)
                            contact += loc['contact'];

                          PageController pageController = PageController();
                          String roomsEnding = 'а';
                          if ((11 <= loc['rooms'] && loc['rooms'] <= 14) ||
                              loc['rooms'] % 10 == 0 ||
                              loc['rooms'] % 10 >= 5) {
                            roomsEnding = '';
                          } else if (loc['rooms'] % 10 != 1) {
                            roomsEnding = 'ы';
                          }

                          String room = '';
                          if (loc['rooms'] != 0)
                            room = '${loc['rooms']} комнат' + roomsEnding;

                          return Card(
                            child: Container(
                              padding: EdgeInsets.all(32),
                              height:
                                  3 * MediaQuery.of(context).size.height / 5,
                              child: Row(
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: IconButton(
                                      // iconSize: 50,
                                      icon: Icon(
                                        Icons.keyboard_arrow_left_outlined,
                                      ),
                                      onPressed: () =>
                                          pageController.previousPage(
                                        duration: Duration(milliseconds: 500),
                                        curve: Curves.ease,
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 24,
                                    child: AspectRatio(
                                      aspectRatio: 3 / 2,
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
                                              backgroundDecoration:
                                                  BoxDecoration(
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
                                              child:
                                                  CircularProgressIndicator());
                                        },
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 1,
                                    child: IconButton(
                                      // iconSize: 50,
                                      icon: Icon(
                                        Icons.keyboard_arrow_right_outlined,
                                      ),
                                      onPressed: () => pageController.nextPage(
                                        duration: Duration(milliseconds: 500),
                                        curve: Curves.ease,
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 30,
                                    child: Stack(
                                      children: [
                                        Align(
                                          alignment: Alignment.topCenter,
                                          child: Text(
                                            loc['title'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
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
                                          alignment: Alignment.bottomCenter,
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
    );
  }
}
