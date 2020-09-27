import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:todo/database/db_manager.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:todo/model/task_list.dart';

class NewListPage extends StatefulWidget {
  NewListPage({Key key}) : super(key: key);

  @override
  _NewListPageState createState() => _NewListPageState();
}

class _NewListPageState extends State<NewListPage> {
  TextEditingController listNameController = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // DBManager dbManager = new DBManager();

  bool _saving = false;

  Color currentColor = Color(0xff6633ff);
  Color pickerColor = Color(0xff6633ff);

  ValueChanged<Color> onColorChanged;

  changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  @override
  void dispose() {
    _scaffoldKey.currentState?.dispose();
    //_connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // initConnectivity();
    // _connectivitySubscription =
    //     _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
    //       setState(() {
    //         _connectionStatus = result.toString();
    //       });
    //     });
  }

  // TODO: 未用
  void showInSnackBar(String value) {
    _scaffoldKey.currentState?.removeCurrentSnackBar();

    _scaffoldKey.currentState?.showSnackBar(new SnackBar(
      content: new Text(value, textAlign: TextAlign.center),
      backgroundColor: currentColor,
      duration: Duration(seconds: 3),
    ));
  }

  Container _getToolbar(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10.0, top: 40.0),
      child: BackButton(color: Colors.black),
    );
  }

  _submit() {
    setState(() {
      _saving = true;
    });

    // TODO: 加异步操作
    Future.delayed(Duration(seconds: 2), () {
      TaskList list =
          new TaskList(listNameController.text.toString().trim(), currentColor);
      DBManager.getInstance().then((value) => value.addTaskList(list));
      //DBManager.get.addTaskList(list);

      setState(() {
        _saving = false;
      });
    });

    // setState(() {
    //   _saving = false;
    // });
  }

  Widget _buildWidget() {
    return Stack(
      children: [
        _getToolbar(context),
        Container(
          child: Column(
            children: [
              // 标题: NewList
              Padding(
                padding: EdgeInsets.only(top: 100.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'New',
                            style: TextStyle(
                                fontSize: 30.0, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'List',
                            style:
                                TextStyle(fontSize: 28.0, color: Colors.grey),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.only(
                  top: 50.0,
                  left: 20.0,
                  right: 20.0,
                ),
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                          border: new OutlineInputBorder(
                              borderSide: new BorderSide(color: Colors.teal)),
                          labelText: "List name",
                          contentPadding: EdgeInsets.only(
                              left: 16.0, top: 20.0, right: 16.0, bottom: 5.0)),
                      controller: listNameController,
                      autofocus: true,
                      style: TextStyle(
                        fontSize: 22.0,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      maxLength: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                    ),
                    ButtonTheme(
                      minWidth: double.infinity,
                      child: RaisedButton(
                        elevation: 3.0,
                        color: currentColor,
                        textColor: const Color(0xffffffff),
                        child: Text('Card color'),
                        onPressed: () {
                          pickerColor = currentColor;
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Pick a color!'),
                                content: SingleChildScrollView(
                                  child: ColorPicker(
                                    pickerColor: pickerColor,
                                    onColorChanged: changeColor,
                                    //enableLabel: true,
                                    colorPickerWidth: 1000.0,
                                    pickerAreaHeightPercent: 0.7,
                                  ),
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text('Got it'),
                                    onPressed: () {
                                      setState(
                                          () => currentColor = pickerColor);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // 按钮
              Padding(
                padding: EdgeInsets.only(top: 50.0),
                child: Column(
                  children: <Widget>[
                    RaisedButton(
                      child: const Text(
                        'Add',
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.blue,
                      elevation: 4.0,
                      splashColor: Colors.deepPurple,
                      // TODO: finish this
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: ModalProgressHUD(
        inAsyncCall: _saving,
        child: _buildWidget(),
      ),
    );
  }
}
