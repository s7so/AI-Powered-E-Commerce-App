ضع ملفات Firebase هنا كمرجع:
- أضف ملف google-services.json إلى: android/app/google-services.json
- أضف ملف GoogleService-Info.plist إلى: ios/Runner/GoogleService-Info.plist

قم بتوليد ملف lib/firebase_options.dart عبر الأمر:
flutter pub add flutterfire_cli
dart pub global activate flutterfire_cli
flutterfire configure

أو استبدل القيم المؤقتة في lib/firebase_options.dart بالقيم الصحيحة.