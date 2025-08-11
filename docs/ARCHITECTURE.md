Shortsy App Architecture

Folders:
- lib/
  - app/
    - routes.dart (central app routes map)
  - shared/
    - theme/ (design.dart, theme helpers)
    - widgets/ (common UI: glass, headers, nav, buttons, backdrop, comments_sheet, vertical_video_pager)
    - services/ (barrel export of all services)
  - features/
    - feed/ (home_feed_screen.dart, video_post_screen.dart, feed_service.dart, comments_service.dart)
    - profile/ (profile_screen.dart, edit_profile_screen.dart, follow_service.dart, saved_service.dart)
    - discover/ (discover_screen.dart, tag_screen.dart)
    - create/ (create_screen.dart, upload_clip_screen.dart)
    - inbox/ (inbox_screen.dart, chat_screen.dart)
    - live/ (live_screen.dart, live_stream_setup_screen.dart)
    - auth/ (sign_in_screen.dart, auth_service.dart)
  - screens/ (legacy locations; gradually replaced by features/*)

Imports:
- Use shared/widgets/index.dart for all common widgets.
- Use shared/services/index.dart to access services.
- Use features/*/index.dart to import screens/services of a feature.

Migration rules:
- New files live in features/* or shared/*.
- Old files in screens/ keep working but should be gradually converted to re-exports and then removed.
- Avoid relative deep imports; prefer barrels.
