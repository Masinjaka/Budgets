# Android release signing

Release builds accept signing credentials from either `android/key.properties`
for local development or environment variables in CI. Never commit the
keystore, passwords, or a populated `key.properties` file.

## Generate the upload key

From the project root on macOS with Android Studio installed:

```bash
"/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/keytool" \
  -genkeypair -v \
  -keystore android/app/drala-upload-keystore.jks \
  -storetype JKS \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias drala-upload
```

Android Studio includes a JDK even when macOS's `/usr/bin/keytool` cannot find a
system Java runtime. On Linux, or when Java is already on `PATH`, use `keytool`
in place of the full executable path.

Keep a secure offline backup of this file and its passwords. The copy under
`android/app/` is ignored by Git.

## Local release builds

Copy `android/key.properties.example` to `android/key.properties`, then replace
the placeholder passwords:

```properties
storePassword=your-keystore-password
keyPassword=your-key-password
keyAlias=drala-upload
storeFile=drala-upload-keystore.jks
```

Build with `fvm flutter build apk --release`.

## GitHub Actions secrets

Encode the keystore without committing the encoded output:

```bash
base64 -i android/app/drala-upload-keystore.jks \
  -o /tmp/drala-upload-keystore.base64
```

Open the GitHub repository, then go to **Settings → Secrets and variables →
Actions** and create these repository secrets:

- `ANDROID_KEYSTORE_BASE64`: contents of the generated `.base64` file
- `ANDROID_KEYSTORE_PASSWORD`: keystore password
- `ANDROID_KEY_ALIAS`: `drala-upload`
- `ANDROID_KEY_PASSWORD`: key password

The workflow decodes the key to `$RUNNER_TEMP`, signs the APK, and removes the
temporary file. Base64 is only an encoding; GitHub Actions secrets provide the
actual encrypted storage.

Reference: [Flutter Android release signing](https://docs.flutter.dev/deployment/android)
and [GitHub encrypted secrets](https://docs.github.com/actions/how-tos/write-workflows/choose-what-workflows-do/use-secrets).
