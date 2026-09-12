package com.looper.player

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.app.Activity
import android.content.Intent
import android.content.BroadcastReceiver
import android.content.IntentFilter
import android.os.Bundle
import android.os.Build
import android.media.AudioManager
import android.content.Context
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.util.Log
import android.graphics.Color
import android.media.MediaMetadataRetriever
import android.os.PowerManager


class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.looper.player/broadcast"
    private val WIDGET_CHANNEL = "com.looper.player/widget"
    private val WAKELOCK_CHANNEL = "com.looper.player/wakelock"
    private val AUDIO_FOCUS_CHANNEL = "com.looper.player/audio_focus"
    private val SAF_PICK_FOLDER_REQUEST_CODE = 9273
    private var wakeLock: PowerManager.WakeLock? = null
    private var audioFocusManager: AudioFocusManager? = null
    // Pending result for an in-flight pickSafFolder() call, bridged across
    // the async gap to the system folder-picker Activity in onActivityResult.
    private var pendingSafResult: MethodChannel.Result? = null


    companion object {
        var activeEngine: FlutterEngine? = null
        var stopOnTaskRemoved: Boolean = false

        fun sendWidgetAction(context: Context, action: String) {
            val engine = activeEngine
            if (engine != null) {
                val channel = MethodChannel(engine.dartExecutor.binaryMessenger, "com.looper.player/widget")
                channel.invokeMethod("onWidgetAction", action)
            } else {
                // If app is not running, click launches the app
                val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
                launchIntent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                context.startActivity(launchIntent)
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        activeEngine = flutterEngine
        io.flutter.embedding.engine.FlutterEngineCache.getInstance().put("looper_cached_engine", flutterEngine)
        
        try {
            startService(Intent(this, LooperTaskService::class.java))
        } catch (e: Exception) {
            Log.e("LooperTaskService", "Failed to start LooperTaskService", e)
        }



        val afm = AudioFocusManager(this, MethodChannel(flutterEngine.dartExecutor.binaryMessenger, AUDIO_FOCUS_CHANNEL))
        audioFocusManager = afm
        // Registered unconditionally (not tied to holding AudioManager focus):
        // mpv_audio_kit is the sole audio-focus owner, so this class must never
        // request focus itself (a second concurrent focus request would steal
        // focus from mpv's own listener and pause playback). These receivers
        // only need the ordinary broadcasts, not focus, to power "Resume on
        // Bluetooth Connect" (and a redundant but harmless noisy-pause).
        afm.registerReceivers()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, AUDIO_FOCUS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestAudioFocus" -> {
                    val granted = afm.requestAudioFocus()
                    result.success(granted)
                }
                "abandonAudioFocus" -> {
                    afm.abandonAudioFocus()
                    result.success(null)
                }
                "setPlaybackInterrupted" -> {
                    val interrupted = call.argument<Boolean>("interrupted") ?: false
                    afm.setPlaybackInterrupted(interrupted)
                    result.success(null)
                }
                "syncSettings" -> {
                    afm.isEnabled = call.argument<Boolean>("enabled") ?: true
                    afm.pauseOnDuck = call.argument<Boolean>("pauseOnDuck") ?: false
                    afm.resumeOnBluetoothConnect = call.argument<Boolean>("resumeOnBluetoothConnect") ?: false
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "broadcastMetadata") {
                val title = call.argument<String>("title")
                val artist = call.argument<String>("artist")
                val album = call.argument<String>("album")
                val duration = (call.argument<Any>("duration") as? Number)?.toLong() ?: 0L
                val isPlaying = call.argument<Boolean>("isPlaying") ?: false

                sendPlaybackBroadcast(title, artist, album, duration, isPlaying)
                result.success(null)
            } else if (call.method == "setStopOnTaskRemoved") {
                val value = call.argument<Boolean>("value") ?: false
                stopOnTaskRemoved = value
                result.success(null)
            } else if (call.method == "isOnCall") {
                val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                val mode = audioManager.mode
                val isOnCall = (mode == AudioManager.MODE_IN_CALL || 
                                mode == AudioManager.MODE_IN_COMMUNICATION || 
                                mode == AudioManager.MODE_RINGTONE)
                result.success(isOnCall)
            } else if (call.method == "restartApp") {
                val intent = packageManager.getLaunchIntentForPackage(packageName)
                if (intent != null) {
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
                    startActivity(intent)
                    Runtime.getRuntime().exit(0)
                }
            } else if (call.method == "queryMediaStore") {
                val minDurationMs = (call.argument<Any>("minDurationMs") as? Number)?.toLong() ?: 0L
                val minSizeBytes = (call.argument<Any>("minSizeBytes") as? Number)?.toLong() ?: 0L
                val includeSystemAndMessagingAudio =
                    call.argument<Boolean>("includeSystemAndMessagingAudio") ?: false
                val songs = queryMediaStoreAudio(
                    minDurationMs,
                    minSizeBytes,
                    includeSystemAndMessagingAudio
                )
                result.success(songs)
            } else if (call.method == "rescanMedia") {
                try {
                    val path = call.argument<String>("path") ?: "/storage/emulated/0"
                    android.media.MediaScannerConnection.scanFile(
                        applicationContext,
                        arrayOf(path),
                        null
                    ) { _, _ -> }
                    result.success(true)
                } catch (e: Exception) {
                    result.success(false)
                }
            } else if (call.method == "getEmbeddedPicture") {
                val path = call.argument<String>("path")
                if (path != null) {
                    try {
                        val mmr = MediaMetadataRetriever()
                        mmr.setDataSource(path)
                        val artBytes = mmr.embeddedPicture
                        mmr.release()
                        result.success(artBytes)
                    } catch (e: Exception) {
                        result.success(null)
                    }
                } else {
                    result.success(null)
                }
            } else if (call.method == "pickSafFolder") {
                // Storage Access Framework folder pick, used for "Add folder"
                // instead of MANAGE_EXTERNAL_STORAGE (Play Store disallows the
                // latter for a media-player app). The OS persists the grant
                // (takePersistableUriPermission) across restarts/reboots, so
                // nothing needs to be tracked on the Dart side.
                try {
                    pendingSafResult = result
                    val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)
                    intent.addFlags(
                        Intent.FLAG_GRANT_READ_URI_PERMISSION or
                        Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION
                    )
                    startActivityForResult(intent, SAF_PICK_FOLDER_REQUEST_CODE)
                } catch (e: Exception) {
                    pendingSafResult = null
                    result.error("SAF_PICK_FAILED", e.message, null)
                }
            } else if (call.method == "listSafAudioFiles") {
                val extensions = call.argument<List<String>>("extensions") ?: emptyList()
                // Recursive DocumentsContract listing does binder round-trips
                // per directory level - keep it off the platform/UI thread.
                Thread {
                    val files = listSafAudioFiles(extensions)
                    runOnUiThread { result.success(files) }
                }.start()
            } else if (call.method == "releaseSafFolder") {
                val path = call.argument<String>("path")
                if (path != null) {
                    releaseSafFolder(path)
                }
                result.success(null)
            } else if (call.method == "getEmbeddedLyrics") {
                val path = call.argument<String>("path")
                if (path == null) {
                    result.success(null)
                } else {
                    // Tag parsing does real file I/O - keep it off the
                    // platform/UI thread, same as the SAF folder listing above.
                    Thread {
                        val lyrics = readEmbeddedLyrics(path)
                        runOnUiThread { result.success(lyrics) }
                    }.start()
                }
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WIDGET_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "updateWidgetState") {
                val title = call.argument<String>("title") ?: "No song playing"
                val artist = call.argument<String>("artist") ?: ""
                val isPlaying = call.argument<Boolean>("isPlaying") ?: false
                val isShuffle = call.argument<Boolean>("isShuffle") ?: false
                val repeatMode = (call.argument<Any>("repeatMode") as? Number)?.toInt() ?: 0
                val lyrics = call.argument<String>("lyrics") ?: ""
                val nextLyrics = call.argument<String>("nextLyrics") ?: ""
                val artPath = call.argument<String>("artPath") ?: ""
                var accentColor = (call.argument<Any>("accentColor") as? Number)?.toInt() ?: 0
                val position = (call.argument<Any>("position") as? Number)?.toLong() ?: 0L
                val duration = (call.argument<Any>("duration") as? Number)?.toLong() ?: 0L

                Log.d("PlayerWidget", "MainActivity: updateWidgetState: title=$title, artist=$artist, isPlaying=$isPlaying, accentColor=$accentColor")

                // If accentColor is transparent or zero, fallback to premium green
                if (accentColor == 0) {
                    accentColor = Color.parseColor("#55DF69")
                }

                val prefs = es.antonborri.home_widget.HomeWidgetPlugin.getData(this)
                val oldTitle = prefs.getString("title", "")
                prefs.edit().apply {
                    if (title != oldTitle) {
                        putInt("currentLyricIndex", 0)
                        putString("lastSavedLyric", "")
                    }
                    putString("title", title)
                    putString("artist", artist)
                    putBoolean("isPlaying", isPlaying)
                    putBoolean("isShuffle", isShuffle)
                    putInt("repeatMode", repeatMode)
                    putString("lyrics", lyrics)
                    putString("nextLyrics", nextLyrics)
                    putString("artPath", artPath)
                    putInt("accentColor", accentColor)
                    putLong("position", position)
                    putLong("duration", duration)
                    apply()
                }

                // Trigger widget update for all 4 providers
                val appWidgetManager = AppWidgetManager.getInstance(this)
                val providers = listOf(
                    PlayerWidgetProvider::class.java,
                    PlayerWidgetProviderSquareArtwork::class.java,
                    PlayerWidgetProviderSquareProgress::class.java,
                    PlayerWidgetProviderLargeLyrics::class.java
                )
                for (provider in providers) {
                    val componentName = ComponentName(this, provider)
                    val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
                    Log.d("PlayerWidget", "MainActivity: updating widget IDs count for ${provider.simpleName} = ${appWidgetIds.size}")
                    for (appWidgetId in appWidgetIds) {
                        PlayerWidgetProvider.updateWidget(this, appWidgetManager, appWidgetId, provider)
                    }
                }

                result.success(null)
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WAKELOCK_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "acquire" -> {
                    acquireWakeLock()
                    result.success(null)
                }
                "release" -> {
                    releaseWakeLock()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun acquireWakeLock() {
        try {
            if (wakeLock == null) {
                val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
                wakeLock = powerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "LooperPlayer:PlaybackWakeLock")
            }
            if (wakeLock?.isHeld == false) {
                wakeLock?.acquire()
                Log.d("LooperWakeLock", "Partial WakeLock acquired")
            }
        } catch (e: Exception) {
            Log.e("LooperWakeLock", "Error acquiring wakeLock", e)
        }
    }

    private fun releaseWakeLock() {
        try {
            if (wakeLock?.isHeld == true) {
                wakeLock?.release()
                Log.d("LooperWakeLock", "Partial WakeLock released")
            }
        } catch (e: Exception) {
            Log.e("LooperWakeLock", "Error releasing wakeLock", e)
        }
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != SAF_PICK_FOLDER_REQUEST_CODE) return

        val pending = pendingSafResult
        pendingSafResult = null
        val treeUri = data?.data
        if (resultCode != Activity.RESULT_OK || treeUri == null) {
            pending?.success(null) // user cancelled the picker
            return
        }

        try {
            contentResolver.takePersistableUriPermission(
                treeUri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION
            )
        } catch (e: Exception) {
            Log.e("SafFolderPicker", "Failed to persist URI permission", e)
        }

        val resolvedPath = resolveTreeUriToPath(treeUri)
        if (resolvedPath == null) {
            // Not backed by local/SD storage (e.g. a cloud document provider) -
            // the app can't do anything useful with it, so drop the grant.
            try {
                contentResolver.releasePersistableUriPermission(
                    treeUri,
                    Intent.FLAG_GRANT_READ_URI_PERMISSION
                )
            } catch (_: Exception) {}
            pending?.error(
                "UNSUPPORTED_PROVIDER",
                "Please choose a folder on this device's internal storage or SD card.",
                null
            )
            return
        }

        // Proactively index the folder: scoped storage grants raw filesystem
        // path reads to MediaStore-indexed audio files even without a broad
        // storage permission, so this makes common formats immediately
        // readable by the ordinary scan/metadata code path.
        try {
            android.media.MediaScannerConnection.scanFile(
                applicationContext,
                arrayOf(resolvedPath),
                null
            ) { _, _ -> }
        } catch (_: Exception) {}

        pending?.success(resolvedPath)
    }

    /// Resolves a tree Uri from the default local-storage document provider
    /// (internal storage or an SD card) to its real absolute filesystem path.
    /// Returns null for any other provider (e.g. a cloud-backed picker).
    private fun resolveTreeUriToPath(treeUri: android.net.Uri): String? {
        if (treeUri.authority != "com.android.externalstorage.documents") return null
        val docId = try {
            android.provider.DocumentsContract.getTreeDocumentId(treeUri)
        } catch (e: Exception) {
            null
        } ?: return null

        val split = docId.split(":", limit = 2)
        val volumeId = split.getOrNull(0) ?: return null
        val relativePath = split.getOrNull(1) ?: ""
        val root = if (volumeId.equals("primary", ignoreCase = true)) {
            "/storage/emulated/0"
        } else {
            "/storage/$volumeId"
        }
        return if (relativePath.isEmpty()) root else "$root/$relativePath"
    }

    /// Recursively lists every file matching [lowerExtensions] across all
    /// currently-persisted local-storage SAF folder grants.
    private fun listSafAudioFiles(extensions: List<String>): List<String> {
        val results = mutableListOf<String>()
        val lowerExtensions = extensions.map { it.lowercase() }.toSet()
        try {
            for (perm in contentResolver.persistedUriPermissions) {
                if (!perm.isReadPermission) continue
                val treeUri = perm.uri
                val rootPath = resolveTreeUriToPath(treeUri) ?: continue
                val rootDocId = try {
                    android.provider.DocumentsContract.getTreeDocumentId(treeUri)
                } catch (e: Exception) {
                    null
                } ?: continue
                walkSafTree(treeUri, rootDocId, rootPath, lowerExtensions, results)
            }
        } catch (e: Exception) {
            Log.e("SafFolderQuery", "Error listing SAF audio files", e)
        }
        return results
    }

    private fun walkSafTree(
        treeUri: android.net.Uri,
        parentDocId: String,
        parentPath: String,
        lowerExtensions: Set<String>,
        results: MutableList<String>
    ) {
        val childrenUri = android.provider.DocumentsContract
            .buildChildDocumentsUriUsingTree(treeUri, parentDocId)
        val projection = arrayOf(
            android.provider.DocumentsContract.Document.COLUMN_DOCUMENT_ID,
            android.provider.DocumentsContract.Document.COLUMN_DISPLAY_NAME,
            android.provider.DocumentsContract.Document.COLUMN_MIME_TYPE
        )
        try {
            contentResolver.query(childrenUri, projection, null, null, null)?.use { cursor ->
                val idCol = cursor.getColumnIndex(android.provider.DocumentsContract.Document.COLUMN_DOCUMENT_ID)
                val nameCol = cursor.getColumnIndex(android.provider.DocumentsContract.Document.COLUMN_DISPLAY_NAME)
                val mimeCol = cursor.getColumnIndex(android.provider.DocumentsContract.Document.COLUMN_MIME_TYPE)
                while (cursor.moveToNext()) {
                    val docId = if (idCol != -1) cursor.getString(idCol) else null
                    val name = if (nameCol != -1) cursor.getString(nameCol) else null
                    if (docId == null || name == null) continue
                    val mime = if (mimeCol != -1) cursor.getString(mimeCol) else null
                    val childPath = if (parentPath.endsWith("/")) "$parentPath$name" else "$parentPath/$name"

                    if (mime == android.provider.DocumentsContract.Document.MIME_TYPE_DIR) {
                        if (name.startsWith(".")) continue
                        walkSafTree(treeUri, docId, childPath, lowerExtensions, results)
                    } else {
                        val ext = name.substringAfterLast('.', "")
                        if (ext.isNotEmpty() && lowerExtensions.contains(".${ext.lowercase()}")) {
                            results.add(childPath)
                        }
                    }
                }
            }
        } catch (e: Exception) {
            Log.e("SafFolderQuery", "Error walking SAF tree at $parentPath", e)
        }
    }

    /// Releases a previously-persisted SAF grant whose resolved root matches
    /// (or contains/is contained by) [path], e.g. when the user removes a
    /// folder from Library Folders in Settings.
    private fun releaseSafFolder(path: String) {
        try {
            for (perm in contentResolver.persistedUriPermissions) {
                val treeUri = perm.uri
                val rootPath = resolveTreeUriToPath(treeUri) ?: continue
                if (rootPath == path ||
                    path.startsWith("$rootPath/") ||
                    rootPath.startsWith("$path/")
                ) {
                    contentResolver.releasePersistableUriPermission(
                        treeUri,
                        Intent.FLAG_GRANT_READ_URI_PERMISSION
                    )
                }
            }
        } catch (e: Exception) {
            Log.e("SafFolderRelease", "Error releasing SAF folder", e)
        }
    }

    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        return io.flutter.embedding.engine.FlutterEngineCache.getInstance().get("looper_cached_engine")
    }

    override fun shouldDestroyEngineWithHost(): Boolean {
        return stopOnTaskRemoved
    }

    override fun onDestroy() {
        releaseWakeLock()
        audioFocusManager?.unregisterReceivers()
        activeEngine = null
        if (stopOnTaskRemoved) {
            io.flutter.embedding.engine.FlutterEngineCache.getInstance().remove("looper_cached_engine")
        }
        super.onDestroy()
    }

    /// Reads the embedded lyrics tag (ID3 USLT for mp3/wav, Vorbis Comment
    /// LYRICS/UNSYNCEDLYRICS for flac/ogg, MP4 (c)lyr for m4a, ...) via
    /// jaudiotagger's unified FieldKey.LYRICS mapping. metadata_god (used for
    /// title/artist/album/art elsewhere in this app) has no lyrics field, and
    /// hand-rolling binary tag parsing for untrusted files isn't worth the
    /// risk when a mature library already does this correctly.
    private fun readEmbeddedLyrics(path: String): String? {
        return try {
            val audioFile = org.jaudiotagger.audio.AudioFileIO.read(java.io.File(path))
            val tag = audioFile.tag ?: return null
            if (!tag.hasField(org.jaudiotagger.tag.FieldKey.LYRICS)) return null
            val lyrics = tag.getFirst(org.jaudiotagger.tag.FieldKey.LYRICS)
            if (lyrics.isNullOrBlank()) null else lyrics
        } catch (e: Exception) {
            // Includes formats jaudiotagger can't read, corrupt/partial
            // files, and KeyNotFoundException for tag types that don't map
            // LYRICS at all - all just "no embedded lyrics", not a crash.
            null
        } catch (e: NoClassDefFoundError) {
            Log.e("EmbeddedLyrics", "jaudiotagger format module unavailable", e)
            null
        }
    }

    private fun sendPlaybackBroadcast(title: String?, artist: String?, album: String?, duration: Long, isPlaying: Boolean) {
        val intent = Intent("com.android.music.metadatachanged")
        intent.putExtra("track", title)
        intent.putExtra("artist", artist)
        intent.putExtra("album", album)
        intent.putExtra("duration", duration)
        intent.putExtra("playing", isPlaying)
        
        // Some apps listen to these specific keys
        intent.putExtra("id", 1L)
        intent.putExtra("list_size", 1)
        
        sendBroadcast(intent)

        // Also send playstatechanged
        val stateIntent = Intent("com.android.music.playstatechanged")
        stateIntent.putExtra("playing", isPlaying)
        stateIntent.putExtra("track", title)
        sendBroadcast(stateIntent)
    }

    private fun queryMediaStoreAudio(
        minDurationMs: Long,
        minSizeBytes: Long,
        includeSystemAndMessagingAudio: Boolean
    ): List<Map<String, Any?>> {
        val audioList = mutableListOf<Map<String, Any?>>()
        try {
            val collection = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
                android.provider.MediaStore.Audio.Media.getContentUri(android.provider.MediaStore.VOLUME_EXTERNAL)
            } else {
                android.provider.MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
            }

            val projection = arrayOf(
                android.provider.MediaStore.Audio.Media._ID,
                android.provider.MediaStore.Audio.Media.TITLE,
                android.provider.MediaStore.Audio.Media.ARTIST,
                android.provider.MediaStore.Audio.Media.ALBUM,
                android.provider.MediaStore.Audio.Media.DURATION,
                android.provider.MediaStore.Audio.Media.SIZE,
                android.provider.MediaStore.Audio.Media.DATA,
                android.provider.MediaStore.Audio.Media.YEAR,
                android.provider.MediaStore.Audio.Media.TRACK
            )

            val categorySelection = if (includeSystemAndMessagingAudio) {
                "1 = 1"
            } else {
                """(${android.provider.MediaStore.Audio.Media.IS_MUSIC} != 0 OR ${android.provider.MediaStore.Audio.Media.IS_MUSIC} IS NULL)
                    AND ${android.provider.MediaStore.Audio.Media.IS_RINGTONE} = 0
                    AND ${android.provider.MediaStore.Audio.Media.IS_NOTIFICATION} = 0
                    AND ${android.provider.MediaStore.Audio.Media.IS_ALARM} = 0""".trimIndent()
            }
            val selection = """
                ($categorySelection)
                AND (${android.provider.MediaStore.Audio.Media.DURATION} >= ? OR ${android.provider.MediaStore.Audio.Media.DURATION} IS NULL)
                AND (${android.provider.MediaStore.Audio.Media.SIZE} >= ? OR ${android.provider.MediaStore.Audio.Media.SIZE} IS NULL)
            """.trimIndent()

            val selectionArgs = arrayOf(
                minDurationMs.toString(),
                minSizeBytes.toString()
            )

            contentResolver.query(
                collection,
                projection,
                selection,
                selectionArgs,
                "${android.provider.MediaStore.Audio.Media.TITLE} ASC"
            )?.use { cursor ->
                val titleCol = cursor.getColumnIndex(android.provider.MediaStore.Audio.Media.TITLE)
                val artistCol = cursor.getColumnIndex(android.provider.MediaStore.Audio.Media.ARTIST)
                val albumCol = cursor.getColumnIndex(android.provider.MediaStore.Audio.Media.ALBUM)
                val durationCol = cursor.getColumnIndex(android.provider.MediaStore.Audio.Media.DURATION)
                val sizeCol = cursor.getColumnIndex(android.provider.MediaStore.Audio.Media.SIZE)
                val pathCol = cursor.getColumnIndex(android.provider.MediaStore.Audio.Media.DATA)
                val yearCol = cursor.getColumnIndex(android.provider.MediaStore.Audio.Media.YEAR)
                val trackCol = cursor.getColumnIndex(android.provider.MediaStore.Audio.Media.TRACK)

                while (cursor.moveToNext()) {
                    val path = if (pathCol != -1) cursor.getString(pathCol) else null
                    if (path.isNullOrEmpty()) continue

                    val lowerPath = path.lowercase()
                    val fileName = java.io.File(lowerPath).name
                    val pathSegments = lowerPath.split('/').filter { it.isNotEmpty() }.toSet()
                    val isAlwaysIgnored = lowerPath.contains("/android/data/") ||
                        lowerPath.contains("/android/obb/") ||
                        lowerPath.contains("/.cache/") ||
                        lowerPath.endsWith("/.nomedia")
                    val isOptionalAudio = pathSegments.any {
                        it == "ringtones" || it == "ringtone" ||
                            it == "notifications" || it == "notification" ||
                            it == "alarms" || it == "alarm" ||
                            it == "whatsapp" || it == "whatsapp business" ||
                            it == "whatsapp voice notes" || it == "whatsapp audio" ||
                            it == "telegram audio" || it == "telegram voice"
                    } ||
                        lowerPath.contains("/system/media/audio/") ||
                        fileName.startsWith("ptt-") ||
                        fileName.startsWith("aud-")
                    if (isAlwaysIgnored || (!includeSystemAndMessagingAudio && isOptionalAudio)) {
                        continue
                    }

                    val title = if (titleCol != -1) cursor.getString(titleCol) else null
                    val artist = if (artistCol != -1) cursor.getString(artistCol) else null
                    val album = if (albumCol != -1) cursor.getString(albumCol) else null
                    val duration = if (durationCol != -1) cursor.getLong(durationCol) else 0L
                    val size = if (sizeCol != -1) cursor.getLong(sizeCol) else 0L
                    val year = if (yearCol != -1) cursor.getInt(yearCol) else 0
                    val track = if (trackCol != -1) cursor.getInt(trackCol) else 0

                    audioList.add(mapOf(
                        "path" to path,
                        "title" to title,
                        "artist" to artist,
                        "album" to album,
                        "duration" to duration,
                        "size" to size,
                        "year" to year,
                        "track" to track
                    ))
                }
            }
        } catch (e: Exception) {
            Log.e("MediaStoreQuery", "Error querying MediaStore", e)
        }
        return audioList
    }
}
