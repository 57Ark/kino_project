import 'package:flutter/material.dart';

class MyDrawer extends StatefulWidget {
  final FilterSettings filterSettings;
  final Function updateParent;
  @override
  _MyDrawerState createState() => _MyDrawerState();

  MyDrawer(this.updateParent, this.filterSettings);
}

class _MyDrawerState extends State<MyDrawer> {
  RangeLabels squareLabels = RangeLabels('0', "200");
  RangeLabels priceLabels = RangeLabels('0', "100000");

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Ink(
        color: Colors.deepPurple,
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.cyan,
              ),
              child: Text(
                'Фильтры',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                ),
              ),
            ),
            Card(
              color: Colors.cyan,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '   Количесвто комнат',
                      style: TextStyle(fontSize: 20),
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
                  CheckboxListTile(
                    value: widget.filterSettings.isTwoRoom,
                    onChanged: (bool? newValue) {
                      setState(
                        () {
                          if (newValue != null)
                            widget.filterSettings.isTwoRoom = newValue;
                        },
                      );
                      widget.updateParent(() {});
                    },
                    title: Text(
                      '2 комнаты',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  CheckboxListTile(
                    value: widget.filterSettings.isThreeRoom,
                    onChanged: (bool? newValue) {
                      setState(
                        () {
                          if (newValue != null)
                            widget.filterSettings.isThreeRoom = newValue;
                        },
                      );
                      widget.updateParent(() {});
                    },
                    title: Text(
                      '3 комнаты',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  CheckboxListTile(
                    value: widget.filterSettings.isFourPlusRoom,
                    onChanged: (bool? newValue) {
                      setState(
                        () {
                          if (newValue != null)
                            widget.filterSettings.isFourPlusRoom = newValue;
                        },
                      );
                      widget.updateParent(() {});
                    },
                    title: Text(
                      '4 комнаты или более',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
            Card(
              color: Colors.cyan,
              child: Column(children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '   Площадь',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                RangeSlider(
                  values: widget.filterSettings.square,
                  onChanged: (RangeValues? newValues) {
                    setState(() {
                      if (newValues != null) {
                        if (newValues.end - newValues.start > 10) {
                          widget.filterSettings.square = newValues;
                        } else {
                          if (widget.filterSettings.square.start ==
                              newValues.start) {
                            widget.filterSettings.square = RangeValues(
                                widget.filterSettings.square.start,
                                widget.filterSettings.square.start + 10);
                          } else if (widget.filterSettings.square.end ==
                              newValues.end) {
                            widget.filterSettings.square = RangeValues(
                                widget.filterSettings.square.end - 10,
                                widget.filterSettings.square.end);
                          }
                        }
                        squareLabels = RangeLabels(
                            '${newValues.start.toInt().toString()} м\u00B2',
                            '${newValues.end.toInt().toString()} м\u00B2');
                      }
                    });
                    widget.updateParent(() {});
                  },
                  min: 0,
                  max: 200,
                  divisions: 200,
                  labels: squareLabels,
                  activeColor: Colors.deepPurple,
                  inactiveColor: Colors.pinkAccent,
                ),
              ]),
            ),
            Card(
              color: Colors.cyan,
              child: Column(children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '   Цена (за сутки)',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                RangeSlider(
                  values: widget.filterSettings.price,
                  onChanged: (RangeValues? newValues) {
                    setState(() {
                      if (newValues != null) {
                        if (newValues.end - newValues.start > 5000) {
                          widget.filterSettings.price = newValues;
                        } else {
                          if (widget.filterSettings.price.start ==
                              newValues.start) {
                            widget.filterSettings.price = RangeValues(
                                widget.filterSettings.price.start,
                                widget.filterSettings.price.start + 5000);
                          } else if (widget.filterSettings.price.end ==
                              newValues.end) {
                            widget.filterSettings.price = RangeValues(
                                widget.filterSettings.price.end - 5000,
                                widget.filterSettings.price.end);
                          }
                        }
                        priceLabels = RangeLabels(
                            '${newValues.start.toInt().toString()} \u20BD',
                            '${newValues.end.toInt().toString()} \u20BD');
                      }
                    });
                    widget.updateParent(() {});
                  },
                  min: 0,
                  max: 100000,
                  divisions: 100,
                  labels: priceLabels,
                  activeColor: Colors.deepPurple,
                  inactiveColor: Colors.pinkAccent,
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterSettings {
  bool isOneRoom = false;
  bool isTwoRoom = false;
  bool isThreeRoom = false;
  bool isFourPlusRoom = false;
  RangeValues square = RangeValues(0, 200);
  RangeValues price = RangeValues(0, 100000);

  bool filter(Map<String, dynamic> locs) {
    bool _rooms = (!isOneRoom && !isTwoRoom && !isThreeRoom && !isFourPlusRoom);
    bool _square = (square.start == 0 && square.end == 200);
    bool _price = (price.start == 0 && price.end == 100000);

    if (_rooms && _square && _price) {
      return true;
    } else if (_rooms && _square) {
      if (locs['price'] < price.start || locs['price'] > price.end)
        return false;
    } else if (_rooms && _price) {
      if (locs['square'] < square.start || locs['square'] > square.end)
        return false;
    } else if (_square && _price) {
      if (!isOneRoom && locs['rooms'] == 1) return false;
      if (!isTwoRoom && locs['rooms'] == 2) return false;
      if (!isThreeRoom && locs['rooms'] == 3) return false;
      if (!isFourPlusRoom && locs['rooms'] >= 4) return false;
    } else if (_rooms) {
      if (locs['square'] < square.start || locs['square'] > square.end)
        return false;

      if (locs['price'] < price.start || locs['price'] > price.end)
        return false;
    } else if (_square) {
      if (!isOneRoom && locs['rooms'] == 1) return false;
      if (!isTwoRoom && locs['rooms'] == 2) return false;
      if (!isThreeRoom && locs['rooms'] == 3) return false;
      if (!isFourPlusRoom && locs['rooms'] >= 4) return false;

      if (locs['price'] < price.start || locs['price'] > price.end)
        return false;
    } else if (_price) {
      if (!isOneRoom && locs['rooms'] == 1) return false;
      if (!isTwoRoom && locs['rooms'] == 2) return false;
      if (!isThreeRoom && locs['rooms'] == 3) return false;
      if (!isFourPlusRoom && locs['rooms'] >= 4) return false;
      if (locs['square'] < square.start || locs['square'] > square.end)
        return false;
    } else {
      if (!isOneRoom && locs['rooms'] == 1) return false;
      if (!isTwoRoom && locs['rooms'] == 2) return false;
      if (!isThreeRoom && locs['rooms'] == 3) return false;
      if (!isFourPlusRoom && locs['rooms'] >= 4) return false;

      if (locs['square'] < square.start || locs['square'] > square.end)
        return false;

      if (locs['price'] < price.start || locs['price'] > price.end)
        return false;
    }
    return true;
  }
}
