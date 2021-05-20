import 'package:flutter/material.dart';

class MyDrawer extends StatefulWidget {
  final FilterSettings filterSettings;
  final Function updateParent;
  @override
  _MyDrawerState createState() => _MyDrawerState();

  MyDrawer(this.updateParent, this.filterSettings);
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black,
            ),
            child: Text(
              'Фильтр',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          CheckboxListTile(
            value: widget.filterSettings.isOneRoom,
            onChanged: (bool? newValue) {
              setState(
                () {
                  if (newValue != null)
                    widget.filterSettings.isOneRoom = newValue;
                },
              );
              widget.updateParent(() {});
            },
            title: Text(
              '1 комната',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class FilterSettings {
  bool isOneRoom = false;
  bool isTwoRoom = false;
  bool isThreeRoom = false;
  bool isFourPlusRoom = false;

  bool filter(Map<String, dynamic> locs) {
    if (!isOneRoom && !isTwoRoom && !isThreeRoom && !isFourPlusRoom)
      return true;
    if (!isOneRoom && locs['rooms'] == 1) return false;
    if (!isTwoRoom && locs['rooms'] == 2) return false;
    if (!isThreeRoom && locs['rooms'] == 3) return false;
    if (!isFourPlusRoom && locs['rooms'] >= 4) return false;
    return true;
  }
}
