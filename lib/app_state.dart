import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:csv/csv.dart';
import 'flutter_flow/lat_lng.dart';
import 'dart:convert';

class FFAppState extends ChangeNotifier {
  static final FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal() {
    initializePersistedState();
  }

  Future initializePersistedState() async {
    secureStorage = FlutterSecureStorage();
    _memberslist =
        (await secureStorage.getStringList('ff_memberslist'))?.map((x) {
              try {
                return jsonDecode(x);
              } catch (e) {
                print("Can't decode persisted json. Error: $e.");
                return {};
              }
            }).toList() ??
            _memberslist;
  }

  late FlutterSecureStorage secureStorage;

  List<dynamic> _memberslist = [];
  List<dynamic> get memberslist => _memberslist;
  set memberslist(List<dynamic> _value) {
    notifyListeners();

    _memberslist = _value;
    secureStorage.setStringList(
        'ff_memberslist', _value.map((x) => jsonEncode(x)).toList());
  }

  void deleteMemberslist() {
    notifyListeners();
    secureStorage.delete(key: 'ff_memberslist');
  }

  void addToMemberslist(dynamic _value) {
    notifyListeners();
    _memberslist.add(_value);
    secureStorage.setStringList(
        'ff_memberslist', _memberslist.map((x) => jsonEncode(x)).toList());
  }

  void removeFromMemberslist(dynamic _value) {
    notifyListeners();
    _memberslist.remove(_value);
    secureStorage.setStringList(
        'ff_memberslist', _memberslist.map((x) => jsonEncode(x)).toList());
  }
}

LatLng? _latLngFromString(String? val) {
  if (val == null) {
    return null;
  }
  final split = val.split(',');
  final lat = double.parse(split.first);
  final lng = double.parse(split.last);
  return LatLng(lat, lng);
}

extension FlutterSecureStorageExtensions on FlutterSecureStorage {
  Future<String?> getString(String key) async => await read(key: key);
  Future<void> setString(String key, String value) async =>
      await write(key: key, value: value);

  Future<bool?> getBool(String key) async => (await read(key: key)) == 'true';
  Future<void> setBool(String key, bool value) async =>
      await write(key: key, value: value.toString());

  Future<int?> getInt(String key) async =>
      int.tryParse(await read(key: key) ?? '');
  Future<void> setInt(String key, int value) async =>
      await write(key: key, value: value.toString());

  Future<double?> getDouble(String key) async =>
      double.tryParse(await read(key: key) ?? '');
  Future<void> setDouble(String key, double value) async =>
      await write(key: key, value: value.toString());

  Future<List<String>?> getStringList(String key) async =>
      await read(key: key).then((result) {
        if (result == null || result.isEmpty) {
          return null;
        }
        return CsvToListConverter()
            .convert(result)
            .first
            .map((e) => e.toString())
            .toList();
      });
  Future<void> setStringList(String key, List<String> value) async =>
      await write(key: key, value: ListToCsvConverter().convert([value]));
}
