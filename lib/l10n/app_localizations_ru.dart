// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Mirada';

  @override
  String get navMirror => 'Экран';

  @override
  String get navDevices => 'Устройства';

  @override
  String get navSettings => 'Настройки';

  @override
  String get navAbout => 'О программе';

  @override
  String get mirrorIdleTitle => 'Трансляция не запущена';

  @override
  String get mirrorIdleHint =>
      'Выберите iPhone на странице «Устройства» или откройте Пункт управления > Повтор экрана на телефоне.';

  @override
  String mirrorWaitingVideo(Object name) {
    return 'Приёмник запущен. На iPhone откройте Пункт управления > Повтор экрана и выберите «$name».';
  }

  @override
  String get mirrorConnecting => 'Подключение…';

  @override
  String get mirrorMirroring => 'Трансляция';

  @override
  String get mirrorDisconnect => 'Отключить';

  @override
  String mirrorError(Object reason) {
    return 'Не удалось запустить приёмник: $reason';
  }

  @override
  String get devicesTitle => 'Устройства';

  @override
  String get devicesScan => 'Поиск';

  @override
  String get devicesScanning => 'Поиск…';

  @override
  String get devicesNone => 'iPhone пока не найден';

  @override
  String get devicesHint =>
      'Убедитесь, что iPhone разблокирован, подключён к той же сети Wi-Fi и находится в зоне Bluetooth.';

  @override
  String get devicesConnected => 'Подключено';

  @override
  String get devicesPaired => 'Сопряжено';

  @override
  String get devicesTapConnect => 'Нажмите, чтобы подключить';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsReceiverName => 'Имя приёмника';

  @override
  String get settingsReceiverNameHint =>
      'Отображается в списке «Повтор экрана» на iPhone';

  @override
  String get settingsResolution => 'Разрешение';

  @override
  String get settingsFrameRate => 'Лимит кадров';

  @override
  String get settingsPin => 'Требовать PIN-код';

  @override
  String get settingsAvSync => 'Синхронизация звука';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get languageSystem => 'Как в системе (по умолчанию)';

  @override
  String get languageEnGB => 'Traditional English';

  @override
  String get languageZh => '简体中文';

  @override
  String get languageRu => 'Русский';

  @override
  String get languageGa => 'Gaeilge';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get themeSystem => 'Как в системе (по умолчанию)';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get themeOled => 'OLED';

  @override
  String get aboutTagline => 'Ваш iPhone на рабочем столе Linux.';

  @override
  String aboutVersion(Object version) {
    return 'Версия $version';
  }

  @override
  String get checkUpdates => 'Проверить обновления';

  @override
  String get updateChecking => 'Проверка обновлений…';

  @override
  String updateAvailable(Object version) {
    return 'Доступна версия $version';
  }

  @override
  String get updateUpToDate => 'Установлена последняя версия';

  @override
  String get updateFailed => 'Не удалось проверить обновления';

  @override
  String get aboutLicenses => 'Лицензии';

  @override
  String get aboutProject => 'Страница проекта';

  @override
  String get receiverUxplayMissing =>
      'uxplay не найден. Установите его для работы трансляции (см. README проекта).';

  @override
  String get windowTitleMinimize => 'Свернуть';

  @override
  String get windowTitleMaximize => 'Развернуть';

  @override
  String get windowTitleRestore => 'Восстановить';

  @override
  String get windowTitleClose => 'Закрыть';
}
