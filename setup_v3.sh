#!/usr/bin/env bash
set -e
mkdir -p app/src/main/java/com/personal/meetingfocus app/src/main/res/layout app/src/main/res/values app/src/main/res/xml app/src/main/res/drawable app/src/main/res/mipmap-mdpi app/src/main/res/mipmap-hdpi app/src/main/res/mipmap-xhdpi app/src/main/res/mipmap-xxhdpi app/src/main/res/mipmap-xxxhdpi app/src/main/res/mipmap-anydpi-v26
pip install -q pillow
cat << 'EOF' > gen_icon.py
from PIL import Image, ImageDraw
import math
def mk(sz=256, fg=False):
 im = Image.new("RGBA", (sz, sz), (0, 0, 0, 0))
 dr = ImageDraw.Draw(im)
 if not fg: dr.rounded_rectangle((10, 10, sz-11, sz-11), radius=56, fill=(248, 250, 252, 255))
 s = 0.64 if fg else 1.0
 c, ro, ri, gp = sz/2.0, sz*0.36*s, sz*0.295*s, sz*0.042*s
 px = im.load()
 for y in range(sz):
  for x in range(sz):
   dx, dy = x - c, y - c
   if ri <= math.hypot(dx, dy) <= ro and abs(dx) > gp and abs(dy) > gp:
    t = (x + y) / (2.0 * sz)
    px[x, y] = (0, int(45+95*t), int(165+85*t), 255) if (dx<0 and dy<0) or (dx>0 and dy>0) else (0, int(195-70*t), 255, 255)
 dr.ellipse((c-6*s, c-6*s, c+6*s, c+6*s), fill=(0, 82, 212, 255))
 w, hw, tp, nk, sh, tf, tn = sz*0.026*s, sz*0.072*s, sz*0.045*s, sz*0.175*s, sz*0.145*s, sz*0.455*s, sz*0.405*s
 dr.polygon([(c,c-tp),(c-hw,c-nk),(c-w,c-sh),(c-w,c-tn),(c+w,c-tf),(c+w,c-sh),(c+hw,c-nk)], fill=(0,68,204,255))
 dr.polygon([(c,c+tp),(c-hw,c+nk),(c-w,c+sh),(c-w,c+tf),(c+w,c+tn),(c+w,c+sh),(c+hw,c+nk)], fill=(0,68,204,255))
 dr.polygon([(c-tp,c),(c-nk,c-hw),(c-sh,c-w),(c-tf,c-w),(c-tn,c+w),(c-sh,c+w),(c-nk,c+hw)], fill=(0,155,255,255))
 dr.polygon([(c+tp,c),(c+nk,c-hw),(c+sh,c-w),(c+tn,c-w),(c+tf,c+w),(c+sh,c+w),(c+nk,c+hw)], fill=(0,168,255,255))
 return im
b = mk(256, False)
b.save("app/src/main/res/drawable/app_logo.png")
mk(256, True).save("app/src/main/res/drawable/ic_launcher_fg.png")
for f, z in [("mdpi",48),("hdpi",72),("xhdpi",96),("xxhdpi",144),("xxxhdpi",192)]:
 r = b.resize((z, z), Image.Resampling.LANCZOS)
 r.save(f"app/src/main/res/mipmap-{f}/ic_launcher.png")
 r.save(f"app/src/main/res/mipmap-{f}/ic_launcher_round.png")
EOF
python3 gen_icon.py

cat << 'EOF' > settings.gradle.kts
pluginManagement { repositories { google(); mavenCentral(); gradlePluginPortal() } }
dependencyResolutionManagement { repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS); repositories { google(); mavenCentral() } }
rootProject.name = "MeetingFocus"
include(":app")
EOF

cat << 'EOF' > build.gradle.kts
plugins {
 id("com.android.application") version "8.5.0" apply false
 id("org.jetbrains.kotlin.android") version "1.9.24" apply false
}
EOF

