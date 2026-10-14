# CampusHub

Complaints, venue bookings and suggestions for your campus. Flutter app backed by
Firebase Auth and Cloud Firestore, with images uploaded to Cloudinary.

## Setup

`lib/firebase_options.dart` and `lib/core/constants/cloudinary_constants.dart` are
git-ignored. Generate the first with `flutterfire configure` and create the second
with your Cloudinary `cloudName` and unsigned `uploadPreset`.

```sh
flutter pub get
flutter run
```

## Firestore security rules

`firestore.rules` holds the server-side authorization for every collection, including
who may delete an account (only its owner or an active admin). Deploy it whenever it
changes:

```sh
firebase deploy --only firestore:rules
```

`firestore.indexes.json` lists the composite indexes the app's queries need
(`firebase deploy --only firestore:indexes`).

## Deleting accounts

* **Users** delete their own account from *Profile menu → My account → Delete Account*,
  confirming with their password.
* **Admins** delete anyone else's from *Admin Panel → Manage Users → (user) → Delete
  Account*, typing `DELETE` to confirm.

What happens to the data:

| Data | Outcome |
| --- | --- |
| Profile, notifications, suggestions they wrote, their votes | Deleted |
| Complaints and bookings | Kept for staff and reports, name replaced with "Deleted user" |
| Pending and upcoming bookings | Cancelled (the coordinator is notified) |
| `deleted_accounts/{uid}` | Tombstone with uid, who deleted it and when |

Deletion is refused for a coordinator who still manages venues (reassign them in
Manage Venues first) and for the last active admin.

Without a backend, the app can only remove the Firebase Auth sign-in of the user who is
signed in. When an admin deletes someone, that person is signed out of any open session
straight away, and their leftover sign-in is removed the next time it is used. To remove
it immediately, delete the user in the Firebase console (Authentication → Users) or add
a Cloud Function using the Admin SDK.

## Tests

```sh
flutter analyze
flutter test

# Security rules, against the Firestore emulator (Node 20+ and Java 11+)
cd firestore_tests
npm install
npm test
```
