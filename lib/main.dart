import 'package:calenderapp/dashboard.dart';
import 'package:calenderapp/home.dart';
import 'package:calenderapp/usermodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'flutter_calendar_carousel.dart';
import 'recievedreq.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'size_config.dart';
import 'calender.dart';
import 'editprofile.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final usersref = Firestore.instance.collection('users');
User currentUser;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xff9b0000),
        accentColor: Color(0xffffa000),
      ),
      title: 'CDF EVENTS',
      home: LoginRoot(),

    );
  }
}

class LoginRoot extends StatefulWidget {
  @override
  _LoginRootState createState() => _LoginRootState();
}

class _LoginRootState extends State<LoginRoot> {
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;
  String adminID;
  String currentUserID;

  //check there is existing user, else create new account
  createUserInFirestore() async {
    //check if user exits in users collection according to their id
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersref.document(user.id).get();
    currentUserID = user.id;

    if (!doc.exists) {
      //final mobile = await Navigator.push(context, MaterialPageRoute(builder: (context) => Register()),);

      //get username from that and use to create new user doc in db
      usersref.document(user.id).setData({
        "id": user.id,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "role": false,
        "mobile":""
      });
      doc = await usersref.document(user.id).get();
    }
    currentUser = User.fromDocument(doc);
  }

  //get the userid of admin
  adminDetails() async {
    final QuerySnapshot snapshot =
    await usersref.where("role", isEqualTo: true).getDocuments();

    snapshot.documents.forEach((DocumentSnapshot doc) {
      adminID = doc.documentID;
    });
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Scaffold buildAuthScreen() {
    return roleBasedScaffold(adminID, currentUserID);
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
        body: SafeArea(

            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/redaccent.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(bottomRight: Radius.circular(25.0),bottomLeft: Radius.circular(25.0)),
                      color: Colors.white,
                    ),

                    height: MediaQuery.of(context).size.height*0.4,

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: SizeConfig.blockSizeHorizontal * 250,
                          height: SizeConfig.blockSizeVertical * 20,
                          margin: const EdgeInsets.only(top: 20.0),
                          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                          child: Image(
                            image: AssetImage("images/icon.png"),
                          ),
                        ),
                        Text(
                          "CDF",
                          style: TextStyle(
                            fontSize: SizeConfig.blockSizeHorizontal * 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Playfair Display SC',
                            color: Colors.black,
                          ),
                        ),


                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 10.0),
                    child: Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[

                          Text(
                            "EVENTS",
                            style: TextStyle(
                              fontSize: SizeConfig.blockSizeHorizontal * 15,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Playfair Display SC',
                            ),
                          ),

                          Container(
                            width: SizeConfig.blockSizeHorizontal * 60,
                            height: SizeConfig.blockSizeVertical * 8,
                            margin: const EdgeInsets.only(top: 20.0),
                            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                            child: FlatButton(
                              shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(30.0)),
                              splashColor: Colors.red,
                              color: Theme.of(context).primaryColor,
                              child: Text(
                                "LOGIN",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Playfair Display SC',
                                  fontSize: SizeConfig.blockSizeVertical * 4
                                ),
                              ),
                              onPressed: login,
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: MediaQuery.of(context).size.height*0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageController = PageController();

    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
    });

    //Re authenticate when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }, onError: (err) {
    });

    adminDetails();

    @override
    Future<Widget> build(BuildContext context) async {
      SizeConfig().init(context);
      return isAuth ? buildAuthScreen() : buildUnAuthScreen();
    }
  }

  handleSignIn(GoogleSignInAccount account) {
    if (account != null) {
      createUserInFirestore();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  Widget checkRolesRoute(adID, cuserID) {
    if (adID == cuserID) {
      return PageView(
        children: <Widget>[
          Home('Home'),
          Calender(),
          Dashboard(),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      );
    } else {
      return PageView(
        children: <Widget>[
          Home('Home'),
          Calender(),
          EditProfile(),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      );
    }
  }

  Widget checkRolesBottomNavi(adID, cuserID) {
    if (adID == cuserID) {
      return CupertinoTabBar(
          backgroundColor: Colors.white,
          currentIndex: pageIndex,
          onTap: onTap,
          activeColor: Theme.of(context).primaryColor,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.create),
            ),
          ]);
    } else {
      return CupertinoTabBar(
          backgroundColor: Colors.white,
          currentIndex: pageIndex,
          onTap: onTap,
          activeColor: Theme.of(context).primaryColor,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
            ),
          ]);
    }
  }

  Scaffold roleBasedScaffold(adminID, currentUID) {
    if (adminID == currentUID) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'CDF Events',
            style: TextStyle(),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: logout,
                  child: Icon(
                    Icons.exit_to_app,
                    size: 26.0,
                  ),
                )),
          ],
        ),
        body: PageView(
          children: <Widget>[
            Home('Home'),
            Calender(),
            Dashboard(),
          ],
          controller: pageController,
          onPageChanged: onPageChanged,
          physics: NeverScrollableScrollPhysics(),
        ),
        bottomNavigationBar: CupertinoTabBar(
            backgroundColor: Colors.white,
            currentIndex: pageIndex,
            onTap: onTap,
            activeColor: Theme.of(context).primaryColor,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.create),
              ),
            ]),
      );
    }
    else{
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'CDF Events',
            style: TextStyle(),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: logout,
                  child: Icon(
                    Icons.exit_to_app,
                    size: 26.0,
                  ),
                )),
          ],
        ),
        body: PageView(
          children: <Widget>[
            Home('Home'),
            Calender(),
            //ChatScreen(),
            EditProfile(),
          ],
          controller: pageController,
          onPageChanged: onPageChanged,
          physics: BouncingScrollPhysics(),
        ),
        bottomNavigationBar: CupertinoTabBar(
            backgroundColor: Colors.white,
            currentIndex: pageIndex,
            onTap: onTap,
            activeColor: Theme.of(context).primaryColor,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
              ),
            ]),
      );
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
