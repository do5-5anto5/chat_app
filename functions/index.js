const {onDocumentCreated} = require('firebase-functions/v2/firestore');
const admin = require('firebase-admin');

admin.initializeApp();

exports.myFunction = onDocumentCreated('chat/{messageId}', (event) => {
  const snapshot = event.data;

  if (!snapshot) {
    console.log('No data associated with the event');
    return;
  }

  return admin.messaging().send({
    notification: {
      title: snapshot.data()['username'],
      body: snapshot.data()['text'],
    },
    data: {
      click_action: 'FLUTTER_NOTIFICATION_CLICK',
    },
    topic: 'chat',
  });
});