cat << 'EOF' > gradle.properties
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
android.nonTransitiveRClass=true
EOF

cat << 'EOF' > app/build.gradle.kts
plugins { id("com.android.application"); id("org.jetbrains.kotlin.android") }
android {
 namespace = "com.personal.meetingfocus"
 compileSdk = 34
 defaultConfig { applicationId = "com.personal.meetingfocus"; minSdk = 26; targetSdk = 34; versionCode = 4; versionName = "3.0" }
 compileOptions { sourceCompatibility = JavaVersion.VERSION_17; targetCompatibility = JavaVersion.VERSION_17 }
 kotlinOptions { jvmTarget = "17" }
}
dependencies {
 implementation("androidx.core:core-ktx:1.13.1")
 implementation("androidx.appcompat:appcompat:1.7.0")
 implementation("com.google.android.material:material:1.12.0")
 implementation("androidx.recyclerview:recyclerview:1.3.2")
}
EOF

cat << 'EOF' > app/src/main/AndroidManifest.xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="com.personal.meetingfocus">
<uses-permission android:name="android.permission.QUERY_ALL_PACKAGES"/>
<uses-permission android:name="android.permission.ACCESS_NOTIFICATION_POLICY"/>
<uses-permission android:name="android.permission.KILL_BACKGROUND_PROCESSES"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<application android:allowBackup="true" android:icon="@mipmap/ic_launcher" android:roundIcon="@mipmap/ic_launcher_round" android:label="Meeting Focus" android:supportsRtl="true" android:theme="@style/AppTheme">
<activity android:name=".MainActivity" android:icon="@mipmap/ic_launcher" android:roundIcon="@mipmap/ic_launcher_round" android:exported="true" android:windowSoftInputMode="stateHidden|adjustResize">
<intent-filter><action android:name="android.intent.action.MAIN"/><category android:name="android.intent.category.LAUNCHER"/></intent-filter>
</activity>
<service android:name=".FocusNotificationService" android:label="Meeting Focus Notification Blocker" android:permission="android.permission.BIND_NOTIFICATION_LISTENER_SERVICE" android:exported="true">
<intent-filter><action android:name="android.service.notification.NotificationListenerService"/></intent-filter>
</service>
<service android:name=".FocusVpnService" android:permission="android.permission.BIND_VPN_SERVICE" android:exported="false">
<intent-filter><action android:name="android.net.VpnService"/></intent-filter>
</service>
<service android:name=".AppFreezeAccessibilityService" android:label="Meeting Focus App Freezer" android:permission="android.permission.BIND_ACCESSIBILITY_SERVICE" android:exported="true">
<intent-filter><action android:name="android.accessibilityservice.AccessibilityService"/></intent-filter>
<meta-data android:name="android.accessibilityservice" android:resource="@xml/accessibility_service_config"/>
</service>
</application>
</manifest>
EOF

cat << 'EOF' > app/src/main/res/values/styles.xml
<resources>
<style name="AppTheme" parent="Theme.MaterialComponents.DayNight.NoActionBar">
<item name="colorPrimary">#0EA5E9</item>
<item name="android:statusBarColor">#080D1A</item>
<item name="android:navigationBarColor">#080D1A</item>
<item name="android:windowBackground">#080D1A</item>
</style>
<color name="ic_launcher_background">#F8FAFC</color>
</resources>
EOF

cat << 'EOF' > app/src/main/res/values/strings.xml
<resources>
<string name="app_name">Meeting Focus</string>
<string name="accessibility_service_description">মিটিং চলাকালীন ফ্রিজ করা অ্যাপগুলো বন্ধ রাখতে সাহায্য করে।</string>
</resources>
EOF

cat << 'EOF' > app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
<background android:drawable="@color/ic_launcher_background"/>
<foreground android:drawable="@drawable/ic_launcher_fg"/>
</adaptive-icon>
EOF
cp app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml

