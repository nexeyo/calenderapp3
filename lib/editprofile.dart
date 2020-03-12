import 'package:calenderapp/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';


final usersRef = Firestore.instance.collection('users');



class EditProfile extends StatefulWidget {


  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {



  TextEditingController displayNameController = TextEditingController();
  TextEditingController mobileNoController = TextEditingController();
  bool _mobileValid = true;
  bool _displayNameValid = true;

  String userName;
  String mobile;
  String email;
  String photoUrl;
  String usersId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //_getUserAuth();
    getUserData();
    CircularProgressIndicator();
  }

  getUserData()async{
    displayNameController.text = currentUser?.displayName;
    mobileNoController.text = currentUser?.mobile;

  }

  updateProfData(){
    setState(() {
      displayNameController.text.trim().length < 3 ||
      displayNameController.text.isEmpty ? _displayNameValid = false :
          _displayNameValid = true;
      mobileNoController.text.trim().length > 10 ? _mobileValid = false :
          _mobileValid = true;
    });

    if(_displayNameValid && _mobileValid){
      usersRef.document(currentUser?.id).updateData({
        "displayName" : displayNameController.text,
        "mobile" : mobileNoController.text,

      });
    }
    return Alert(
      context: context,
      title: "User Profile",
      desc: "Mobile Number Updated",
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



  @override
  Widget build(BuildContext context) {

    final curScaleFactor = MediaQuery.of(context).textScaleFactor;
    return ListView(
      children: <Widget>[
        Container(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 32.0,bottom: 8.0),
                child: CircleAvatar(
                  radius: 50.0,
                  backgroundImage: NetworkImage(currentUser?.photoUrl),
                  backgroundColor: Colors.transparent,
                ),
//              child: Text(currentUser?.id),
                ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0,right: 16.0),
                child: Column(
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(top: 12.0),
                      child: Text("Display Name",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    TextField(
                      controller: displayNameController,
                      decoration: InputDecoration(
                        hintText: "Update Name",
                        errorText: _displayNameValid ? null : "Display Name Too Short",
                        border: new OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0,right: 16.0),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 12.0),
                      child: Text("Mobile No",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    TextField(
                      controller: mobileNoController,
                      decoration: InputDecoration(
                        errorText: _mobileValid ? null : "Invalid Mobile Number",
                        hintText: "Enter Your Mobile No",
                        border: new OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  color: Theme.of(context).primaryColor,
                  onPressed: updateProfData,
                  child: Text(
                    "Update Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20 * curScaleFactor *0.8,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),

      ],
    );
  }
}
