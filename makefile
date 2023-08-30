build-apk:
	flutter  build apk --dart-define=APP_CONFIG=config/online/http.yaml
build-web:
	flutter build web  --dart-define=APP_CONFIG=config/online/https.yaml --base-href=/web/
cp-apk:
	cp build/app/outputs/flutter-apk/app-release.apk ./build/web/myoption.apk
	cp build/app/outputs/flutter-apk/app-release.apk.sha1 ./build/web/myoption.apk.sha1
build: build-web build-apk cp-apk
	@echo " ------------ Successfully!! ------------ "