cat << 'EOF' > app/src/main/res/xml/accessibility_service_config.xml
<?xml version="1.0" encoding="utf-8"?>
<accessibility-service xmlns:android="http://schemas.android.com/apk/res/android" android:accessibilityEventTypes="typeWindowStateChanged" android:accessibilityFeedbackType="feedbackGeneric" android:canRetrieveWindowContent="true" android:description="@string/accessibility_service_description" android:notificationTimeout="100"/>
EOF

cat << 'EOF' > app/src/main/res/layout/activity_main.xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android" android:layout_width="match_parent" android:layout_height="match_parent" android:background="#080D1A" android:orientation="vertical" android:padding="12dp">
<LinearLayout android:id="@+id/heroCard" android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="vertical" android:padding="14dp">
<LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:gravity="center_vertical" android:orientation="horizontal">
<ImageView android:layout_width="44dp" android:layout_height="44dp" android:src="@drawable/app_logo" android:scaleType="fitCenter"/>
<LinearLayout android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:layout_marginStart="10dp" android:orientation="vertical">
<LinearLayout android:layout_width="wrap_content" android:layout_height="wrap_content" android:gravity="center_vertical" android:orientation="horizontal">
<TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Meeting Focus Pro" android:textColor="#F8FAFC" android:textSize="18sp" android:textStyle="bold"/>
<TextView android:id="@+id/btnHelpGuide" android:layout_width="wrap_content" android:layout_height="wrap_content" android:layout_marginStart="8dp" android:paddingHorizontal="8dp" android:paddingVertical="2dp" android:text="❓ গাইড" android:textColor="#38BDF8" android:textSize="11sp" android:textStyle="bold"/>
</LinearLayout>
<TextView android:id="@+id/txtStatusBadge" android:layout_width="wrap_content" android:layout_height="wrap_content" android:layout_marginTop="2dp" android:text="⚪ মিটিং মোড বন্ধ আছে" android:textColor="#94A3B8" android:textSize="12sp"/>
</LinearLayout>
<com.google.android.material.switchmaterial.SwitchMaterial android:id="@+id/switchMeetingMode" android:layout_width="wrap_content" android:layout_height="wrap_content"/>
</LinearLayout>
<TextView android:id="@+id/txtLiveBanner" android:layout_width="match_parent" android:layout_height="wrap_content" android:layout_marginTop="8dp" android:padding="8dp" android:text="💡 নিচের '⚡ অটো সেট' বাটনে চাপলে সচল অ্যাপ বাদে বাকি সব অ্যাপ এক ক্লিকেই ফ্রিজ ও নেট অফ হয়ে যাবে।" android:textColor="#BAE6FD" android:textSize="11.5sp"/>
<LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:layout_marginTop="8dp" android:orientation="horizontal" android:weightSum="2">
<TextView android:id="@+id/btnNotificationPerm" android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:layout_marginEnd="4dp" android:gravity="center" android:paddingVertical="6dp" android:text="🔔 নোটিফিকেশন অ্যাক্সেস" android:textColor="#E2E8F0" android:textSize="11sp" android:textStyle="bold"/>
<TextView android:id="@+id/btnAccessibilityPerm" android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:layout_marginStart="4dp" android:gravity="center" android:paddingVertical="6dp" android:text="🛡️ ফ্রিজ গার্ড পারমিশন" android:textColor="#E2E8F0" android:textSize="11sp" android:textStyle="bold"/>
</LinearLayout>
</LinearLayout>
<LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:layout_marginTop="8dp" android:gravity="center_vertical" android:orientation="horizontal">
<EditText android:id="@+id/edtSearch" android:layout_width="0dp" android:layout_height="40dp" android:layout_weight="1" android:hint="🔍 অ্যাপ খুঁজুন (WhatsApp, Messenger)..." android:textColorHint="#64748B" android:textColor="#F8FAFC" android:textSize="12.5sp" android:singleLine="true" android:paddingHorizontal="12dp"/>
<TextView android:id="@+id/btnQuickPreset" android:layout_width="wrap_content" android:layout_height="40dp" android:layout_marginStart="8dp" android:gravity="center" android:paddingHorizontal="12dp" android:text="⚡ অটো সেট: অফ" android:textColor="#FFFFFF" android:textSize="12sp" android:textStyle="bold"/>
</LinearLayout>
<LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:layout_marginTop="8dp" android:layout_marginBottom="4dp" android:orientation="horizontal" android:weightSum="4">
<TextView android:id="@+id/tabAll" android:layout_width="0dp" android:layout_height="32dp" android:layout_weight="1" android:layout_marginEnd="3dp" android:gravity="center" android:text="সব (0)" android:textColor="#FFFFFF" android:textSize="11sp" android:textStyle="bold"/>
<TextView android:id="@+id/tabAllowed" android:layout_width="0dp" android:layout_height="32dp" android:layout_weight="1" android:layout_marginHorizontal="2dp" android:gravity="center" android:text="🟢 সচল (0)" android:textColor="#94A3B8" android:textSize="11sp" android:textStyle="bold"/>
<TextView android:id="@+id/tabOffline" android:layout_width="0dp" android:layout_height="32dp" android:layout_weight="1" android:layout_marginHorizontal="2dp" android:gravity="center" android:text="🚫 নেট অফ (0)" android:textColor="#94A3B8" android:textSize="11sp" android:textStyle="bold"/>
<TextView android:id="@+id/tabFrozen" android:layout_width="0dp" android:layout_height="32dp" android:layout_marginStart="3dp" android:gravity="center" android:text="❄️ ফ্রিজড (0)" android:textColor="#94A3B8" android:textSize="11sp" android:textStyle="bold"/>
</LinearLayout>
<TextView android:id="@+id/txtEmptyState" android:layout_width="match_parent" android:layout_height="wrap_content" android:gravity="center" android:paddingVertical="24dp" android:visibility="gone" android:text="এই ক্যাটাগরিতে বর্তমানে কোনো অ্যাপ নেই।" android:textColor="#94A3B8" android:textSize="13sp"/>
<androidx.recyclerview.widget.RecyclerView android:id="@+id/recyclerApps" android:layout_width="match_parent" android:layout_height="0dp" android:layout_weight="1"/>
</LinearLayout>
EOF

