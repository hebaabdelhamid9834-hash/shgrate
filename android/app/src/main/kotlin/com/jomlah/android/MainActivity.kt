package com.shgrade.android

import com.tiktok.TikTokBusinessSdk
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class MainActivity : FlutterFragmentActivity() {
    companion object {
        private const val CHANNEL = "shgarde/marketing_analytics"
        private const val TIKTOK_APP_ID = "7700496912805314612"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "initializeTikTok" -> result.success(initializeTikTok())
                        "trackTikTok" -> {
                            if (!TikTokBusinessSdk.isInitialized()) {
                                result.success(false)
                                return@setMethodCallHandler
                            }

                            val eventName = call.argument<String>("eventName")
                            if (eventName.isNullOrBlank()) {
                                result.error("INVALID_EVENT", "TikTok eventName is required", null)
                                return@setMethodCallHandler
                            }

                            val properties = JSONObject()
                            @Suppress("UNCHECKED_CAST")
                            val rawProperties = call.argument<Map<String, Any?>>("properties")
                            rawProperties?.forEach { (key, value) ->
                                if (value != null) properties.put(key, value)
                            }
                            TikTokBusinessSdk.trackEvent(eventName, properties)
                            result.success(true)
                        }
                        "identifyTikTok" -> {
                            if (TikTokBusinessSdk.isInitialized()) {
                                TikTokBusinessSdk.identify(
                                    call.argument<String>("externalId"),
                                    call.argument<String>("name"),
                                    call.argument<String>("phone"),
                                    call.argument<String>("email")
                                )
                            }
                            result.success(TikTokBusinessSdk.isInitialized())
                        }
                        "logoutTikTok" -> {
                            if (TikTokBusinessSdk.isInitialized()) TikTokBusinessSdk.logout()
                            result.success(true)
                        }
                        "flushTikTok" -> {
                            if (TikTokBusinessSdk.isInitialized()) TikTokBusinessSdk.flush()
                            result.success(true)
                        }
                        else -> result.notImplemented()
                    }
                } catch (error: Exception) {
                    result.error("TIKTOK_ERROR", error.message, null)
                }
            }
    }

    private fun initializeTikTok(): Boolean {
        if (TikTokBusinessSdk.isInitialized()) return true

        val appSecret = BuildConfig.TIKTOK_APP_SECRET
        if (appSecret.isBlank()) return false

        val config = TikTokBusinessSdk.TTConfig(applicationContext, appSecret)
            .setAppId(BuildConfig.APPLICATION_ID)
            .setTTAppId(TIKTOK_APP_ID)

        if (BuildConfig.DEBUG) config.openDebugMode()

        TikTokBusinessSdk.initializeSdk(config)
        TikTokBusinessSdk.startTrack()
        return TikTokBusinessSdk.isInitialized()
    }
}
