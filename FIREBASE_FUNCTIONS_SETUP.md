# Firebase Cloud Functions Setup Guide

## Step 1: Install Firebase CLI
```bash
npm install -g firebase-tools
```

## Step 2: Login to Firebase
```bash
firebase login
```

## Step 3: Initialize Cloud Functions
Navigate to your project root directory and run:
```bash
cd c:\Users\Nziza Donatien\Documents\potato-diseases-detection
firebase init functions
```

Select:
- Choose your existing project: `potato-disease-811da`
- Language: JavaScript or TypeScript (JavaScript is simpler)
- ESLint: Yes
- Install dependencies: Yes

## Step 4: Create the Cloud Function
Open `functions/index.js` and add this code:

```javascript
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Send notification when a new notification document is created
exports.sendNotification = functions.firestore
    .document("notifications/{notificationId}")
    .onCreate(async (snap, context) => {
      const data = snap.data();
      
      // Skip if already sent
      if (data.sent) {
        return null;
      }

      const message = {
        token: data.token,
        notification: {
          title: data.title,
          body: data.body,
        },
        data: data.data,
        android: {
          priority: "high",
          notification: {
            sound: "default",
            channelId: "default_channel",
          },
        },
      };

      try {
        await admin.messaging().send(message);
        
        // Mark as sent
        await snap.ref.update({sent: true, sentAt: admin.firestore.FieldValue.serverTimestamp()});
        
        console.log("Notification sent successfully");
        return null;
      } catch (error) {
        console.error("Error sending notification:", error);
        await snap.ref.update({error: error.message});
        return null;
      }
    });

// Send notification when new chat message is created
exports.notifyNewChatMessage = functions.firestore
    .document("chats/{chatId}/messages/{messageId}")
    .onCreate(async (snap, context) => {
      const message = snap.data();
      const chatId = context.params.chatId;
      
      // Get receiver's FCM token
      const receiverDoc = await admin.firestore()
          .collection("users")
          .doc(message.receiverId)
          .get();
      
      if (!receiverDoc.exists) {
        return null;
      }

      const receiverToken = receiverDoc.data().fcmToken;
      if (!receiverToken) {
        return null;
      }

      // Get sender's name
      const senderDoc = await admin.firestore()
          .collection("users")
          .doc(message.senderId)
          .get();
      
      const senderName = senderDoc.exists ? senderDoc.data().fullName : "Someone";

      const fcmMessage = {
        token: receiverToken,
        notification: {
          title: `New message from ${senderName}`,
          body: message.message,
        },
        data: {
          type: "chat_message",
          senderId: message.senderId,
          chatId: chatId,
        },
        android: {
          priority: "high",
        },
      };

      try {
        await admin.messaging().send(fcmMessage);
        console.log("Chat notification sent");
        return null;
      } catch (error) {
        console.error("Error sending chat notification:", error);
        return null;
      }
    });
```

## Step 5: Deploy Cloud Functions
```bash
firebase deploy --only functions
```

## Step 6: Enable Firebase Cloud Messaging API
1. Go to Firebase Console: https://console.firebase.google.com/
2. Select your project: `potato-disease-811da`
3. Go to Project Settings > Cloud Messaging
4. Enable Cloud Messaging API (V1)

## Step 7: Test Notifications
1. Run your Flutter app
2. Complete a scan as a farmer
3. Check if notifications appear
4. Check Firebase Console > Functions > Logs to see if functions are executing

## Troubleshooting

### If notifications don't work:
1. Check Firebase Console > Functions > Logs for errors
2. Verify FCM tokens are being saved in Firestore users collection
3. Make sure Cloud Messaging API is enabled
4. Check Android notification permissions are granted

### Common Issues:
- **Token not found**: User hasn't logged in after notification initialization
- **Permission denied**: Check Firebase Security Rules
- **Function timeout**: Increase function memory/timeout in Firebase Console

## Firebase Security Rules (Optional)
Add these rules in Firestore Rules to secure notifications:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /notifications/{notificationId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Cost Considerations
- Cloud Functions: First 2M invocations/month are free
- FCM: Free for unlimited messages
- This setup should stay within free tier for small-medium usage

## Next Steps
After deployment:
1. Test all notification types (scan complete, advice request, chat)
2. Monitor Firebase Console logs
3. Adjust notification content as needed
