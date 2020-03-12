import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'size_config.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

final usersRef = Firestore.instance.collection('users');
String userId;
String subject;
String body;
String userEmail;

class UsersDetails extends StatefulWidget {

  @override
  _UsersDetailsState createState() => _UsersDetailsState();
}

class _UsersDetailsState extends State<UsersDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Users"),
      ),
      body: UsersList(),

    );
  }
}

class UsersList extends StatefulWidget {

  @override
  _UsersListState createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {

  sendDeleteMail(String bdy,String sub,String mail) async {
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
    return StreamBuilder<QuerySnapshot>(
      stream: usersRef.snapshots(),
      builder: (context, snapshot){
        if(snapshot.hasError || !snapshot.hasData){
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        switch(snapshot.connectionState){
          case ConnectionState.waiting: return CircularProgressIndicator();
          default:
            return Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: new ListView(
                children: snapshot.data.documents.map((DocumentSnapshot document) {

                  return Column(
                    children: <Widget>[
                      Card(
                        child: Row(
                          children: <Widget>[

                            Container(

                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: CircleAvatar(
                                radius: MediaQuery.of(context).size.height*0.03,
                                backgroundImage: NetworkImage(document['photoUrl']),
                                backgroundColor: Colors.transparent,
                              ),
                            ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: SizeConfig.blockSizeHorizontal * 16,
                                  child: Text(
                                    document['displayName'],
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
                            ),

                            //Text(snapshot.data[index].data["date"]),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: RaisedButton(
                                onPressed: () async{
                                  userId = document.documentID;
                                  userEmail = document['email'];
                                  subject="CDF Events";
                                  body = "Dear User,\n\n "
                                      "Your CDF Events Account has been deleted by the Admin. \n "
                                      "Thank You";
                                  sendDeleteMail(body,subject,userEmail);
                                  usersRef.document(userId).delete();
                                },
                                child: const Text('Delete', style: TextStyle(fontSize: 15,fontFamily: 'SFUIDisplay',)),
                                color: Colors.red,
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
}

