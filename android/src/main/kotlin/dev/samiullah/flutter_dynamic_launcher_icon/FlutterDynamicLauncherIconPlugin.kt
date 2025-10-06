package dev.samiullah.flutter_dynamic_launcher_icon

import android.app.Application
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * FlutterDynamicLauncherIconPlugin
 *
 * Provides API to change launcher icons safely.
 *
 * - Saves the requested icon name.
 * - Applies icon change automatically when the app goes to background or on next launch, avoiding
 * unexpected restarts.
 */
class FlutterDynamicLauncherIconPlugin :
        FlutterPlugin, MethodChannel.MethodCallHandler, Application.ActivityLifecycleCallbacks {

    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var pendingIcon: String? = null

    companion object {
        private const val MAIN_ACTIVITY = "MainActivity"
        private const val PREFS_NAME = "launcher_icon_prefs"
        private const val KEY_REQUESTED_ICON = "requested_icon"
    }

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "flutter_dynamic_launcher_icon")
        channel.setMethodCallHandler(this)
        context = binding.applicationContext

        // Register lifecycle callbacks to detect background events
        if (context is Application) {
            (context as Application).registerActivityLifecycleCallbacks(this)
        }

        // Apply deferred icon change if exists
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val aliasName = prefs.getString(KEY_REQUESTED_ICON, null)
        if (aliasName != null) {
            applyIcon(aliasName)
            prefs.edit().remove(KEY_REQUESTED_ICON).apply()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        if (context is Application) {
            (context as Application).unregisterActivityLifecycleCallbacks(this)
        }
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        when (call.method) {
            "changeIcon" -> {
                val iconName: String? = call.argument("iconName")

                // Validate icon name before saving
                if (iconName != null && !isValidIcon(iconName)) {
                    result.error(
                            "INVALID_ICON",
                            "Icon '$iconName' is not defined in AndroidManifest.xml. " +
                                    "Available icons: [${getSupportedIcons().joinToString(", ")}]",
                            null
                    )
                    return
                }

                saveIconRequest(iconName)
                result.success(null)
            }
            "getCurrentIcon" -> {
                // Returns null for default icon, icon name for alternate icons
                result.success(getCurrentIcon())
            }
            "getSupportedIcons" -> {
                result.success(getSupportedIcons())
            }
            "isSupported" -> {
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    // -------------------------------
    // Implementation
    // -------------------------------

    /** Validate if the icon name exists as an activity-alias */
    private fun isValidIcon(iconName: String): Boolean {
        val supportedIcons = getSupportedIcons()
        return supportedIcons.contains(iconName)
    }

    /** Save icon request for later (background/next launch) */
    private fun saveIconRequest(aliasName: String?) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        if (aliasName == null) {
            // Store a marker to indicate default icon was requested
            prefs.edit().putString(KEY_REQUESTED_ICON, "").apply()
        } else {
            prefs.edit().putString(KEY_REQUESTED_ICON, aliasName).apply()
        }
        pendingIcon = aliasName
    }

    /** Immediately apply icon change */
    private fun applyIcon(aliasName: String?) {
        val pm = context.packageManager
        val packageName = context.packageName

        // null or empty string means MainActivity (default)
        val isDefaultRequested = aliasName.isNullOrEmpty()

        // Get all components (MainActivity + aliases)
        val allComponents = getAllComponents()

        allComponents.forEach { componentName ->
            val comp = ComponentName(packageName, componentName)
            val isMainActivity = componentName.endsWith(MAIN_ACTIVITY)
            val isTargetAlias =
                    if (!isDefaultRequested) {
                        componentName.endsWith(".$aliasName")
                    } else {
                        false
                    }

            when {
                // Enable MainActivity if default is requested
                isDefaultRequested && isMainActivity -> {
                    pm.setComponentEnabledSetting(
                            comp,
                            PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                            PackageManager.DONT_KILL_APP
                    )
                }
                // Disable MainActivity if switching to an alias
                !isDefaultRequested && isMainActivity -> {
                    pm.setComponentEnabledSetting(
                            comp,
                            PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                            PackageManager.DONT_KILL_APP
                    )
                }
                // Enable the target alias
                !isDefaultRequested && isTargetAlias -> {
                    pm.setComponentEnabledSetting(
                            comp,
                            PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                            PackageManager.DONT_KILL_APP
                    )
                }
                // Disable all other aliases
                !isMainActivity -> {
                    pm.setComponentEnabledSetting(
                            comp,
                            PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                            PackageManager.DONT_KILL_APP
                    )
                }
            }
        }
    }

    /** Get currently enabled icon alias. Returns null if default icon is active. */
    private fun getCurrentIcon(): String? {
        val pm = context.packageManager
        val packageName = context.packageName

        // Check MainActivity first
        val mainActivityComp = ComponentName(packageName, "$packageName.$MAIN_ACTIVITY")
        val mainActivityState = pm.getComponentEnabledSetting(mainActivityComp)

        // If MainActivity is explicitly enabled or default, it's the current icon
        if (mainActivityState == PackageManager.COMPONENT_ENABLED_STATE_ENABLED ||
                        mainActivityState == PackageManager.COMPONENT_ENABLED_STATE_DEFAULT
        ) {

            // But check if any alias is also enabled (shouldn't happen, but handle it)
            val aliases = getSupportedIcons().filter { it != MAIN_ACTIVITY }
            aliases.forEach { alias ->
                val comp = ComponentName(packageName, "$packageName.$alias")
                val state = pm.getComponentEnabledSetting(comp)
                if (state == PackageManager.COMPONENT_ENABLED_STATE_ENABLED) {
                    return alias
                }
            }
            // MainActivity is active, so return null (default icon)
            return null
        }

        // Check aliases
        getSupportedIcons().forEach { alias ->
            if (alias != MAIN_ACTIVITY) {
                val comp = ComponentName(packageName, "$packageName.$alias")
                val state = pm.getComponentEnabledSetting(comp)
                if (state == PackageManager.COMPONENT_ENABLED_STATE_ENABLED) {
                    return alias
                }
            }
        }

        // No icon found enabled, return null (default)
        return null
    }

    /** Get all launcher components (MainActivity + aliases) */
    private fun getAllComponents(): List<String> {
        val pm = context.packageManager
        val packageName = context.packageName

        val intent =
                Intent(Intent.ACTION_MAIN).apply {
                    addCategory(Intent.CATEGORY_LAUNCHER)
                    `package` = packageName
                }

        val resolveInfos =
                pm.queryIntentActivities(intent, PackageManager.MATCH_DISABLED_COMPONENTS)

        return resolveInfos.mapNotNull { resolveInfo -> resolveInfo.activityInfo?.name }.filter {
            it.isNotEmpty()
        }
    }

    /** Dynamically discover supported icons (for Flutter API) */
    private fun getSupportedIcons(): List<String> {
        val allComponents = getAllComponents()
        return allComponents.mapNotNull { componentName ->
            val iconName = componentName.substringAfterLast(".")
            if (iconName.isNotEmpty() && iconName != MAIN_ACTIVITY) iconName else null
        }
    }

    // -------------------------------
    // Lifecycle Hooks
    // -------------------------------

    override fun onActivityStopped(activity: android.app.Activity) {
        // When app goes background, apply deferred icon only if there's a pending change
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val requestedIcon = prefs.getString(KEY_REQUESTED_ICON, null)

        if (requestedIcon != null) {
            // Empty string means default was requested, otherwise it's an icon name
            val iconToApply = if (requestedIcon.isEmpty()) null else requestedIcon
            applyIcon(iconToApply)
            prefs.edit().remove(KEY_REQUESTED_ICON).apply()
            pendingIcon = null

            // Force process kill to ensure clean restart and prevent splash screen freeze
            // Only kill process in release mode
            if (!isDebugMode(context)) {
                android.os.Process.killProcess(android.os.Process.myPid())
            }
        }
    }

    private fun isDebugMode(context: Context): Boolean {
        return (context.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
    }

    override fun onActivityCreated(activity: android.app.Activity, savedInstanceState: Bundle?) {}
    override fun onActivityStarted(activity: android.app.Activity) {}
    override fun onActivityResumed(activity: android.app.Activity) {}
    override fun onActivityPaused(activity: android.app.Activity) {}
    override fun onActivitySaveInstanceState(activity: android.app.Activity, outState: Bundle) {}
    override fun onActivityDestroyed(activity: android.app.Activity) {}
}
