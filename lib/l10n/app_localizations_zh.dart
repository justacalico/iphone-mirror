// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Mirada';

  @override
  String get navMirror => '镜像';

  @override
  String get navDevices => '设备';

  @override
  String get navSettings => '设置';

  @override
  String get navAbout => '关于';

  @override
  String get mirrorIdleTitle => '尚未开始镜像';

  @override
  String get mirrorIdleHint => '在“设备”页选择你的 iPhone，或在手机上打开控制中心 > 屏幕镜像并选择这台电脑。';

  @override
  String mirrorWaitingVideo(Object name) {
    return '接收器已就绪。在 iPhone 上打开控制中心 > 屏幕镜像，选择“$name”。';
  }

  @override
  String get mirrorConnecting => '正在连接…';

  @override
  String get mirrorMirroring => '正在镜像';

  @override
  String get mirrorDisconnect => '断开连接';

  @override
  String mirrorError(Object reason) {
    return '无法启动接收器：$reason';
  }

  @override
  String get devicesTitle => '设备';

  @override
  String get devicesScan => '扫描';

  @override
  String get devicesScanning => '正在扫描…';

  @override
  String get devicesNone => '还没有找到 iPhone';

  @override
  String get devicesHint => '请确认 iPhone 已解锁、连接同一 WiFi 网络，并且在蓝牙范围内。';

  @override
  String get devicesConnected => '已连接';

  @override
  String get devicesPaired => '已配对';

  @override
  String get devicesTapConnect => '点按连接';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsReceiverName => '接收器名称';

  @override
  String get settingsReceiverNameHint => '显示在 iPhone 的屏幕镜像列表中';

  @override
  String get settingsResolution => '分辨率';

  @override
  String get settingsFrameRate => '帧率上限';

  @override
  String get settingsPin => '需要 PIN 码';

  @override
  String get settingsAvSync => '音画同步';

  @override
  String get settingsLanguage => '语言';

  @override
  String get languageSystem => '跟随系统（默认）';

  @override
  String get languageEnGB => 'Traditional English';

  @override
  String get languageZh => '简体中文';

  @override
  String get languageRu => 'Русский';

  @override
  String get languageGa => 'Gaeilge';

  @override
  String get settingsTheme => '主题';

  @override
  String get themeSystem => '跟随系统（默认）';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get themeOled => '纯黑 OLED';

  @override
  String get aboutTagline => '在 Linux 桌面上使用你的 iPhone。';

  @override
  String aboutVersion(Object version) {
    return '版本 $version';
  }

  @override
  String get checkUpdates => '检查更新';

  @override
  String get updateChecking => '正在检查更新…';

  @override
  String updateAvailable(Object version) {
    return '新版本 $version 可用';
  }

  @override
  String get updateUpToDate => '已是最新版本';

  @override
  String get updateFailed => '检查更新失败';

  @override
  String get aboutLicenses => '许可证';

  @override
  String get aboutProject => '项目主页';

  @override
  String get receiverUxplayMissing => '未找到 uxplay。安装它才能启用镜像（见项目 README）。';

  @override
  String get windowTitleMinimize => '最小化';

  @override
  String get windowTitleMaximize => '最大化';

  @override
  String get windowTitleRestore => '还原';

  @override
  String get windowTitleClose => '关闭';
}
