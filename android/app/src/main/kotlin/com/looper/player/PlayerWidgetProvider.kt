package com.looper.player

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.*
import android.os.Bundle
import android.view.KeyEvent
import android.view.View
import android.widget.RemoteViews
import android.util.Log

class PlayerWidgetProvider : AppWidgetProvider() {

    companion object {
        const val ACTION_PLAY_PAUSE = "com.looper.player.ACTION_PLAY_PAUSE"
        const val ACTION_NEXT = "com.looper.player.ACTION_NEXT"
        const val ACTION_PREV = "com.looper.player.ACTION_PREV"
        const val ACTION_SHUFFLE = "com.looper.player.ACTION_SHUFFLE"
        const val ACTION_REPEAT = "com.looper.player.ACTION_REPEAT"

        fun updateWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int, options: Bundle? = null) {
            val views = RemoteViews(context.packageName, R.layout.player_widget)
            val prefs = context.getSharedPreferences("WidgetState", Context.MODE_PRIVATE)

            val title = prefs.getString("title", "No song playing") ?: "No song playing"
            val artist = prefs.getString("artist", "") ?: ""
            val isPlaying = prefs.getBoolean("isPlaying", false)
            val isShuffle = prefs.getBoolean("isShuffle", false)
            val repeatMode = prefs.getInt("repeatMode", 0) // 0: off, 1: all, 2: one
            val lyrics = prefs.getString("lyrics", "") ?: ""
            val nextLyrics = prefs.getString("nextLyrics", "") ?: ""
            val artPath = prefs.getString("artPath", "") ?: ""
            val accentColor = prefs.getInt("accentColor", Color.parseColor("#55DF69"))

            Log.d("PlayerWidget", "PlayerWidgetProvider: updateWidget: id=$appWidgetId, title=$title, artist=$artist, isPlaying=$isPlaying, accentColor=$accentColor")

            // Blend accentColor with a deep dark background (12% accent, 88% black)
            val ratio = 0.12f
            val r = (((accentColor shr 16) and 0xFF) * ratio + 0x11 * (1 - ratio)).toInt()
            val g = (((accentColor shr 8) and 0xFF) * ratio + 0x11 * (1 - ratio)).toInt()
            val b = ((accentColor and 0xFF) * ratio + 0x11 * (1 - ratio)).toInt()
            val blendedBackgroundColor = Color.rgb(r, g, b)
            views.setInt(R.id.widget_background_image, "setColorFilter", blendedBackgroundColor)

            // Set song metadata
            views.setTextViewText(R.id.widget_title, title)
            views.setTextViewText(R.id.widget_artist, artist)

            // Setup sizes (responsive elements)
            val opts = options ?: appWidgetManager.getAppWidgetOptions(appWidgetId)
            val minWidth = opts.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH)
            val minHeight = opts.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT)

            val width = if (minWidth > 0) minWidth else 250
            val height = if (minHeight > 0) minHeight else 110

            // Dynamic layout adjustments based on dimensions
            val showLyrics = width >= 150 && height >= 80
            val showShuffleRepeat = width >= 160

            val hasLyrics = lyrics.isNotEmpty() || nextLyrics.isNotEmpty()
            if (showLyrics && hasLyrics) {
                views.setViewVisibility(R.id.widget_lyrics_container, View.VISIBLE)
                views.setTextViewText(R.id.widget_lyric_active, lyrics)
                views.setTextViewText(R.id.widget_lyric_next, nextLyrics)
            } else {
                views.setViewVisibility(R.id.widget_lyrics_container, View.GONE)
            }

            if (showShuffleRepeat) {
                views.setViewVisibility(R.id.widget_shuffle, View.VISIBLE)
                views.setViewVisibility(R.id.widget_repeat, View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.widget_shuffle, View.GONE)
                views.setViewVisibility(R.id.widget_repeat, View.GONE)
            }

            // Set play/pause icon and play container background color
            if (isPlaying) {
                views.setImageViewResource(R.id.widget_play_pause, R.drawable.ic_pause)
            } else {
                views.setImageViewResource(R.id.widget_play_pause, R.drawable.ic_play)
            }
            
            // Apply accent colors dynamically to the circular background ImageView
            views.setInt(R.id.widget_play_pause_background, "setColorFilter", accentColor)

            // Highlight Shuffle if enabled
            if (isShuffle) {
                views.setInt(R.id.widget_shuffle, "setColorFilter", accentColor)
            } else {
                views.setInt(R.id.widget_shuffle, "setColorFilter", Color.parseColor("#88FFFFFF"))
            }

            // Highlight Repeat if not off
            if (repeatMode == 2) {
                views.setImageViewResource(R.id.widget_repeat, R.drawable.ic_repeat_one)
                views.setInt(R.id.widget_repeat, "setColorFilter", accentColor)
            } else if (repeatMode == 1) {
                views.setImageViewResource(R.id.widget_repeat, R.drawable.ic_repeat)
                views.setInt(R.id.widget_repeat, "setColorFilter", accentColor)
            } else {
                views.setImageViewResource(R.id.widget_repeat, R.drawable.ic_repeat)
                views.setInt(R.id.widget_repeat, "setColorFilter", Color.parseColor("#88FFFFFF"))
            }

            // Set artwork
            Log.d("PlayerWidget", "artwork path: $artPath")
            if (artPath.isNotEmpty()) {
                try {
                    val bitmap = decodeSampledBitmapFromFile(artPath, 256, 256)
                    Log.d("PlayerWidget", "decoded bitmap: ${bitmap != null}")
                    if (bitmap != null) {
                        val roundedBitmap = getRoundedCornerBitmap(bitmap, 48) // 48px rounding
                        views.setImageViewBitmap(R.id.widget_artwork, roundedBitmap)
                    } else {
                        views.setImageViewResource(R.id.widget_artwork, R.drawable.ic_play)
                    }
                } catch (e: Exception) {
                    views.setImageViewResource(R.id.widget_artwork, R.drawable.ic_play)
                }
            } else {
                views.setImageViewResource(R.id.widget_artwork, R.drawable.ic_play)
            }

            // Add PendingIntents for clicks
            views.setOnClickPendingIntent(R.id.widget_play_pause_container, getPendingIntent(context, ACTION_PLAY_PAUSE))
            views.setOnClickPendingIntent(R.id.widget_next, getPendingIntent(context, ACTION_NEXT))
            views.setOnClickPendingIntent(R.id.widget_prev, getPendingIntent(context, ACTION_PREV))
            views.setOnClickPendingIntent(R.id.widget_shuffle, getPendingIntent(context, ACTION_SHUFFLE))
            views.setOnClickPendingIntent(R.id.widget_repeat, getPendingIntent(context, ACTION_REPEAT))

            // Launch app intent when title, artist or artwork is clicked
            val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            val launchPendingIntent = PendingIntent.getActivity(
                context, 0, launchIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_artwork, launchPendingIntent)
            views.setOnClickPendingIntent(R.id.widget_title, launchPendingIntent)
            views.setOnClickPendingIntent(R.id.widget_artist, launchPendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun decodeSampledBitmapFromFile(path: String, reqWidth: Int, reqHeight: Int): Bitmap? {
            try {
                val options = BitmapFactory.Options().apply {
                    inJustDecodeBounds = true
                }
                BitmapFactory.decodeFile(path, options)

                options.inSampleSize = calculateInSampleSize(options, reqWidth, reqHeight)
                options.inJustDecodeBounds = false
                return BitmapFactory.decodeFile(path, options)
            } catch (e: Exception) {
                return null
            }
        }

        private fun calculateInSampleSize(options: BitmapFactory.Options, reqWidth: Int, reqHeight: Int): Int {
            val height = options.outHeight
            val width = options.outWidth
            var inSampleSize = 1

            if (height > reqHeight || width > reqWidth) {
                val halfHeight = height / 2
                val halfWidth = width / 2
                while (halfHeight / inSampleSize >= reqHeight && halfWidth / inSampleSize >= reqWidth) {
                    inSampleSize *= 2
                }
            }
            return inSampleSize
        }

        private fun getPendingIntent(context: Context, action: String): PendingIntent {
            val intent = Intent(context, PlayerWidgetProvider::class.java).apply {
                this.action = action
            }
            return PendingIntent.getBroadcast(
                context, action.hashCode(), intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }

        private fun getRoundedCornerBitmap(bitmap: Bitmap, pixels: Int): Bitmap {
            val output = Bitmap.createBitmap(bitmap.width, bitmap.height, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(output)

            val color = -0xbdbdbe
            val paint = Paint()
            val rect = Rect(0, 0, bitmap.width, bitmap.height)
            val rectF = RectF(rect)
            val roundPx = pixels.toFloat()

            paint.isAntiAlias = true
            canvas.drawARGB(0, 0, 0, 0)
            paint.color = color
            canvas.drawRoundRect(rectF, roundPx, roundPx, paint)

            paint.xfermode = PorterDuffXfermode(PorterDuff.Mode.SRC_IN)
            canvas.drawBitmap(bitmap, rect, rect, paint)

            return output
        }
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onAppWidgetOptionsChanged(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int, newOptions: Bundle) {
        updateWidget(context, appWidgetManager, appWidgetId, newOptions)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        val action = intent.action ?: return

        when (action) {
            ACTION_PLAY_PAUSE -> {
                sendMediaButtonIntent(context, KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE)
            }
            ACTION_NEXT -> {
                sendMediaButtonIntent(context, KeyEvent.KEYCODE_MEDIA_NEXT)
            }
            ACTION_PREV -> {
                sendMediaButtonIntent(context, KeyEvent.KEYCODE_MEDIA_PREVIOUS)
            }
            ACTION_SHUFFLE, ACTION_REPEAT -> {
                MainActivity.sendWidgetAction(context, action)
            }
        }
    }

    private fun sendMediaButtonIntent(context: Context, keycode: Int) {
        val downIntent = Intent(Intent.ACTION_MEDIA_BUTTON).apply {
            setClassName(context.packageName, "com.ryanheise.audioservice.MediaButtonReceiver")
            putExtra(Intent.EXTRA_KEY_EVENT, KeyEvent(KeyEvent.ACTION_DOWN, keycode))
        }
        context.sendBroadcast(downIntent)

        val upIntent = Intent(Intent.ACTION_MEDIA_BUTTON).apply {
            setClassName(context.packageName, "com.ryanheise.audioservice.MediaButtonReceiver")
            putExtra(Intent.EXTRA_KEY_EVENT, KeyEvent(KeyEvent.ACTION_UP, keycode))
        }
        context.sendBroadcast(upIntent)
    }
}
