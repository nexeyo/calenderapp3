import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'size_config.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

final reqRef =  Firestore.instance.collection('requests');
final acceptedRef = Firestore.instance.collection('acceptedreqs');

String approvedUser;
String userMail;
String rejectedUserMail;
DateTime danaDate;
String dana_category;
String requestID;
String approvedDanaDate;
String rejectedDanaDate;
String subject;
String body;

class RecievedReq extends StatefulWidget {

  @override
  _RecievedReqState createState() => _RecievedReqState();
}

class _RecievedReqState extends State<RecievedReq> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;



  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Dana Requests"),
      ),
      body: StreamBuild(),
//
    );
  }
}




class StreamBuild extends StatefulWidget {

  const StreamBuild({Key key, this.requests}) : super(key: key);
  final FirebaseUser requests;

  @override
  _StreamBuildState createState() => _StreamBuildState();
}

class _StreamBuildState extends State<StreamBuild> {

  sendApprovalMail(String bdy,String sub,String mail) async {

    String username = 'cdfevent688@gmail.com';
    String password = 'EventApp688';

    final smtpServer = gmail(username, password);
    // Creating the Gmail server

    // Create our email message.
    final message = Message()
      ..from = Address(username, 'CDF EVENTS')
      ..recipients.add(mail) //recipient email
      ..subject = sub //subject of the email
      ..text = bdy; //body of the email

    try {
      await send(message, smtpServer);


    } on MailerException catch (e) {
    }

  }

  sendRejectionMail(String bdy,String sub,String mail) async {

    String username = 'cdfevent688@gmail.com';
    String password = 'EventApp688';

    final smtpServer = gmail(username, password);
    // Creating the Gmail server

    // Create our email message.
    final message = Message()
      ..from = Address(username, 'CDF EVENTS')
      ..recipients.add(mail) //recipient email
      ..subject = sub //subject of the email
      ..text = bdy; //body of the email

    try {
       await send(message, smtpServer);


    } on MailerException catch (e) {

    }

  }

  @override
  Widget build(BuildContext context) {
    final curScaleFactor = MediaQuery.of(context).textScaleFactor;
    return StreamBuilder<QuerySnapshot>(
      stream: reqRef.where("date", isGreaterThanOrEqualTo: new DateTime.now()).orderBy('date', descending: false).snapshots(),
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
              padding: const EdgeInsets.only(top: 15.0),
              child: new ListView(
                children: snapshot.data.documents.map((DocumentSnapshot document) {

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

                      Column(
                        children: <Widget>[
                          Card(
                            child: Row(
                              children: <Widget>[

                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                    child: Container(
                                      width: SizeConfig.blockSizeHorizontal * 17,
                                      child: AutoSizeText(
                                        DateFormat.yMMMd().format(DateTime.parse((document['date']).toDate().toString())),
                                        //parseDate(document['date']),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontFamily: 'SFUIDisplay',
                                          //fontSize: SizeConfig.blockSizeHorizontal * 5,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    width: SizeConfig.blockSizeHorizontal * 16,
                                    child: AutoSizeText(
                                      document['category'],
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(
                                        fontFamily: 'SFUIDisplay',
                                        //fontSize: SizeConfig.blockSizeHorizontal * 5,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    width: SizeConfig.blockSizeHorizontal * 16,
                                    child: Text(
                                      document['requestmaker'],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'SFUIDisplay',
                                        //fontSize: SizeConfig.blockSizeHorizontal * 5,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),

                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(0.0),
                                    child: RaisedButton(
                                      onPressed: () async{
                                        danaDate = document['date'].toDate();
                                        dana_category = document['category'];
                                        approvedUser = document['requestmaker'];
                                        rejectedUserMail = document['useremail'];
                                        requestID = document.documentID;
                                        rejectedDanaDate = DateFormat.yMMMd().format(DateTime.parse((document['date']).toDate().toString()));
                                        subject="Daana Request";
                                        body = "Sorry. Due to having multiple daana requests your Daana request for"
                                            " "+dana_category+" daana on "+rejectedDanaDate+" hasn't been approved. "
                                            "Please be kind enough to request for another day.\n\n Thank you\n CDF Events";

                                        sendRejectionMail(body,subject,rejectedUserMail);
                                        reqRef.document(requestID).delete();

                                      },
                                      child: FittedBox(
                                        child: AutoSizeText( 'Delete',
                                          style: TextStyle(fontSize: 20*curScaleFactor,fontFamily: 'SFUIDisplay',),
                                          maxLines: 1,
                                        ),
                                      ),
                                      color: Colors.red,
                                      textColor: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: SizeConfig.blockSizeHorizontal*1,
                                ),
                                //Text(snapshot.data[index].data["date"]),
                                Expanded(
                                  child: RaisedButton(
                                    onPressed: () async{
                                      danaDate = document['date'].toDate();
                                      dana_category = document['category'];
                                      approvedUser = document['requestmaker'];
                                      userMail = document['useremail'];
                                      requestID = document.documentID;
                                      approvedDanaDate = DateFormat.yMMMd().format(DateTime.parse((document['date']).toDate().toString()));

                                      subject="Daana Request";
                                      body = "Your Daana request for "+dana_category+" daana on "+approvedDanaDate+" has been approved.\n\n Thank you\n CDF Events";

                                      //print(userMail);

                                      await acceptedRef.add({
                                        "dana_category": dana_category,
                                        "date": danaDate,
                                        "name": approvedUser,
                                        "email": userMail,
                                      });

                                      sendApprovalMail(body,subject,userMail);

                                      final DocumentSnapshot doc = await reqRef.document(requestID).get();
                                      if(doc.exists){
                                        doc.reference.delete();
                                      }
                                    },
                                    child: FittedBox(
                                      child: AutoSizeText(
                                        'Accept',
                                        style: TextStyle(fontSize: 20*curScaleFactor,fontFamily: 'SFUIDisplay',),
                                        maxLines: 1,
                                      ),
                                    ),
                                    color: Colors.green,
                                    textColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                        //title: Text(snapshot.data[index].data["name"]),
                      ),
                    ],
                  );
                }).toList(),
              ),
            );
        }
      },
    );
  }
  String parseDate(Timestamp time){

//    var format = new DateFormat('d MMM, hh:mm a');
//    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
//    return format.format(date);
    Timestamp timestamp = time;
    DateTime reqDate = timestamp.toDate();
    return reqDate.toString();
  }
}
