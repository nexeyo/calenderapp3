import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:calenderapp/main.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'calendercarousel.dart';
import 'editprofile.dart';
import 'home.dart';
import 'size_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart' show CalendarCarousel;


final requestRef = Firestore.instance.collection('requests');
final usersref = Firestore.instance.collection('users');

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;



Color inactiveBoxClr = Colors.red[500];
Color activeBoxClr = Colors.red[800];

class Calender extends StatefulWidget {

  @override
  _CalenderState createState() => _CalenderState();
}

class _CalenderState extends State<Calender> {
  TextEditingController _dateSelected = new TextEditingController();

  Color breakfastClr = inactiveBoxClr;
  Color lunchClr = inactiveBoxClr;

  String category;
  DateTime date;
  DateTime _dateTime = DateTime.now();
  Map<DateTime,List<dynamic>> _events;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _events = {};
  }


  Future<DateTime> getDate() {
    // Imagine that this function is
    // more complex and slow.
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2018),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.light(),
          child: child,
        );
      },
    );
  }

  var finaldate;
  Future<Null> selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _dateTime,
        firstDate: new DateTime(2018),
        lastDate: new DateTime(2999));

    if (picked != null && picked != _dateTime) {
      setState(() {
        _dateTime = picked;
        _dateSelected.value = TextEditingValue(text: picked.toString());
      });
    }
  }

  void callDatePicker() async {
    var order = await getDate();
    setState(() {
      finaldate = order;
    });
  }

  void updateClr(int category){
    if(category == 1){
      if(breakfastClr==inactiveBoxClr){
        breakfastClr = activeBoxClr;
        lunchClr = inactiveBoxClr;
      }
      else{
        breakfastClr = inactiveBoxClr;
      }
    }
    if(category==2)
    {
      if(lunchClr == inactiveBoxClr){
        lunchClr = activeBoxClr;
        breakfastClr = inactiveBoxClr;
      }
      else{
        lunchClr = inactiveBoxClr;
      }
    }
  }

  submitData() async{
    if(category == null){
      return Alert(
        context: context,
        title: "Select Category",
        buttons: [
          DialogButton(
            color: Colors.red,
            child: Text("Ok"),
            onPressed: (){
              Navigator.pop(context);
            },
          )
        ],
      ).show();
    }
    else{
      await requestRef.add({
        "date": date,
        "category": category,
        "requestmaker":currentUser?.displayName,
        "useremail": currentUser?.email,
      });

      setState(() {
        CupertinoAlertDialog(
          title:Text("Request Sent"),
          actions: <Widget>[FlatButton(child: Text("Ok"),),],

        );
        lunchClr = inactiveBoxClr;
        breakfastClr = inactiveBoxClr;
      });
      return Alert(
        context: context,
        title: "Daana Request",
        desc: "Daana Request Submitted",
        buttons: [
          DialogButton(
            color: Colors.redAccent,
            child: Text("Ok"),
            onPressed: (){
              Navigator.pop(context);
            },
          )
        ],
      ).show();
    }


  }

  @override
  Widget build(BuildContext context) {
    final curScaleFactor = MediaQuery.of(context).textScaleFactor;
    SizeConfig().init(context);
    return Scaffold(

      body: CupertinoScrollbar(

        child: ListView(
          children: <Widget>[

            Container(

              height:  MediaQuery.of(context).size.height*0.6,
                child: ScreenCalendar(),
            ),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topRight: Radius.circular(25.0),topLeft: Radius.circular(25.0)),
                color: Colors.red[400],
              ),
              child: Column(
                children: <Widget>[

                  Container(
                    margin: EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height*0.12,
                      width: SizeConfig.blockSizeHorizontal * 80,
                      child: CupertinoDatePicker(
                        backgroundColor: Colors.red[400],
                        initialDateTime: _dateTime,
                        mode: CupertinoDatePickerMode.date,
                        onDateTimeChanged: (dateTime) {
                          date = dateTime;
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.blockSizeHorizontal*5,
                  ),
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: SizeConfig.blockSizeHorizontal*5,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: (){
                            category = "Breakfast";
                            setState(() {
                              updateClr(1);
                            });
                          },
                          child: Container(
                            height: SizeConfig.blockSizeVertical*15,
                            width: SizeConfig.blockSizeHorizontal*9,
                            margin: EdgeInsets.all(3.0),
                            decoration: BoxDecoration(
                              color: breakfastClr,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.free_breakfast,
                                  color: Colors.white,
                                  size: SizeConfig.blockSizeVertical*10,
                                ),
                                Center(child: Text("Breakfast",
                                  style: TextStyle(
                                      color: Colors.white
                                  ),)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: (){
                            category = "Lunch";
                            setState(() {
                              updateClr(2);
                            });
                          },
                          child: Container(
                            height: SizeConfig.blockSizeVertical*15,
                            width: SizeConfig.blockSizeHorizontal*9,
                            margin: EdgeInsets.all(3.0),
                            decoration: BoxDecoration(
                              color: lunchClr,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.fastfood,
                                  color: Colors.white,
                                  size: SizeConfig.blockSizeVertical*10,
                                ),
                                Center(child: Text("Lunch",
                                  style: TextStyle(
                                      color: Colors.white
                                  ),)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: SizeConfig.blockSizeHorizontal*5,
                      ),
                    ],
                  ),

                  GestureDetector(
                    onTap:submitData,
                    child: Container(
                      color: Colors.red[900],
                      margin: EdgeInsets.only(top: 10.0),
                      width: double.infinity,
                      height: SizeConfig.blockSizeVertical*10,
                      child: Center(
                        child: new Text(
                          "Submit",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