cat << 'EOF' > app/src/main/res/layout/item_app_rule.xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android" android:id="@+id/cardRoot" android:layout_width="match_parent" android:layout_height="wrap_content" android:layout_marginVertical="4dp" android:orientation="vertical" android:padding="11dp">
<LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:gravity="center_vertical" android:orientation="horizontal">
<ImageView android:id="@+id/imgAppIcon" android:layout_width="40dp" android:layout_height="40dp" android:scaleType="fitCenter"/>
<LinearLayout android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:layout_marginStart="10dp" android:orientation="vertical">
<TextView android:id="@+id/txtAppName" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textColor="#F8FAFC" android:textSize="14.5sp" android:textStyle="bold" android:singleLine="true"/>
<TextView android:id="@+id/txtAppStatus" android:layout_width="wrap_content" android:layout_height="wrap_content" android:layout_marginTop="2dp" android:textColor="#94A3B8" android:textSize="11.5sp"/>
</LinearLayout>
</LinearLayout>
<LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:layout_marginTop="9dp" android:orientation="horizontal" android:weightSum="3">
<TextView android:id="@+id/btnToggleAllowed" android:layout_width="0dp" android:layout_height="34dp" android:layout_weight="1" android:layout_marginEnd="4dp" android:gravity="center" android:text="🟢 সচল রাখুন" android:textSize="11sp" android:textStyle="bold"/>
<TextView android:id="@+id/btnToggleOffline" android:layout_width="0dp" android:layout_height="34dp" android:layout_weight="1" android:layout_marginHorizontal="2dp" android:gravity="center" android:text="🚫 নেট অফ" android:textSize="11sp" android:textStyle="bold"/>
<TextView android:id="@+id/btnToggleFreeze" android:layout_width="0dp" android:layout_height="34dp" android:layout_weight="1" android:layout_marginStart="4dp" android:gravity="center" android:text="❄️ ফ্রিজ" android:textSize="11sp" android:textStyle="bold"/>
</LinearLayout>
</LinearLayout>
EOF

