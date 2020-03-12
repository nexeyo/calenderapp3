import 'package:calenderapp/size_config.dart';
import 'package:flutter/material.dart';
import 'calender.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;
import 'package:intl/intl.dart';


final eventsRef =  Firestore.instance.collection('eventslist');
final acceptedRef =  Firestore.instance.collection('acceptedreqs');



class ScreenCalendar extends StatefulWidget {
  @override
  _ScreenCalendarState createState() => new _ScreenCalendarState();
}

class _ScreenCalendarState extends State<ScreenCalendar> {
  DateTime _currentDate = DateTime.now();
  static String noEventText = "No event here";
  String calendarText = noEventText;


//   dayRecieved(){
//    return StreamBuilder<QuerySnapshot>(
//      stream: acceptedRef.snapshots(),
//      builder: (context, snapshot){
//        if(snapshot.hasError || !snapshot.hasData){
//          return Padding(
//            padding: const EdgeInsets.all(8.0),
//            child: Center(child: CircularProgressIndicator()),
//          );
//        }
//        switch(snapshot.connectionState){
//          case ConnectionState.waiting: return Text('Loading..');
//          default:
//              children: snapshot.data.documents.map((DocumentSnapshot document) {
//                return DateFormat.y().format(DateTime.parse((document['date']).toDate().toString()));
//              }
//        }
//      },
//    );
//  }

  Future<void> getCalendarEventList() async {
     Firestore.instance.collection("acceptedreqs").snapshots().listen(
            (data) => data.documents.forEach((doc) => _markedDateMap.add(
            new DateTime(int.parse(DateFormat.y().format(DateTime.parse((doc['date']).toDate().toString()))),
                int.parse(DateFormat.M().format(DateTime.parse((doc['date']).toDate().toString()))), int.parse(DateFormat.d().format(DateTime.parse((doc['date']).toDate().toString())))),
            new Event(
                date: new DateTime(int.parse(DateFormat.y().format(DateTime.parse((doc['date']).toDate().toString()))),
                    int.parse(DateFormat.M().format(DateTime.parse((doc['date']).toDate().toString()))), int.parse(DateFormat.d().format(DateTime.parse((doc['date']).toDate().toString())))),
                icon: _eventIcon))

            ));
    setState(() {});
  }

  @override
  void initState(){
    getCalendarEventList();
    super.initState();
  }



  updateEvents(){
    _markedDateMap.add(
        new DateTime(2020, 2, 15),
        new Event(
          date: new DateTime(2020, 2, 15),
          title: 'Event 5',
          icon: _eventIcon,
        ));
  }

  @override
  void dispose(){
    _markedDateMap.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig.blockSizeVertical*60,
      child: CalendarCarousel(
        weekendTextStyle: TextStyle(
          color: Colors.red,
        ),
        weekFormat: false,
        weekDayMargin: EdgeInsets.only(bottom:0.0,top: 0.0),
        weekDayPadding: EdgeInsets.only(top:0.0),
        headerMargin: EdgeInsets.all(0.0),
        selectedDayBorderColor: Colors.red[400],
        markedDatesMap: _markedDateMap,
        selectedDayButtonColor: Colors.deepOrange,
        selectedDayTextStyle: TextStyle(color: Colors.white),
        //todayBorderColor: Colors.redAccent,
        weekdayTextStyle: TextStyle(color: Colors.black),
        height: SizeConfig.blockSizeVertical*40,
        daysHaveCircularBorder: false,
        todayButtonColor: Colors.redAccent,
        locale: 'en',
        selectedDateTime: _currentDate,
        onDayPressed: (DateTime date, List<Event> events) {
          this.setState(() {
            _currentDate = date;
          });
        },
      ),
    );
  }

  void refresh(DateTime date) {
    _currentDate = date;
    print('selected date ' +
        date.day.toString() +
        date.month.toString() +
        date.year.toString() +
        ' ' +
        date.toString());
    if(_markedDateMap.getEvents(new DateTime(date.year, date.month, date.day)).isNotEmpty){
      calendarText = _markedDateMap
          .getEvents(new DateTime(date.year, date.month, date.day))[0]
          .title;
    } else{
      calendarText = noEventText;
    }

  }
}

EventList<Event> _markedDateMap = new EventList<Event>(events: {
});

Widget _eventIcon = new Container(
  decoration: new BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(1000)),
      border: Border.all(color: Colors.blue, width: 2.0)),
  child: new Icon(
    Icons.person,
    color: Colors.amber,
  ),
);