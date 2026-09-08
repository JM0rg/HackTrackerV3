# Emulator regression journey

Run from `app/` with a booted, disposable simulator or emulator that contains no data you need to keep:

```sh
flutter test integration_test/emulator_test.dart -d <device-id> --reporter expanded
```

This launches the real Flutter app and native SQLite/path-provider plugins. The test code uses a uniquely named temporary database and in-memory test preferences, and does not initialize Supabase. However, Flutter's integration-test runner uninstalls the app during cleanup, deleting its device sandbox, including any normal scorebook already on that device. Use a dedicated disposable device; export any existing scorebook before testing. Do not pass production credentials or Supabase Dart defines to this test.

The journey covers profile editing, team creation, roster and opponent entry, seasons and tournaments, multiple-team lineup isolation, actual base drags, explicit submission, free/premium access, ball-location adjustments, draft recovery, failed-save retry, undo/cancel, ending/reopening games, inning transitions, personal RBI versus team totals, stats routes, disk reopening, and portable backup restoration.

The normal unit/widget/golden suite remains `flutter test`. Native gestures use the device viewport and real safe-area insets; desktop widget tests should not be imported into this suite with platform-channel mocks.

After testing, launch the regular application again using `bash scripts/run.sh -d <device-id>` from the repository root. It will start with a fresh sandbox; restore an exported backup if needed.

Account OTP delivery, cross-device invitations/sync, real store purchases, and performance on physical devices require separate verification. The current app has no completed store integration or full game sync.
