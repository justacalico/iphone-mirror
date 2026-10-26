// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Irish (`ga`).
class AppLocalizationsGa extends AppLocalizations {
  AppLocalizationsGa([String locale = 'ga']) : super(locale);

  @override
  String get appTitle => 'Mirada';

  @override
  String get navMirror => 'Scáthán';

  @override
  String get navDevices => 'Gléasanna';

  @override
  String get navSettings => 'Socruithe';

  @override
  String get navAbout => 'Faoi';

  @override
  String get mirrorIdleTitle => 'Níl aon scáthánú ar siúl';

  @override
  String get mirrorIdleHint =>
      'Roghnaigh d\'iPhone in Gléasanna, nó roghnaigh an ríomhaire seo in Control Centre > Screen Mirroring ar an bhfón.';

  @override
  String mirrorWaitingVideo(Object name) {
    return 'Tá an glacadóir beo. Oscail Control Centre > Screen Mirroring ar do iPhone agus roghnaigh \"$name\".';
  }

  @override
  String get mirrorConnecting => 'Ag ceangal...';

  @override
  String get mirrorMirroring => 'Ag scáthánú';

  @override
  String get mirrorDisconnect => 'Dícheangail';

  @override
  String mirrorError(Object reason) {
    return 'Níorbh fhéidir an glacadóir a thosú: $reason';
  }

  @override
  String get devicesTitle => 'Gléasanna';

  @override
  String get devicesScan => 'Scan';

  @override
  String get devicesScanning => 'Ag scanadh...';

  @override
  String get devicesNone => 'Ní bhfuarthas aon iPhone go fóil';

  @override
  String get devicesHint =>
      'Cinntigh go bhfuil d\'iPhone díghlasáilte, ar an líonra Wi-Fi céanna, agus laistigh de raon Bluetooth.';

  @override
  String get devicesConnected => 'Ceangailte';

  @override
  String get devicesPaired => 'Péireáilte';

  @override
  String get devicesTapConnect => 'Tapáil chun ceangal';

  @override
  String get settingsTitle => 'Socruithe';

  @override
  String get settingsReceiverName => 'Ainm an ghlacadóra';

  @override
  String get settingsReceiverNameHint =>
      'Le feiceáil in Screen Mirroring ar do iPhone';

  @override
  String get settingsResolution => 'Taifeach';

  @override
  String get settingsFrameRate => 'Uasráta frámaí';

  @override
  String get settingsPin => 'Éiligh PIN';

  @override
  String get settingsAvSync => 'Sioncronú fuaime/físe';

  @override
  String get settingsLanguage => 'Teanga';

  @override
  String get languageSystem => 'Córas (réamhshocrú)';

  @override
  String get languageEnGB => 'Traditional English';

  @override
  String get languageZh => '简体中文';

  @override
  String get languageRu => 'Русский';

  @override
  String get languageGa => 'Gaeilge';

  @override
  String get settingsTheme => 'Téama';

  @override
  String get themeSystem => 'Córas (réamhshocrú)';

  @override
  String get themeLight => 'Solas';

  @override
  String get themeDark => 'Dorcha';

  @override
  String get themeOled => 'OLED';

  @override
  String get aboutTagline => 'Úsáid d\'iPhone ar do dheasc Linux.';

  @override
  String aboutVersion(Object version) {
    return 'Leagan $version';
  }

  @override
  String get checkUpdates => 'Seiceáil le haghaidh nuashonruithe';

  @override
  String get updateChecking => 'Ag seiceáil le haghaidh nuashonruithe...';

  @override
  String updateAvailable(Object version) {
    return 'Tá leagan $version ar fáil';
  }

  @override
  String get updateUpToDate => 'Tá tú cothrom le dáta';

  @override
  String get updateFailed => 'Theip ar an seiceáil nuashonruithe';

  @override
  String get aboutLicenses => 'Ceadúnais';

  @override
  String get aboutProject => 'Leathanach an tionscadail';

  @override
  String get receiverUxplayMissing =>
      'Níor aimsíodh uxplay. Suiteáil é chun scáthánú a chumasú (féach README an tionscadail).';

  @override
  String get windowTitleMinimize => 'Íoslaghdaigh';

  @override
  String get windowTitleMaximize => 'Uasmhéadaigh';

  @override
  String get windowTitleRestore => 'Athchóirigh';

  @override
  String get windowTitleClose => 'Dún';
}