cat << 'EOF' > app/src/main/java/com/personal/meetingfocus/PrefsManager.kt
package com.personal.meetingfocus
import android.content.Context
object PrefsManager {
private const val P = "meeting_focus_v3_prefs"
private val DEF = setOf("com.whatsapp","com.whatsapp.w4b","com.google.android.apps.messaging","com.android.mms","com.android.dialer","com.google.android.dialer")
val BROWSERS = setOf("com.android.chrome","com.sec.android.app.sbrowser","org.mozilla.firefox","com.opera.browser","com.opera.mini.native","com.brave.browser","com.microsoft.emmx","com.mi.globalbrowser","com.android.browser","com.google.android.googlequicksearchbox")
private fun sp(c: Context) = c.getSharedPreferences(P, Context.MODE_PRIVATE)
fun isMeetingModeActive(c: Context) = sp(c).getBoolean("meeting_active", false)
fun setMeetingModeActive(c: Context, v: Boolean) = sp(c).edit().putBoolean("meeting_active", v).apply()
fun isAutoSetActive(c: Context) = sp(c).getBoolean("auto_set", false)
fun setAutoSetActive(c: Context, v: Boolean) = sp(c).edit().putBoolean("auto_set", v).apply()
fun getAllowedPackages(c: Context): Set<String> = sp(c).getStringSet("allowed", DEF) ?: DEF
fun setPackageAllowed(c: Context, pkg: String, v: Boolean) { val s = getAllowedPackages(c).toMutableSet(); if (v) s.add(pkg) else s.remove(pkg); sp(c).edit().putStringSet("allowed", s).apply() }
fun getOfflinePackages(c: Context): Set<String> = sp(c).getStringSet("offline", emptySet()) ?: emptySet()
fun setPackageOffline(c: Context, pkg: String, v: Boolean) { val s = getOfflinePackages(c).toMutableSet(); if (v) s.add(pkg) else s.remove(pkg); sp(c).edit().putStringSet("offline", s).apply() }
fun setBulkOfflinePackages(c: Context, pkgs: Set<String>) = sp(c).edit().putStringSet("offline", pkgs).apply()
fun getFrozenPackages(c: Context): Set<String> = sp(c).getStringSet("frozen", emptySet()) ?: emptySet()
fun setPackageFrozen(c: Context, pkg: String, v: Boolean) { val s = getFrozenPackages(c).toMutableSet(); if (v) s.add(pkg) else s.remove(pkg); sp(c).edit().putStringSet("frozen", s).apply() }
fun setBulkFrozenPackages(c: Context, pkgs: Set<String>) = sp(c).edit().putStringSet("frozen", pkgs).apply()
}
EOF

cat << 'EOF' > app/src/main/java/com/personal/meetingfocus/FocusNotificationService.kt
package com.personal.meetingfocus
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
class FocusNotificationService : NotificationListenerService() {
override fun onNotificationPosted(sbn: StatusBarNotification?) {
super.onNotificationPosted(sbn)
if (sbn == null || !PrefsManager.isMeetingModeActive(this)) return
val pkg = sbn.packageName
if (pkg == packageName) return
if (PrefsManager.getFrozenPackages(this).contains(pkg) || PrefsManager.getOfflinePackages(this).contains(pkg) || !PrefsManager.getAllowedPackages(this).contains(pkg)) {
try { if (sbn.isClearable) cancelNotification(sbn.key) else snoozeNotification(sbn.key, 3600000L) } catch (_: Exception) {}
}
}
}
EOF

