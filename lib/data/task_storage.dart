import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

/// Titik akses data tugas.
///
/// Starter memakai memori agar aplikasi dapat langsung dijalankan. Lengkapi
/// TODO 2 dengan SharedPreferences dan JSON; jangan memindahkan akses storage
/// ke widget.
class TaskStorage {
  static const String kunciTugas = 'daftar-tugas';
  TaskStorage({this.loadDelay = const Duration(milliseconds: 450)});

  static List<Task> _memory = <Task>[];

  final Duration loadDelay;

  Future<List<Task>> load({bool simulateError = false}) async {
    if (loadDelay > Duration.zero) {
      await Future<void>.delayed(loadDelay);
    }
    if (simulateError) {
      throw const FormatException('Simulasi data tersimpan yang rusak.');
    }

    // TODO 2a: baca String JSON dari SharedPreferences lalu ubah menjadi
    // List<Task> dengan Task.fromJson. JSON rusak dapat menghasilkan
    // FormatException agar UI menampilkan state error.
    // return List<Task>.of(_memory);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? mentah = prefs.getString(kunciTugas);

    if (mentah == null) {
      return List<Task>.of(_memory);
    }

    final List<dynamic> baris;
    try {
      baris = jsonDecode(mentah) as List<dynamic>;
    } on FormatException {
      throw const FormatException(
        'Data tugas tersimpan rusak dan tidak dapat dibaca sebagai JSON.',
      );
    } on TypeError {
      throw const FormatException(
        'Data tugas tersimpan bukan berbentuk daftar.',
      );
    }

    return List<Task>.generate(
      baris.length,
      (int i) => Task.fromJson(baris[i] as Map<String, dynamic>),
      growable: true,
    );
  }

  Future<void> save(List<Task> tasks) async {
    // TODO 2b: encode seluruh daftar sebagai JSON String dan tulis melalui
    // SharedPreferences. Periksa nilai bool yang dikembalikan setString.
    // _memory = List<Task>.of(tasks);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String mentah = jsonEncode(
      tasks.map((Task t) => t.toJson()).toList(growable: false),
    );

    final bool berhasil = await prefs.setString(kunciTugas, mentah);
    if (!berhasil) {
      _memory = List<Task>.of(tasks);
      throw Exception('Penyimpanan perangkat menolak penulisan data tugas.');
    }
    // await prefs.setInt(kunciVersi, versiSkema);
  }

  Future<void> clear() async {
    // TODO 2c: hapus key daftar tugas dari SharedPreferences.
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(kunciTugas);
    _memory = <Task>[];
  }

  /// Hanya untuk mengisolasi pengujian lokal.
  static void resetMemoryForTest() => _memory = <Task>[];
}
