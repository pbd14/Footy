const schedule = require('node-schedule');
const admin = require("firebase-admin");
const serviceAccount = require("./footy-335d6-firebase-adminsdk-4qx1j-e83a7b5db8.json");

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});
const db = admin.firestore();


schedule.scheduleJob('1', '* * * * * *', () => {
    var date = new Date();
    date.setHours(0, 0, 0, 0);

    // current timestamp in milliseconds
    let ts = Date.now();

    var date_ob = new Date(ts);
    var hNow = date_ob.getHours();
    if (hNow < 10) {
        hNow = '0' + hNow;
    }
    var mNow = date_ob.getMinutes();
    if (mNow < 10) {
        mNow = '0' + mNow;
    }


    db.collection('bookings')
        // .where('status', '!=', 'finished')
        // .where('timestamp_date', '==', Math.round(new Date(date).getTime()/1000))
        .get()
        .then(doc => {
            doc.docs.forEach(document => {
                // console.log(document.data());
                // if(document.data().from){

                // }
                if (document.data().timestamp_date.seconds == Math.round(new Date(date).getTime() / 1000)) {
                    strNow = hNow + ':' + mNow;
                    if (document.data().status == 'unfinished') {
                        if (document.data().from <= strNow && strNow < document.data().to) {
                            console.log(document.data().from);
                            console.log(strNow);
                            console.log(document.data().to)
                            db.collection('bookings').doc(document.id).update(
                                { 'status': 'in process' }
                            )
                            db.collection('users').doc(document.data().userId)
                                .get()
                                .then(
                                    doc => {
                                        var message = {
                                            notification: {
                                                title: "It's time",
                                                body: 'Your booking has started',
                                            },
                                            data: {
                                                screen: "OnEventScreen",
                                            },
                                            token: doc.data().fcm_token
                                        };
                                        admin.messaging().send(message)
                                            .then((response) => {
                                                // Response is a message ID string.
                                                console.log('Successfully sent message:', response);
                                            })
                                            .catch((error) => {
                                                console.log('Error sending message:', error);
                                            });
                                        token = doc.data().fcm_token;
                                    }
                                )


                            console.log('Done');
                        }
                    }


                    else if (document.data().status == 'in process' || document.data().status == 'unfinished') {
                        if (strNow >= document.data().to) {
                            console.log(document.data().from);
                            console.log(strNow);
                            console.log(document.data().to)
                            db.collection('bookings').doc(document.id).update(
                                { 'status': 'finished' }
                            )
                            db.collection('users').doc(document.data().userId)
                                .get()
                                .then(
                                    doc => {
                                        var message = {
                                            notification: {
                                                title: "Rate it",
                                                body: 'Rate your finished booking'
                                            },
                                            data: {
                                                click_action: "OnEventScreen",
                                                booking: doc,
                                            },
                                            token: doc.data().fcm_token
                                        };
                                        admin.messaging().send(message)
                                            .then((response) => {
                                                // Response is a message ID string.
                                                console.log('Successfully sent message:', response);
                                            })
                                            .catch((error) => {
                                                console.log('Error sending message:', error);
                                            });
                                        token = doc.data().fcm_token;
                                    }
                                )
                            console.log('Done');
                        }
                    }
                }

            }
            );
        })
        .catch(err => {
            console.log('SWW');
            process.exit();
        });
});