cat << 'EOF' > app/src/main/java/com/personal/meetingfocus/FocusVpnService.kt
package com.personal.meetingfocus
import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.net.VpnService
import android.os.Handler
import android.os.Looper
import android.os.ParcelFileDescriptor
import java.io.FileInputStream
class FocusVpnService : VpnService() {
private var vpnInterface: ParcelFileDescriptor? = null
@Volatile private var isRunning = false
private var drainThread: Thread? = null
private val handler = Handler(Looper.getMainLooper())
private val freezeWatchdog = object : Runnable {
override fun run() {
if (!isRunning || !PrefsManager.isMeetingModeActive(this@FocusVpnService)) return
val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
for (pkg in PrefsManager.getFrozenPackages(this@FocusVpnService)) { try { am.killBackgroundProcesses(pkg) } catch (_: Exception) {} }
handler.postDelayed(this, 4000L)
}
}
override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
if (intent?.action == ACTION_STOP_VPN) { stopVpn(); stopSelf(); return START_NOT_STICKY }
startVpn(); return START_STICKY
}
private fun startVpn() {
stopVpn()
val blocked = mutableSetOf<String>().apply { addAll(PrefsManager.getOfflinePackages(this@FocusVpnService)); addAll(PrefsManager.getFrozenPackages(this@FocusVpnService)); remove(packageName) }
if (blocked.isEmpty()) { stopSelf(); return }
val builder = Builder().setSession("MeetingFocusPro").setMtu(1500).addAddress("10.10.10.2", 32).addRoute("0.0.0.0", 0).addDnsServer("10.10.10.1").addAddress("fd00:1::2", 128).addRoute("::", 0).addDnsServer("fd00:1::1")
var added = 0
for (pkg in blocked) { try { builder.addAllowedApplication(pkg); added++ } catch (_: Exception) {} }
if (added > 0) {
vpnInterface = builder.establish(); isRunning = true
vpnInterface?.let { pfd -> drainThread = Thread { val input = FileInputStream(pfd.fileDescriptor); val buf = ByteArray(32767); while (isRunning) { try { if (input.read(buf) <= 0) Thread.sleep(50) } catch (_: Exception) { break } } }.apply { isDaemon = true; start() } }
handler.post(freezeWatchdog)
} else stopSelf()
}
private fun stopVpn() { isRunning = false; handler.removeCallbacks(freezeWatchdog); try { drainThread?.interrupt() } catch (_: Exception) {}; drainThread = null; try { vpnInterface?.close() } catch (_: Exception) {}; vpnInterface = null }
override fun onDestroy() { stopVpn(); super.onDestroy() }
companion object { const val ACTION_STOP_VPN = "com.personal.meetingfocus.STOP_VPN" }
}
EOF

cat << 'EOF' > app/src/main/java/com/personal/meetingfocus/AppFreezeAccessibilityService.kt
package com.personal.meetingfocus
import android.accessibilityservice.AccessibilityService
import android.app.ActivityManager
import android.content.Context
import android.view.accessibility.AccessibilityEvent
import android.widget.Toast
class AppFreezeAccessibilityService : AccessibilityService() {
private var lastBlockedTime = 0L
override fun onAccessibilityEvent(event: AccessibilityEvent?) {
if (event?.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED || !PrefsManager.isMeetingModeActive(this)) return
val pkg = event.packageName?.toString() ?: return
if (pkg == packageName || pkg == "com.android.systemui" || pkg.contains("launcher") || pkg.contains("settings")) return
if (PrefsManager.getFrozenPackages(this).contains(pkg)) {
try { (getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager).killBackgroundProcesses(pkg) } catch (_: Exception) {}
performGlobalAction(GLOBAL_ACTION_HOME)
val now = System.currentTimeMillis()
if (now - lastBlockedTime > 2000L) { lastBlockedTime = now; Toast.makeText(this, "❄️ এই অ্যাপটি Meeting Focus-এ ফ্রিজ করা আছে!", Toast.LENGTH_LONG).show() }
}
}
override fun onInterrupt() {}
}
EOF
