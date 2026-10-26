import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../utils/version.dart';

sealed class UpdateState {
  const UpdateState();
}

class UpdateIdle extends UpdateState {
  const UpdateIdle();
}

class UpdateChecking extends UpdateState {
  const UpdateChecking();
}

class UpdateUpToDate extends UpdateState {
  const UpdateUpToDate();
}

class UpdateFailed extends UpdateState {
  const UpdateFailed();
}

class UpdateAvailable extends UpdateState {
  final Version version;
  final String tag;
  const UpdateAvailable(this.version, this.tag);

  String get url => 'https://gitlab.com/HttpAnimations/iphone-mirror/-/releases/$tag';
}

class UpdateChecker {
  UpdateChecker({
    http.Client? client,
    this.projectPath = 'HttpAnimations/iphone-mirror',
    PackageInfo? packageInfo,
  })  : _client = client ?? http.Client(),
        _info = packageInfo;

  final http.Client _client;
  final String projectPath;
  final PackageInfo? _info;

  Future<UpdateState>? _inFlight;

  String get projectUrl => 'https://gitlab.com/$projectPath';

  Future<UpdateState> check() {
    final running = _inFlight;
    if (running != null) return running;
    final future = _check();
    _inFlight = future;
    return future.whenComplete(() => _inFlight = null);
  }

  Future<UpdateState> _check() async {
    try {
      final current = await _currentVersion();
      if (current == null) return const UpdateFailed();
      final latest = await _latestRelease();
      if (latest == null) return const UpdateFailed();
      if (latest.$1 > current) return UpdateAvailable(latest.$1, latest.$2);
      return const UpdateUpToDate();
    } catch (_) {
      return const UpdateFailed();
    }
  }

  Future<Version?> _currentVersion() async {
    final info = _info ?? await PackageInfo.fromPlatform();
    return Version.tryParse(info.version);
  }

  Future<(Version, String)?> _latestRelease() async {
    (Version, String)? best;
    for (var page = 1; page <= 5; page++) {
      final uri = Uri.https('gitlab.com', '/api/v4/projects/${Uri.encodeComponent(projectPath)}/releases', {
        'per_page': '100',
        'page': '$page',
        'order_by': 'released_at',
        'sort': 'desc',
      });
      final res = await _client.get(uri);
      if (res.statusCode != 200) return null;
      final body = jsonDecode(res.body);
      if (body is! List) return null;
      for (final item in body) {
        if (item is! Map) continue;
        final tag = item['tag_name'];
        if (tag is! String) continue;
        final v = Version.tryParse(tag);
        if (v == null) continue;
        if (best == null || v > best.$1) best = (v, tag);
      }
      if (body.length < 100) break;
    }
    return best;
  }
}
