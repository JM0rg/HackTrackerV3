## Dart MCP

A Dart MCP server (`dart mcp-server`) is configured for this project. **Prefer MCP tools over CLI** for Dart/Flutter work — they integrate with the running app and auto-handle paths.

### Common tools

- `mcp__dart__dart_format` — canonical formatting (source of truth).
- `mcp__dart__analyze_files` — analyzer errors + warnings.
- `mcp__dart__run_tests` — Dart/Flutter tests.
- `mcp__dart__read_package_uris` — read actual dependency source (e.g. `package:riverpod/riverpod.dart`). Use this to understand APIs instead of guessing signatures.
- `mcp__dart__hover` / `signature_help` / `resolve_workspace_symbol` — type and API lookups.
- `mcp__dart__hot_reload` / `hot_restart` — apply edits to the running app.
- `mcp__dart__get_widget_tree` / `get_runtime_errors` / `get_app_logs` — runtime introspection (see `ui-verification.md`).

### DTD connection

Before calling `mcp__dart__connect_dart_tooling_daemon`, read `/tmp/dtd_uri` (`cat /tmp/dtd_uri` via Bash) and pass the value as `uri`. Don't ask the user for it.

If `/tmp/dtd_uri` is missing or empty, the user's `flutter run` was started before the zshrc wrapper was active. Ask them to `source ~/.zshrc` and restart `flutter run`.

### Known caveat

- `mcp__dart__analyze_files` can pass while `flutter test` fails on the same code (compile-time errors the analyzer doesn't catch). Always run tests before declaring "analyze clean" sufficient.
