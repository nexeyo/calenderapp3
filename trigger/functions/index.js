const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);

var msgData;

exports.newEventNotification = functions.firestore.document('eventslist/{uid}').onCreate((snap, context) => {
        msgData = snap.data();
        admin.firestore().collection('devicetokens').get().then((snap) => {
            var tokens = [];
            if (snap.empty) {
                console.log('No Device');
            } else {
                for (var token of snap.docs) {
                    tokens.push(token.data().tokenNo);
                }
                var payload = {
                    "notification": {
                        "title":  msgData.eventname,
                        "body":  msgData.description,
                        "sound": "default"
                    },
                    "data": {
                        "sendername": msgData.eventname,
                        "message": msgData.description
                    }
                }
                return admin.messaging().sendToDevice(tokens, payload).then((response) => {
                    console.log('Pushed them all');
                }).catch((err) => {
                    console.log(err);
                });
            }
        });
    });