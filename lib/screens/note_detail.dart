import 'package:flutter/material.dart';
import 'package:flutterappv14/models/note.dart';
import 'package:flutterappv14/utils/database_helper.dart';
import 'package:intl/intl.dart';

import 'dart:async';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetail({this.note, this.appBarTitle}); // Bu şekilde süslü parantezli kullanırsanız parametreler optional olur yani isteğe bağlı

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  static var _priorities = ['High', 'Low'];

  DatabaseHelper helper = DatabaseHelper();

  String appBarTitle;
  Note note;

  TextEditingController subeadiController = TextEditingController();
  TextEditingController anakatController = TextEditingController();
  TextEditingController altkatController = TextEditingController();
  TextEditingController demirbaskatController = TextEditingController();
  TextEditingController barkodController = TextEditingController();
  NoteDetailState(this.note, this.appBarTitle);

  String barcode = "";

  Future scan() async {
    try {
      String scannedBarcode = await BarcodeScanner.scan();
      setState(() => barkodController.text = scannedBarcode);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'Kamera yetkisi verin!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => this.barcode = 'Lütfen barkod okutunuz!');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    subeadiController.text = note.subeadi;
    anakatController.text = note.anakat;
    altkatController.text = note.altkat;
    demirbaskatController.text = note.demalt;
    barkodController.text = note.barkod;
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    return WillPopScope(
        onWillPop: () {
          // Write some code to control things, when user press Back navigation button in device navigationBar
          moveToLastScreen();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  // Write some code to control things, when user press back button in AppBar
                  moveToLastScreen();
                }),
          ),
          body: Padding(
            padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
            child: ListView(
              children: <Widget>[
                // First element
                ListTile(
                  title: DropdownButton(
                      items: _priorities.map((String dropDownStringItem) {
                        return DropdownMenuItem<String>(
                          value: dropDownStringItem,
                          child: Text(dropDownStringItem),
                        );
                      }).toList(),
                      style: textStyle,
                      value: getPriorityAsString(note.priority),
                      onChanged: (valueSelectedByUser) {
                        setState(() {
                          debugPrint('User selected $valueSelectedByUser');
                          updatePriorityAsInt(valueSelectedByUser);
                        });
                      }),
                ),

                // sube adı
                Padding(
                  padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: TextField(
                    controller: subeadiController,
                    style: textStyle,
                    onChanged: (value) {
                      debugPrint('Something changed in Title Text Field');
                      updateTitle();
                    },
                    decoration:
                        InputDecoration(labelText: 'Şube Adı', labelStyle: textStyle, border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),

                // ana kategori
                Padding(
                  padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: TextField(
                    controller: anakatController,
                    style: textStyle,
                    onChanged: (value) {
                      debugPrint('Something changed in Description Text Field');
                      updateDescription();
                    },
                    decoration:
                        InputDecoration(labelText: 'Ana Kategori', labelStyle: textStyle, border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),

                // alt katagori
                Padding(
                  padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: TextField(
                    controller: altkatController,
                    style: textStyle,
                    onChanged: (value) {
                      debugPrint('Something changed in Description Text Field');
                      updatealtkat();
                    },
                    decoration:
                        InputDecoration(labelText: 'Alt Kategori', labelStyle: textStyle, border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),

                // demirbaş katagori
                Padding(
                  padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: TextField(
                    controller: demirbaskatController,
                    style: textStyle,
                    onChanged: (value) {
                      debugPrint('Something changed in Description Text Field');
                      updateDescription();
                    },
                    decoration: InputDecoration(
                        labelText: 'Demirbaş Kategori', labelStyle: textStyle, border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),

                // barkod
                Padding(
                  padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: TextField(
                    controller: barkodController,
                    style: textStyle,
                    onChanged: (barcode) {
                      debugPrint('Something changed in Description Text Field');
                      updateBarkod();
                    },
                    decoration: InputDecoration(
                        labelText: 'Barkod',
                        labelStyle: textStyle,
                        suffix: IconButton(
                          icon: Icon(Icons.camera_alt),
                          onPressed: scan,
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),

                // Fourth Element
                Padding(
                  padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            'Kaydet',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint("Save button clicked");
                              _save();
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 5.0,
                      ),
                      Expanded(
                        child: RaisedButton(
                            child: Text(
                              'Kaydet',
                              textScaleFactor: 1.5,
                            ),
                            onPressed: scan),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  // Convert the String priority in the form of integer before saving it to Database
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  // Convert int priority to String priority and display it to user in DropDown
  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0]; // 'High'
        break;
      case 2:
        priority = _priorities[1]; // 'Low'
        break;
    }
    return priority;
  }

  // Update the title of Note object
  void updateTitle() {
    note.subeadi = subeadiController.text;
  }

  // Update the description of Note object
  void updateDescription() {
    note.anakat = anakatController.text;
  }

// Update the description of Note object
  void updatealtkat() {
    note.altkat = altkatController.text;
  }

// Update the description of Note object
  void updatedemkat() {
    note.demalt = demirbaskatController.text;
  }

  // Update the description of Note object
  void updateBarkod() {
    note.barkod = barkodController.text;
  }

  // Save data to database
  void _save() async {
    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id != null) {
      // Case 1: Update operation
      result = await helper.updateNote(note);
    } else {
      // Case 2: Insert Operation
      result = await helper.insertNote(note);
    }

    if (result != 0) {
      // Success
      _showAlertDialog('Status', 'Note Saved Successfully');
    } else {
      // Failure
      _showAlertDialog('Status', 'Problem Saving Note');
    }
  }

  //void _delete() async {

  //moveToLastScreen();

  // Case 1: If user is trying to delete the NEW NOTE i.e. he has come to
  // the detail page by pressing the FAB of NoteList page.
  //if (note.id == null) {
  //	_showAlertDialog('Status', 'No Note was deleted');
  //	return;
  //	}

  // Case 2: User is trying to delete the old note that already has a valid ID.
  //	int result = await helper.deleteNote(note.id);
  //if (result != 0) {
//			_showAlertDialog('Status', 'Note Deleted Successfully');
//		} else {
//			_showAlertDialog('Status', 'Error Occured while Deleting Note');
//		}
//	}

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
