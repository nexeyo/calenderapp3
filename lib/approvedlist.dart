import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'size_config.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:auto_size_text/auto_size_text.dart';

final acceptedRef = Firestore.instance.collection('acceptedreqs');


String approvedUser;
String approvedUserMail;
DateTime danaDate;
String dana_category;
String requestID;
String daana_date;
String subject;
String body;

class ApprovedList extends StatefulWidget {
  @override
  _ApprovedListState createState() => _ApprovedListState();
}

class _ApprovedListState extends State<ApprovedList> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Approved List"),
      ),
      body: ApprovedListBuild(),
    );
  }
}

class ApprovedListBuild extends StatefulWidget {
  @override
  _ApprovedListBuildState createState() => _ApprovedListBuildState();
}

class _ApprovedListBuildState extends State<ApprovedListBuild> {


   sendMail(String bdy,String sub,String mail) async {

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
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
      return Alert(
        context: context,
        title: "Email Sent",
        buttons: [
          DialogButton(
            color: Colors.redAccent,
            child: Text("Ok"),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ).show();//print if the email is sent

    } on MailerException catch (e) {
      print('Message not sent. \n'+ e.toString()); //print if the email is not sent
      // e.toString() will show why the email is not sending
    }

  }


  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(
      stream: acceptedRef.where("date", isGreaterThanOrEqualTo: new DateTime.now()).orderBy('date', descending: false).snapshots(),
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
//                return new ListTile(
//                  title: new Text(document['name']),
//                  subtitle: new Text(document['dana_category']),
//                );
                  return Column(
                    children: <Widget>[
                      Card(
                        child: Row(
                          children: <Widget>[

                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                child: Container(
                                  width: SizeConfig.blockSizeHorizontal * 17,
                                  child: Text(
                                    DateFormat.yMMMd().format(DateTime.parse((document['date']).toDate().toString())),
                                    //parseDate(document['date']),
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontFamily: 'SFUIDisplay',
                                      //fontSize: SizeConfig.blockSizeHorizontal * 5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                width: SizeConfig.blockSizeHorizontal * 16,
                                child: Text(
                                  document['dana_category'],
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
                                  document['name'],
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


                            //Text(snapshot.data[index].data["date"]),
                            Expanded(
                              child: RaisedButton(
                                onPressed: () async{
                                  daana_date = DateFormat.yMMMd().format(DateTime.parse((document['date']).toDate().toString()));
                                  dana_category = document['dana_category'];
                                  approvedUser = document['name'];
                                  approvedUserMail = document['email'];
                                  requestID = document.documentID;
                                  subject="Daana Request";
                                  body = "This is a kind reminder for your daana request for "+dana_category+" on "+daana_date+".";


                                  sendMail(body,subject,approvedUserMail);
                                },
                                child: const Text('Notify', style: TextStyle(fontSize: 15,fontFamily: 'SFUIDisplay',)),
                                color: Colors.lightBlue,
                                textColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                    //title: Text(snapshot.data[index].data["name"]),
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
