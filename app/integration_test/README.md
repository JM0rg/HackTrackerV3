# Emulator regression journey

Run from `app/` with a booted simulator or emulator:

```sh
flutter test integration_test/emulator_test.dart -d <device-id> --reporter expanded
```

This launches the real Flutter app and native SQLite/path-provider plugins. It uses a uniquely named temporary database and in-memory test preferences. It does not initialize Supabase or alter an existing scorebook. Do not pass production credentials or Supabase Dart defines to this test.

The journey covers profile editing, team creation, roster and opponent entry, seasons and tournaments, multiple-team lineup isolation, actual base drags, explicit submission, free/premium access, ball-location adjustments, draft recovery, failed-save retry, undo/cancel, ending/reopening games, inning transitions, personal RBI versus team totals, stats routes, disk reopening, and portable backup restoration.

The normal unit/widget/golden suite remains `flutter test`. Native gestures use the device viewport and real safe-area insets; desktop widget tests should not be imported into this suite with platform-channel mocks.

After testing, launch the regular application again using `bash scripts/run.sh -d <device-id>` from the repository root. The test target replaces the installed executable, while the existing normal scorebook remains intact.

Account OTP delivery, cross-device invitations/sync, real store purchases, and performance on physical devices require separate verification. The current app has no completed store integration or full game sync.
