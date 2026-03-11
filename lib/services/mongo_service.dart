import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logbook_app_004/features/logbook/models/log_model.dart';
import 'package:logbook_app_004/helpers/log_helper.dart';

class MongoService {
  static final MongoService _instance = MongoService._internal();

  Db? _db;
  DbCollection? _collection;

  final String _source = "mongo_service.dart";

  factory MongoService() => _instance;
  MongoService._internal();

  Future<DbCollection> _getSafeCollection() async {
    if (_db == null || !_db!.isConnected || _collection == null) {
      await connect();
    }
    return _collection!;
  }

  Future<void> connect() async {
    final dbUri = dotenv.env['MONGODB_URI'];

    if (dbUri == null) {
      throw Exception("MONGODB_URI tidak ditemukan");
    }

    _db = await Db.create(dbUri);
    await _db!.open();

    _collection = _db!.collection('logs');
  }

  Future<List<LogModel>> getLogs(String teamId) async {
    try {
      final collection = await _getSafeCollection();

      final data = await collection
          .find(where.eq('teamId', teamId))
          .toList();

      return data.map((e) => LogModel.fromMap(e)).toList();
    } catch (e) {
      await LogHelper.writeLog(
        "Fetch Error $e",
        source: _source,
        level: 1,
      );
      return [];
    }
  }

  Future<void> insertLog(LogModel log) async {
    final collection = await _getSafeCollection();
    await collection.insertOne(log.toMap());
  }

  Future<void> updateLog(LogModel log) async {
    final collection = await _getSafeCollection();

    if (log.id == null) {
      throw Exception("Log ID null");
    }

    await collection.replaceOne(
      where.id(ObjectId.fromHexString(log.id!)),
      log.toMap(),
    );
  }

  Future<void> deleteLog(String id) async {
    final collection = await _getSafeCollection();

    await collection.remove(
      where.id(ObjectId.fromHexString(id)),
    );
  }

  Future<void> close() async {
    await _db?.close();
  }
}