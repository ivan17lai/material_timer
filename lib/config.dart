import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as p;

/// 整個 App 的聲音設定
class AppConfig {
  final bool endSoundEnabled;       // 結束時是否播放音效
  final bool warningSoundEnabled;   // 是否啟用「即將結束提示音」
  final int warningThreshold;       // 還剩幾秒時播放提示音
  final String? customEndSoundPath; // 自訂結束音效路徑（之後要做檔案選擇時會用）

  const AppConfig({
    required this.endSoundEnabled,
    required this.warningSoundEnabled,
    required this.warningThreshold,
    required this.customEndSoundPath,
  });

  /// 預設設定
  factory AppConfig.defaults() {
    return const AppConfig(
      endSoundEnabled: true,
      warningSoundEnabled: true,
      warningThreshold: 10,
      customEndSoundPath: null, // 目前用內建 done.mp3
    );
  }

  Map<String, dynamic> toJson() => {
    'endSoundEnabled': endSoundEnabled,
    'warningSoundEnabled': warningSoundEnabled,
    'warningThreshold': warningThreshold,
    'customEndSoundPath': customEndSoundPath,
  };

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      endSoundEnabled:
      json['endSoundEnabled'] is bool ? json['endSoundEnabled'] as bool : true,
      warningSoundEnabled: json['warningSoundEnabled'] is bool
          ? json['warningSoundEnabled'] as bool
          : true,
      warningThreshold: json['warningThreshold'] is int
          ? json['warningThreshold'] as int
          : 10,
      customEndSoundPath: json['customEndSoundPath'] as String?,
    );
  }
}

/// 設定檔路徑：放在 exe 同資料夾
Future<File> _getConfigFile() async {
  final exePath = Platform.resolvedExecutable;
  final exeDir = File(exePath).parent;
  final configPath = p.join(exeDir.path, 'material_timer_config.json');
  return File(configPath);
}

/// 讀取設定
Future<AppConfig> loadConfig() async {
  try {
    final file = await _getConfigFile();
    if (!await file.exists()) {
      return AppConfig.defaults();
    }
    final text = await file.readAsString();
    final jsonMap = jsonDecode(text) as Map<String, dynamic>;
    return AppConfig.fromJson(jsonMap);
  } catch (_) {
    return AppConfig.defaults();
  }
}

/// 儲存設定
Future<void> saveConfig(AppConfig config) async {
  final file = await _getConfigFile();
  final jsonText = const JsonEncoder.withIndent('  ').convert(config.toJson());
  await file.writeAsString(jsonText);
}

// ==========================
// ✅ 計時器儲存（不改 AppConfig、不動原本 config 檔）
// 會另外建立：material_timer_timers.json（放在 exe 同資料夾）
// ==========================

Future<File> _getTimersFile() async {
  final exePath = Platform.resolvedExecutable;
  final exeDir = File(exePath).parent;
  final timersPath = p.join(exeDir.path, 'material_timer_timers.json');
  return File(timersPath);
}

/// 讀取已儲存的計時器（最多 3 個，單位：秒）
/// 回傳格式：List<int>
Future<List<int>> loadSavedTimers() async {
  try {
    final file = await _getTimersFile();
    if (!await file.exists()) return [];

    final text = await file.readAsString();
    final obj = jsonDecode(text);

    if (obj is Map && obj['timers'] is List) {
      return (obj['timers'] as List)
          .whereType<num>()
          .map((e) => e.toInt())
          .where((e) => e > 0)
          .take(3)
          .toList();
    }

    return [];
  } catch (_) {
    return [];
  }
}



/// 儲存一個計時器（秒）
/// - 去重
/// - 最新放最前
/// - 最多 3 個
Future<void> saveTimer(int seconds) async {
  if (seconds <= 0) return;

  final timers = await loadSavedTimers();

  // 去重
  timers.remove(seconds);

  // 最新放前面
  timers.insert(0, seconds);

  // 最多 3 個
  if (timers.length > 3) {
    timers.removeRange(3, timers.length);
  }

  final file = await _getTimersFile();
  final jsonText = const JsonEncoder.withIndent('  ').convert({
    'timers': timers,
  });
  await file.writeAsString(jsonText);
}

/// 刪除指定計時器（秒）
Future<void> removeTimer(int seconds) async {
  final timers = await loadSavedTimers();
  timers.remove(seconds);

  final file = await _getTimersFile();
  final jsonText = const JsonEncoder.withIndent('  ').convert({
    'timers': timers,
  });
  await file.writeAsString(jsonText);
}

/// 清空全部計時器
Future<void> clearSavedTimers() async {
  final file = await _getTimersFile();
  final jsonText = const JsonEncoder.withIndent('  ').convert({
    'timers': <int>[],
  });
  await file.writeAsString(jsonText);
}
