import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class LoggerHelper {
  static File? _logFile;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      final dir = await getApplicationSupportDirectory();
      _logFile = File('${dir.path}/app_logs.txt');
      _initialized = true;

      // Log rotation check (cap at 5MB)
      if (await _logFile!.exists()) {
        final size = await _logFile!.length();
        if (size > 5 * 1024 * 1024) {
          // Keep a backup of the previous log and clear the main one
          final backupFile = File('${dir.path}/app_logs_old.txt');
          if (await backupFile.exists()) {
            await backupFile.delete();
          }
          await _logFile!.rename(backupFile.path);
          _logFile = File('${dir.path}/app_logs.txt');
        }
      }
      
      await write('--- Session Started ---');
    } catch (e) {
      debugPrint('Failed to initialize LoggerHelper: $e');
    }
  }

  static Future<void> write(String message, [dynamic error, StackTrace? stack]) async {
    final timestamp = DateTime.now().toIso8601String();
    final logLine = '[$timestamp] $message${error != null ? '\nError: $error' : ''}${stack != null ? '\nStacktrace:\n$stack' : ''}\n';
        
    debugPrint(logLine.trim());

    if (!_initialized || _logFile == null) return;
    try {
      await _logFile!.writeAsString(logLine, mode: FileMode.append, flush: true);
    } catch (e) {
      debugPrint('LoggerHelper: Failed to write log: $e');
    }
  }

  static Future<File?> getLogFile() async {
    if (!_initialized) await init();
    return _logFile;
  }

  static Future<void> exportLogs() async {
    try {
      final file = await getLogFile();
      if (file != null && await file.exists()) {
        await Share.shareXFiles([XFile(file.path)], text: 'Looper Player Diagnostic Logs');
      }
    } catch (e) {
      write('Failed to export logs', e);
    }
  }

  static Future<void> clearLogs() async {
    try {
      final file = await getLogFile();
      if (file != null && await file.exists()) {
        await file.writeAsString('', mode: FileMode.write, flush: true);
        await write('--- Logs Cleared ---');
      }
    } catch (e) {
      write('Failed to clear logs', e);
    }
  }

  static Future<String> saveCrashLog(String error, StackTrace? stack) async {
    final timestamp = DateTime.now().toIso8601String();
    final crashContent = '=== LOOPER PLAYER CRASH REPORT ===\n'
        'Timestamp: $timestamp\n'
        'OS: ${Platform.operatingSystem} (${Platform.operatingSystemVersion})\n'
        'Error: $error\n'
        'Stacktrace:\n$stack\n'
        '==================================\n';

    // Target 1: Public Download folder on Android/Linux
    try {
      String? downloadDirPath;
      if (Platform.isAndroid) {
        downloadDirPath = '/storage/emulated/0/Download';
      } else {
        final dir = await getDownloadsDirectory();
        downloadDirPath = dir?.path;
      }

      if (downloadDirPath != null) {
        final downloadDir = Directory(downloadDirPath);
        if (await downloadDir.exists()) {
          final file = File('$downloadDirPath/looper_player_crash-logs.txt');
          await file.writeAsString(crashContent, mode: FileMode.write, flush: true);
          return file.path;
        }
      }
    } catch (e) {
      debugPrint('Failed to save crash log to Downloads: $e');
    }

    // Target 2: External Storage (Android specific app folder)
    try {
      if (Platform.isAndroid) {
        final dir = await getExternalStorageDirectory();
        if (dir != null) {
          final file = File('${dir.path}/looper_player_crash-logs.txt');
          await file.writeAsString(crashContent, mode: FileMode.write, flush: true);
          return file.path;
        }
      }
    } catch (e) {
      debugPrint('Failed to save crash log to External Storage: $e');
    }

    // Target 3: App Support Directory (Private, always works)
    try {
      final dir = await getApplicationSupportDirectory();
      final file = File('${dir.path}/looper_player_crash-logs.txt');
      await file.writeAsString(crashContent, mode: FileMode.write, flush: true);
      return file.path;
    } catch (e) {
      debugPrint('Failed to save crash log to App Support: $e');
      return '';
    }
  }

  static Future<void> shareCrashLog(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await Share.shareXFiles([XFile(file.path)], text: 'Looper Player Crash Log');
      }
    } catch (e) {
      write('Failed to share crash log', e);
    }
  }
}
