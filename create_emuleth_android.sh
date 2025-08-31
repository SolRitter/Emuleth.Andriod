bash -lc 'cat > create_emuleth_android.sh << "EOF"
#!/usr/bin/env bash
set -euo pipefail

APP_ID="com.emuleth.app"
APP_NAME="Emuleth"
MIN_SDK=24
TARGET_SDK=33
COMPILE_SDK=33

echo "==> Creating project structure..."
mkdir -p app/src/main/java/$(echo $APP_ID | tr . /)
mkdir -p app/src/main/res/values
mkdir -p .github/workflows

cat > settings.gradle <<SETTINGS
rootProject.name = "${APP_NAME,,}"
include(":app")
SETTINGS

cat > build.gradle <<ROOTGRADLE
buildscript {
    repositories { google(); mavenCentral() }
    dependencies { classpath "com.android.tools.build:gradle:8.4.2" }
}
allprojects { repositories { google(); mavenCentral() } }
ROOTGRADLE

cat > app/build.gradle <<APPGRADLE
apply plugin: "com.android.application"
android {
    namespace "${APP_ID}"
    compileSdk ${COMPILE_SDK}
    defaultConfig {
        applicationId "${APP_ID}"
        minSdk ${MIN_SDK}
        targetSdk ${TARGET_SDK}
        versionCode 1
        versionName "1.0"
    }
    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro"
        }
    }
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}
dependencies {
    implementation "androidx.appcompat:appcompat:1.7.0"
    implementation "com.google.android.material:material:1.12.0"
    implementation "androidx.activity:activity:1.9.1"
    implementation "androidx.constraintlayout:constraintlayout:2.1.4"
}
APPGRADLE

cat > app/proguard-rules.pro <<PRO
# (empty)
PRO

cat > app/src/main/AndroidManifest.xml <<MANIFEST
<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="${APP_ID}">
  <application android:label="@string/app_name" android:theme="@style/AppTheme">
    <activity android:name=".MainActivity" android:exported="true">
      <intent-filter>
        <action android:name="android.intent.action.MAIN" />
        <category android:name="android.intent.category.LAUNCHER" />
      </intent-filter>
    </activity>
  </application>
</manifest>
MANIFEST

cat > app/src/main/res/values/strings.xml <<STRINGS
<resources>
  <string name="app_name">${APP_NAME}</string>
  <string name="hello">Hello, Prime Sol. Emuleth awaits.</string>
</resources>
STRINGS

cat > app/src/main/res/values/colors.xml <<COLORS
<resources>
  <color name="purple_500">#7E57C2</color>
  <color name="purple_700">#5E35B1</color>
  <color name="black">#000000</color>
  <color name="white">#FFFFFF</color>
</resources>
COLORS

cat > app/src/main/res/values/styles.xml <<STYLES
<resources>
  <style name="AppTheme" parent="Theme.Material3.DayNight.NoActionBar"/>
</resources>
STYLES

cat > app/src/main/java/$(echo $APP_ID | tr . /)/MainActivity.java <<JAVA
package ${APP_ID};

import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;
import android.widget.TextView;
import android.widget.FrameLayout;
import android.view.Gravity;

public class MainActivity extends AppCompatActivity {
  @Override protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    TextView tv = new TextView(this);
    tv.setText(getString(R.string.hello));
    tv.setTextSize(20f);
    tv.setGravity(Gravity.CENTER);
    FrameLayout root = new FrameLayout(this);
    root.addView(tv);
    setContentView(root);
  }
}
JAVA

mkdir -p .github/workflows
cat > .github/workflows/android.yml <<YML
name: Android CI (APK)
on:
  push: { branches: [ "main" ] }
  pull_request: { branches: [ "main" ] }
  workflow_dispatch:
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: "17"
      - name: Set up Gradle
        uses: gradle/gradle-build-action@v3
        with:
          gradle-version: "8.7"
      - name: Build Debug APK
        run: gradle :app:assembleDebug
      - name: Upload APK artifact
        uses: actions/upload-artifact@v4
        with:
          name: Emuleth-APK
          path: app/build/outputs/apk/debug/*.apk
YML

cat > README.md <<MD
# ${APP_NAME}
Minimal Android scaffold with CI. Push to **main** and download the APK from **Actions → Artifacts**.
MD

cat > .gitignore <<IGN
.idea/
.gradle/
build/
local.properties
*.iml
app/build/
*.jks
*.keystore
IGN

echo "Scaffold complete."
EOF
chmod +x create_emuleth_android.sh
./create_emuleth_android.sh