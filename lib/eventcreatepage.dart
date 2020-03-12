import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'size_config.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/rendering.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

const Color _colorOne = Color(0x33000000);
const Color _colorTwo = Color(0x24000000);
final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
final GlobalKey<FormState> _taskFormKey = new GlobalKey<FormState>();
String eventName;
String description;
String taskDescription;
String task;
DateTime _dateTime = DateTime.now();
DateTime _times;
DateTime date;
final eventRef = Firestore.instance.collection('eventslist');
final usersRef = Firestore.instance.collection('users');
String eventID, evName, userName, userId;
int count = 1;
final format = DateFormat("HH:mm");
String _time = "Not set";

class CreateEventsPage extends StatefulWidget {
  static String selectedEvent, eventValue;
  static String eventID, evName;

  @override
  _CreateEventsPageState createState() => _CreateEventsPageState();
}

class _CreateEventsPageState extends State<CreateEventsPage> {
  TextEditingController _dateSelected = new TextEditingController();
  submitData() async {
    if (_formKey.currentState.validate()) {

      _formKey.currentState.save();
      await eventRef.add({
        "eventname": eventName,
        "description": description,
        "date": _dateTime,
      });
      _formKey.currentState.reset();
      return Alert(
        context: context,
        title: "CDF Event",
        desc: "Event Created Successfully",
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

  getEventId(String evNm) async {
    final QuerySnapshot snapshot =
        await eventRef.where("eventname", isEqualTo: evNm).getDocuments();
    //DocumentSnapshot snap = snapshot.data.documents;
    //eventID = snapshot.dat
    snapshot.documents.forEach((DocumentSnapshot doc) {
      eventID = doc.documentID;
    });
  }

  submitTasks() async {
    if (_taskFormKey.currentState.validate() && evName != null && userName != null) {
      _taskFormKey.currentState.save();
      await eventRef.document(eventID).collection('tasks').add({
        "eventId": eventID,
        "eventName": evName,
        "userId": userId,
        "userName": userName,
        "task": task,
        "taskTime": _times,
        "taskDetails": taskDescription,
      });
      _taskFormKey.currentState.reset();
      return Alert(
        context: context,
        title: "CDF Event Tasks",
        desc: "Event tasks Created Successfully",
        buttons: [
          DialogButton(
            color: Colors.redAccent,
            child: Text("Ok"),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ).show();
    }
    else{
      return Alert(
        context: context,
        title: "Enter Correct Details",
        buttons: [
          DialogButton(
            color: Colors.red,
            child: Text("Ok"),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ).show();
    }

  }

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

  int sharedValue = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //new List.generate(count, (int i) => new InputWidget(i));
  }

  @override
  Widget build(BuildContext context) {
    final curScaleFactor = MediaQuery.of(context).textScaleFactor;
    Map<int, Widget> bodyWidgets = <int, Widget>{
      0: Text('Events'),
      1: Text('Tasks'),
    };
    Map<int, Widget> icons = <int, Widget>{
      0: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: Container(

              height: SizeConfig.blockSizeVertical * 60,
              child: Form(
                  key: _formKey,
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding:
                            const EdgeInsets.all(4.0),
                            child: Center(child: Text("Enter Your Event Details Here")),
                          ),
                          new Padding(
                            padding:
                                const EdgeInsets.only(bottom: 8.0, top: 1.0),
                            child: new TextFormField(
                              onSaved: (val) => eventName = val,
                              decoration: new InputDecoration(
                                labelText: "Event Name",
                                border: new OutlineInputBorder(),
                              ),
                              validator: (val) => val.length < 5
                                  ? "Event name is too short"
                                  : null,
                            ),
                          ),
                          SizedBox(
                            height: SizeConfig.blockSizeVertical * 2,
                          ),
                          GestureDetector(
                            onTap: () => selectDate(context),
                            child: AbsorbPointer(
                              child: TextFormField(
                                controller: _dateSelected,
                                keyboardType: TextInputType.datetime,
                                decoration: InputDecoration(
                                  border: new OutlineInputBorder(),
                                  hintText: 'Event Date',
                                  suffixIcon: Icon(
                                    Icons.dialpad,
                                    color: Colors.redAccent,
                                  ),
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            height: SizeConfig.blockSizeVertical * 2,
                          ),
                          Expanded(
                            child: Container(
                              child: new TextFormField(

                                onSaved: (val) => description = val,
                                textInputAction: TextInputAction.newline,
                                //keyboardType: TextInputType.multiline,
                                decoration: new InputDecoration(
                                  labelText: "Description",
                                  border: new OutlineInputBorder(),
                                ),
                                validator: (val) => val.isEmpty
                                    ? "Event description should not be empty"
                                    : null,
                                maxLines: 99,
                                //onSaved: (val) => _description = val,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
            ),
          ),
          Container(
            child: GestureDetector(
              onTap: submitData,
              child: Container(
                color: Colors.red[900],
                margin: EdgeInsets.only(top: 10.0, bottom: 0.0),
                width: double.infinity,
                height: SizeConfig.blockSizeVertical * 10,
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
          ),
        ],
      ),
      1: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: Container(
              height: SizeConfig.blockSizeVertical * 80,
              child: Form(
                key: _taskFormKey,
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: new Column(
                      children: <Widget>[
                        Container(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: eventRef
                                .where("date",
                                    isGreaterThanOrEqualTo: new DateTime.now())
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                // ignore: missing_return
                                return Text("Loading");
                              } else {
                                List<DropdownMenuItem> eventsList = [];
                                for (int i = 0;
                                    i < snapshot.data.documents.length;
                                    i++) {
                                  DocumentSnapshot snap =
                                      snapshot.data.documents[i];
                                  eventsList.add(DropdownMenuItem(
                                    child: Text(
                                      DateFormat.MMMd().format(DateTime.parse(
                                              (snap['date'])
                                                  .toDate()
                                                  .toString())) +
                                          "--" +
                                          snap['eventname'],
                                    ),
                                    value: snap['eventname'],
                                  ));
                                }
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    AutoSizeText(
                                      "Event",
                                      style: TextStyle(
                                          fontSize:
                                              SizeConfig.blockSizeHorizontal *
                                                  6),
                                    ),
                                    SizedBox(
                                      height: SizeConfig.blockSizeVertical * 1,
                                    ),
                                    Container(
                                      width:
                                          MediaQuery.of(context).size.width * 1,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 5),
                                      decoration: BoxDecoration(
                                          color: Colors.redAccent[100],
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton(
                                          items: eventsList,
                                          onChanged: (value) {
                                            setState(() {
                                              evName = value;
                                              //eventRef.where("eventname", isEqualTo: evName).snapshots();
                                              //DocumentSnapshot snap = sna
                                              getEventId(evName);
                                            });
                                          },
                                          value: evName,
                                          hint: Text("Select Event"),
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          height: SizeConfig.blockSizeVertical * 2,
                        ),
                        Container(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: usersRef.snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                // ignore: missing_return
                                return Text("Loading");
                              } else {
                                List<DropdownMenuItem> usersList = [];
                                for (int i = 0;
                                    i < snapshot.data.documents.length;
                                    i++) {
                                  DocumentSnapshot snap =
                                      snapshot.data.documents[i];
                                  userId = snap.documentID;
                                  usersList.add(DropdownMenuItem(
                                    child: Text(
                                      snap['displayName'],
                                    ),
                                    value: snap['displayName'],
                                  ));
                                }
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Text(
                                      "User",
                                      style: TextStyle(
                                          fontSize:
                                              SizeConfig.blockSizeHorizontal *
                                                  6),
                                    ),
                                    SizedBox(
                                      height: SizeConfig.blockSizeVertical * 1,
                                    ),
                                    Container(
                                      width:
                                          MediaQuery.of(context).size.width * 1,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 5),
                                      decoration: BoxDecoration(
                                          color: Colors.redAccent[100],
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton(
                                          items: usersList,
                                          onChanged: (value) {
                                            setState(() {
                                              userName = value;
                                            });
                                          },
                                          value: userName,
                                          hint: Text("Select User"),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          height: SizeConfig.blockSizeVertical * 2,
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Enter Task",
                              style: TextStyle(
                                  fontSize:
                                  SizeConfig.blockSizeHorizontal *
                                      6),
                            ),
                            Container(
                              child: TextFormField(
                                decoration: new InputDecoration(
                                  labelText: "Event Task",
                                  border: new OutlineInputBorder(),
                                ),
                                validator: (val) => val.isEmpty
                                    ? "Event tasks should not be empty"
                                    : null,
                                onSaved: (val) => task = val,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: SizeConfig.blockSizeVertical * 2,
                        ),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                          Text(
                            "Select Time",
                            style: TextStyle(
                                fontSize:
                                SizeConfig.blockSizeHorizontal *
                                    6),
                          ),
                          RaisedButton(

                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                            elevation: 4.0,
                            onPressed: () {
                              DatePicker.showTimePicker(context,
                                  theme: DatePickerTheme(
                                    containerHeight: MediaQuery.of(context).size.height*0.3,
                                  ),
                                  showTitleActions: true, onConfirm: (time) {
                                    //_time = '${time.hour} : ${time.minute} : ${time.second}';
                                    setState(() {
                                      _time = '${time.hour} : ${time.minute}';
                                      _times = time;
                                    });
                                  }, currentTime: DateTime.now(), locale: LocaleType.en);
                              setState(() {

                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        child: Row(
                                          children: <Widget>[
                                            Icon(
                                              Icons.access_time,
                                              size: MediaQuery.of(context).size.height*0.03,
                                              color: Colors.redAccent,
                                            ),
                                            Text(
                                              " $_time",
                                              style: TextStyle(
                                                  color: Colors.red[700],
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20 * curScaleFactor),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  Text(
                                    "  Change",
                                    style: TextStyle(
                                        color: Colors.red[700],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20 * curScaleFactor),
                                  ),
                                ],
                              ),
                            ),
                            color: Colors.white,
                          )
                        ]),
                        SizedBox(
                          height: SizeConfig.blockSizeVertical * 2,
                        ),
                        Expanded(
                          child: Container(
                            child: new TextFormField(
                              onSaved: (val) => taskDescription = val,
                              textInputAction: TextInputAction.newline,
                              keyboardType: TextInputType.multiline,
                              decoration: new InputDecoration(
                                labelText: "Task Description",
                                border: new OutlineInputBorder(),
                              ),
                              validator: (val) => val.isEmpty
                                  ? "Task Description should not be empty"
                                  : null,
                              maxLines: null,
                              //onSaved: (val) => _description = val,
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            child: GestureDetector(
              onTap: submitTasks,
              child: Container(
                color: Colors.red[900],
                margin: EdgeInsets.only(top: 10.0, bottom: 0.0),
                width: double.infinity,
                height: SizeConfig.blockSizeVertical * 10,
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
          ),
        ],
      ),
    };

    return Scaffold(
        appBar: AppBar(
          title: Text("Create Events"),
        ),
        backgroundColor: Colors.red[400],
        body: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(8.0),
            ),
            SizedBox(
              width: double.infinity,
              child: CupertinoSegmentedControl<int>(
                padding: EdgeInsets.all(1.0),
                selectedColor: Colors.red[800],
                borderColor: Colors.red[800],
                children: bodyWidgets,
                onValueChanged: (int val) {
                  setState(() {
                    sharedValue = val;
                  });
                },
                groupValue: sharedValue,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 1.0,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 1.0,
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(3.0),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        offset: Offset(0.0, 3.0),
                        blurRadius: 5.0,
                        spreadRadius: -1.0,
                        color: _colorOne,
                      ),
                      BoxShadow(
                        offset: Offset(0.0, 6.0),
                        blurRadius: 10.0,
                        spreadRadius: 0.0,
                        color: _colorTwo,
                      ),
                    ],
                  ),
                  child: icons[sharedValue],
                ),
              ),
            ),
          ],
        ));
  }
}

