import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mirada/services/update_checker.dart';
import 'package:package_info_plus/package_info_plus.dart';

PackageInfo _info(String v) => PackageInfo(
      appName: 'Mirada',
      packageName: 'gitlab.httpanimations.mirada',
      version: v,
      buildNumber: '1',
    );

UpdateChecker _checker(String version, http.Client client) =>
    UpdateChecker(client: client, packageInfo: _info(version));

MockClient _jsonClient(Object body, {int status = 200}) =>
    MockClient((req) async => http.Response(jsonEncode(body), status));

void main() {
  test('reports available when a newer tag exists', () async {
    final client = _jsonClient([
      {'tag_name': 'v1.0.0'},
      {'tag_name': 'v0.2.0'},
    ]);
    final state = await _checker('0.2.0', client).check();
    expect(state, isA<UpdateAvailable>());
    final a = state as UpdateAvailable;
    expect(a.version.toString(), '1.0.0');
    expect(a.url, contains('/-/releases/v1.0.0'));
  });

  test('reports up to date at latest', () async {
    final client = _jsonClient([{'tag_name': 'v0.1.0'}]);
    expect(await _checker('0.1.0', client).check(), isA<UpdateUpToDate>());
    expect(await _checker('1.0.0', client).check(), isA<UpdateUpToDate>());
  });

  test('picks the highest semver tag, not the newest entry', () async {
    final client = _jsonClient([
      {'tag_name': 'v0.9.0'},
      {'tag_name': 'v0.10.0'},
      {'tag_name': 'nightly'},
      {'tag_name': 42},
      'junk',
    ]);
    final state = await _checker('0.1.0', client).check();
    expect((state as UpdateAvailable).tag, 'v0.10.0');
  });

  test('paginates while a page is full', () async {
    var calls = 0;
    final client = MockClient((req) async {
      calls++;
      if (calls == 1) {
        return http.Response(jsonEncode(List.filled(100, {'tag_name': 'v0.0.1'})), 200);
      }
      return http.Response(jsonEncode([{'tag_name': 'v5.0.0'}]), 200);
    });
    final state = await _checker('1.0.0', client).check();
    expect((state as UpdateAvailable).tag, 'v5.0.0');
    expect(calls, 2);
  });

  test('fails on non-200 responses', () async {
    final client = _jsonClient([], status: 404);
    expect(await _checker('0.1.0', client).check(), isA<UpdateFailed>());
  });

  test('fails on malformed body and network errors', () async {
    expect(await _checker('0.1.0', _jsonClient({'bad': 'map'})).check(), isA<UpdateFailed>());
    expect(await _checker('0.1.0', _jsonClient('not json')).check(), isA<UpdateFailed>());
    final throwing = MockClient((req) async => throw http.ClientException('down'));
    expect(await _checker('0.1.0', throwing).check(), isA<UpdateFailed>());
  });

  test('fails when installed version is unparseable', () async {
    final client = _jsonClient([{'tag_name': 'v1.0.0'}]);
    expect(await _checker('abc', client).check(), isA<UpdateFailed>());
  });

  test('dedupes concurrent checks', () async {
    var calls = 0;
    final client = MockClient((req) async {
      calls++;
      return http.Response(jsonEncode([{'tag_name': 'v1.0.0'}]), 200);
    });
    final checker = _checker('0.1.0', client);
    final results = await Future.wait([checker.check(), checker.check()]);
    expect(calls, 1);
    expect(results[0], isA<UpdateAvailable>());
    expect(results[1], isA<UpdateAvailable>());
  });

  test('projectUrl', () {
    expect(_checker('0.1.0', _jsonClient([])).projectUrl, 'https://gitlab.com/HttpAnimations/iphone-mirror');
  });
}
