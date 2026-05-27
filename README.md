# Art Learn Personal Fullstack

Module cá nhân: Bài hướng dẫn nghệ thuật và Art Studio.

## Công nghệ sử dụng

- Frontend: Flutter, Dart, Material Design, CustomPaint, Canvas, GestureDetector.
- Backend: Node.js, NestJS, TypeScript, REST API, Multer.
- Media storage: thư mục `uploads/` trên backend.
- CSDL thiết kế: PostgreSQL.

## Cấu trúc thư mục

```text
art_learn_personal_fullstack/
├── Dart-UI/
│   └── lib/
│       ├── main.dart
│       ├── config/api_config.dart
│       ├── models/tutorial.dart
│       ├── models/artwork.dart
│       ├── services/content_service.dart
│       ├── screens/main_navigation_screen.dart
│       ├── screens/tutorials_screen.dart
│       ├── screens/tutorial_detail_screen.dart
│       ├── screens/draw_screen.dart
│       └── widgets/tutorial_card.dart
└── NestJS-BE/
    └── src/
        ├── main.ts
        ├── app.module.ts
        ├── content/
        │   ├── content.module.ts
        │   ├── content.controller.ts
        │   └── content.service.ts
        └── community/
            ├── community.module.ts
            ├── community.controller.ts
            └── community.service.ts