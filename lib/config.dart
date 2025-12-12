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
