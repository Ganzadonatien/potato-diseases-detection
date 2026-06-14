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
        const update = {
          sent: true,
          sentAt: admin.firestore.FieldValue.serverTimestamp(),
        };
        await snap.ref.update(update);

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

      const senderName = senderDoc.exists ?
        senderDoc.data().fullName : "Someone";

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
