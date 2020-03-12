import 'package:flutter/material.dart';
import 'size_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


final eventRef =  Firestore.instance.collection('eventslist');
final GoogleSignIn googleSignIn = GoogleSignIn();
const Color _colorOne = Color(0x33000000);
const Color _colorTwo = Color(0x24000000);

Map<DateTime, List> _events;

class Home extends StatefulWidget {

  final String title;
  Home(this.title);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Firestore _db = Firestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDeviceToken();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async{
      },
      onLaunch: (Map<String, dynamic> message) async{
      },
      onResume: (Map<String, dynamic> message) async{
      },
    );

    _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(sound: true, badge: true, alert:true )
    );
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
    });


  }

  getDeviceToken() async{
    String deviceToken = await _firebaseMessaging.getToken();

    if (deviceToken != null) {
      var tokens = _db
          .collection('devicetokens')
          .document(deviceToken);

      await tokens.setData({
        'tokenNo': deviceToken,
      });
    }
  }

  logout(){
    googleSignIn.signOut();
  }





  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(

      body: EventStream(),
    );
  }

}

class EventStream extends StatefulWidget {
  @override
  _EventStreamState createState() => _EventStreamState();
}

class _EventStreamState extends State<EventStream> {

  navigateToDesc(DocumentSnapshot desc){
    Navigator.push(context, MaterialPageRoute(builder: (context)=> EventDetails(desc: desc,)));

  }

  //eventRef.orderBy('date', descending: true).snapshots()
  @override
  Widget build(BuildContext context) {
    final curScaleFactor = MediaQuery.of(context).textScaleFactor;
    return StreamBuilder<QuerySnapshot>(
      stream: eventRef.where("date", isGreaterThanOrEqualTo: new DateTime.now()).orderBy('date', descending: false).snapshots(),
      builder: (context, snapshot){
        if(snapshot.hasError || !snapshot.hasData){
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        switch(snapshot.connectionState){
          case ConnectionState.waiting: return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator(

            )),
          );
          default:
            return new ListView(
              children: snapshot.data.documents.map((DocumentSnapshot document) {
              return Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, right: 10.0),
                child: GestureDetector(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height*0.15,
                    child: Material(
                      borderRadius: BorderRadius.circular(24.0 ),
                      elevation: 14.0,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(child: AutoSizeText(
                                  DateFormat.MMMd().format(DateTime.parse((document['date']).toDate().toString())),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: SizeConfig.blockSizeHorizontal*8),
                                  maxLines: 2,

                                )),
                              ),
                              color: Colors.redAccent,
                              height: double.infinity,
                              width: SizeConfig.blockSizeHorizontal*6,
                            ),
                          ),
                          SizedBox(
                            width: SizeConfig.blockSizeHorizontal*5,
                          ),
                          Expanded(
                            child: Container(
                              child: new Text(document['eventname'],style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal*7,
                              ),
                                maxLines: 2,),
                              width: SizeConfig.blockSizeHorizontal*8,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  onTap: () => navigateToDesc(document),
                ),
              );

              }).toList(),
            );
        }
      },
    );
  }
}

class EventDetails extends StatefulWidget {

  final DocumentSnapshot desc;
  EventDetails({this.desc});

  @override
  _EventDetailsState createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  int sharedValue = 0;

  @override
  Widget build(BuildContext context) {
    final curScaleFactor = MediaQuery.of(context).textScaleFactor;

    Map<int, Widget> bodyWidgets = <int, Widget>{
      0: Text('Event Details'),
      1: Text('Responsibilities'),
    };
    Map<int, Widget> icons = <int, Widget>{
      0: ListView(
        children: <Widget>[

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(25.0),bottomLeft: Radius.circular(25.0)),
                  color: Colors.transparent,
                  //border: Border.all(color: Colors.redAccent)
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(

                        color: Colors.redAccent,
                      ),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Center(
                              child: Text(widget.desc.data['eventname'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal*10,
                                color: Colors.white,
                              ),),
                            ),
                          ),
                          SizedBox(
                            height: SizeConfig.blockSizeVertical*2,
                          ),
                        ],
                      ),

                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical*2,
                    ),
                    Container(
                      padding: EdgeInsets.all(5.0),
                      child: Text(widget.desc.data['description'],
                        overflow: TextOverflow.ellipsis,
                        maxLines: 99,
                        style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal*6,),
                        textAlign: TextAlign.justify,

                      ),),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      1: StreamBuilder<QuerySnapshot>(
        stream: eventRef.document(widget.desc.documentID).collection('tasks').orderBy('taskTime', descending: false).snapshots(),
        builder: (context, snapshot){
          if(snapshot.hasError || !snapshot.hasData){
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          switch(snapshot.connectionState){
            case ConnectionState.waiting: return Text('Loading..');
            default:
              return Padding(
                padding: const EdgeInsets.all(1.0),
                child: new ListView(
                  children: snapshot.data.documents.map((DocumentSnapshot document) {
                    return Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Container(
                        height: MediaQuery.of(context).size.height*0.18,
                        child: Material(
                          elevation: 8.0,
                          borderRadius: BorderRadius.circular(14.0),
                          shadowColor: Color(0x802196F3),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: Container(
                                      width : MediaQuery.of(context).size.width*0.25,
                                      child: Center(child: AutoSizeText(
                                        DateFormat.jm().format(DateTime.parse((document['taskTime']).toDate().toString())),
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontSize: SizeConfig.blockSizeHorizontal*7,
                                            fontWeight: FontWeight.w600
                                        ),

                                      )),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 1.0,
                                  color: Colors.black26,
                                  height: MediaQuery.of(context).size.height*0.13,

                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: Container(
                                      width : MediaQuery.of(context).size.width*0.75,
                                      child: Column(
                                        //mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Container(
                                                child: Text(
                                                  document['task'],
                                                  style: TextStyle(
                                                    fontFamily: 'SFUIDisplay',
                                                    fontSize: SizeConfig.blockSizeVertical * 3,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                child: AutoSizeText("Responsible: "+
                                                    document['userName'],
                                                  style: TextStyle(
                                                    fontFamily: 'SFUIDisplay',
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: SizeConfig.blockSizeVertical * 2.5,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                        Expanded(
                                          child: Container(

                                            child: AutoSizeText(
                                              document['taskDetails'],
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontFamily: 'SFUIDisplay',
                                                fontWeight: FontWeight.w400,
                                                fontSize: SizeConfig.blockSizeVertical * 1,
                                                color: Colors.black54,
                                              ),
                                              maxLines: 99,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        )
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
          }
        },
      ),
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("Event Details"),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/red.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
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
                child: icons[sharedValue],
              ),
            ),

          ],
        ),
      ),
    );
  }
}


