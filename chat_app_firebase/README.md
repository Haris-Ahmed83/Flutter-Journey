# Chat App with Firebase

A real-time messaging application built with Flutter and Firebase. This app lets users sign up, find friends, and start conversations — with instant message delivery, read receipts, and image sharing baked right in.

I built this to explore how Firebase handles real-time data at scale and to get hands-on with Firestore's snapshot listeners for a chat-style interface. It's been a solid learning experience around state management, lifecycle handling, and keeping the UI snappy while syncing data in the background.

## What It Does

- **Real-time Messaging** — Messages appear instantly on both sides using Firestore's real-time listeners. No polling, no refresh buttons.
- **Read Receipts** — You can see when your message has been sent, delivered, and read. The blue double-check icon shows up once the other person opens the conversation.
- **Image Sharing** — Pick photos from your gallery, they get uploaded to Firebase Storage and sent as image messages with a nice cached preview.
- **User Search** — Find other users by name or email and start a new conversation in one tap.
- **Online/Offline Status** — See who's currently active with a green dot indicator, plus "last seen" timestamps for offline users.
- **Push Notifications** — Firebase Cloud Messaging is wired up so users get notified when they receive new messages, even when the app is in the background.
- **Unread Count Badges** — The chat list shows unread message counts so you know which conversations need attention.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.38+ |
| Authentication | Firebase Auth (Email/Password) |
| Database | Cloud Firestore |
| File Storage | Firebase Storage |
| Notifications | Firebase Cloud Messaging |
| Image Handling | image_picker, cached_network_image |
| Utilities | timeago, uuid, intl |

## Project Structure

```
lib/
├── main.dart                    # App entry point with auth state listener
├── models/
│   ├── user_model.dart          # User profile data model
│   ├── message_model.dart       # Message with type, status, timestamps
│   └── chat_room_model.dart     # Chat room with participants & metadata
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart    # Email/password sign in
│   │   └── signup_screen.dart   # New account registration
│   ├── home_screen.dart         # Chat list with real-time updates
│   ├── chat_screen.dart         # Conversation view with message input
│   └── search_screen.dart       # Find and start chats with other users
├── services/
│   ├── auth_service.dart        # Firebase Auth wrapper
│   ├── chat_service.dart        # Firestore messaging logic
│   ├── notification_service.dart # FCM setup and token management
│   └── storage_service.dart     # Firebase Storage for images
├── utils/
│   ├── theme.dart               # App-wide colors and Material theme
│   └── helpers.dart             # Date formatting, validation, utilities
└── widgets/
    ├── message_bubble.dart      # Chat bubble with status indicators
    └── chat_room_tile.dart      # Chat list item with avatar and preview
```

## Getting Started

### Prerequisites

- Flutter SDK 3.10+
- A Firebase project (free tier works fine)
- Android Studio / VS Code with Flutter extension

### Firebase Setup

1. Create a new project at [Firebase Console](https://console.firebase.google.com/)
2. Enable **Authentication** → Email/Password sign-in method
3. Create a **Cloud Firestore** database (start in test mode for development)
4. Enable **Firebase Storage**
5. Add your app:
   - **Android**: Download `google-services.json` → place in `android/app/`
   - **iOS**: Download `GoogleService-Info.plist` → place in `ios/Runner/`
6. (Optional) Set up **Cloud Messaging** for push notifications

### Run the App

```bash
# Clone the repo
git clone https://github.com/Haris-Ahmed83/Flutter-Journey.git
cd Flutter-Journey/chat_app_firebase

# Install dependencies
flutter pub get

# Run on your device
flutter run
```

### Firestore Security Rules (Production)

For production, replace the default rules with something like:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    match /chatRooms/{roomId} {
      allow read, write: if request.auth != null
        && request.auth.uid in resource.data.participants;
      match /messages/{messageId} {
        allow read, write: if request.auth != null;
      }
    }
  }
}
```

## How It Works

**Authentication Flow** — The app uses a `StreamBuilder` on Firebase Auth's state. When a user logs in, they're automatically routed to the home screen. On sign out, they land back on the login page. User profiles are stored in Firestore under a `users` collection.

**Messaging** — Each conversation is a `chatRooms` document with a `messages` subcollection. Sending a message is a batched write — the message doc and the room's metadata (last message, unread count) update atomically. The chat screen listens to the messages subcollection in real-time.

**Read Receipts** — When you open a conversation, all unread messages from the other person get marked as `read` with a timestamp. The sender sees the status update in real-time thanks to Firestore's snapshot listeners.

## License

This project is open source and available under the [MIT License](../LICENSE).

---

Built as part of my [Flutter Journey](https://github.com/Haris-Ahmed83/Flutter-Journey) — learning Flutter one project at a time.
