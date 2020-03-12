import 'package:calenderapp/approvedlist.dart';
import 'package:calenderapp/recievedreq.dart';
import 'package:calenderapp/size_config.dart';
import 'package:calenderapp/users.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'eventcreatepage.dart';

class Dashboard extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(
                height: SizeConfig.blockSizeVertical*40,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      child: GestureDetector(
                        child: Container(
                          height: SizeConfig.blockSizeVertical*25,
                          width: SizeConfig.blockSizeHorizontal*25,
                          margin: EdgeInsets.all(3.0),
                          decoration: BoxDecoration(
                            color: Colors.red[600],
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.event_note,
                                color: Colors.white,
                                size: SizeConfig.blockSizeVertical*10,
                              ),
                              Center(child: Text("Create Events",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: SizeConfig.blockSizeHorizontal*6
                                ),)),
                            ],
                          ),
                        ),
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> CreateEventsPage(),));
                        }
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        child: Container(
                          height: SizeConfig.blockSizeVertical*25,
                          width: SizeConfig.blockSizeHorizontal*25,
                          margin: EdgeInsets.all(3.0),
                          decoration: BoxDecoration(
                            color: Colors.red[600],
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.format_list_bulleted,
                                color: Colors.white,
                                size: SizeConfig.blockSizeVertical*10,
                              ),
                              Center(child: Text("Dana Requests",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: SizeConfig.blockSizeHorizontal*6,
                                ),)),
                            ],
                          ),
                        ),
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> RecievedReq(),));
                          }
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Expanded(
              child: Container(
                height: SizeConfig.blockSizeVertical*40,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      child: GestureDetector(
                        child: Container(
                          height: SizeConfig.blockSizeVertical*25,
                          width: SizeConfig.blockSizeHorizontal*25,
                          margin: EdgeInsets.all(3.0),
                          decoration: BoxDecoration(
                            color: Colors.red[600],
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.format_line_spacing,
                                color: Colors.white,
                                size: SizeConfig.blockSizeVertical*10,
                              ),
                              Center(child: Text("Approved List",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: SizeConfig.blockSizeHorizontal*6,
                                ),)),
                            ],
                          ),
                        ),
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> ApprovedList(),));
                          }
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        child: Container(
                          height: SizeConfig.blockSizeVertical*25,
                          width: SizeConfig.blockSizeHorizontal*25,
                          margin: EdgeInsets.all(3.0),
                          decoration: BoxDecoration(
                            color: Colors.red[600],
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.supervised_user_circle,
                                color: Colors.white,
                                size: SizeConfig.blockSizeVertical*10,
                              ),
                              Center(child: Text("Manage Users",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: SizeConfig.blockSizeHorizontal*6,
                                ),)),
                            ],
                          ),
                        ),
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> UsersDetails(),));
                          }
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

      ),
    );
  }
}
