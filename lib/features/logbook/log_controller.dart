import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mongo_dart/mongo_dart.dart' show ObjectId;
import 'models/log_model.dart';
import 'package:logbook_app_004/services/mongo_service.dart';
import 'package:logbook_app_004/helpers/log_helper.dart';
import 'package:logbook_app_004/services/access_control_service.dart';

class LogController {
  final dynamic currentUser;

  LogController(this.currentUser);

  final ValueNotifier<List<LogModel>> logsNotifier =
      ValueNotifier<List<LogModel>>([]);

  final Box<LogModel> _myBox = Hive.box<LogModel>('offline_logs');

  List<LogModel> get logs => logsNotifier.value;

  Future<void> loadLogs(String teamId) async {
    logsNotifier.value = _myBox.values.toList();

    try {
      final cloudData = await MongoService().getLogs(teamId);

      await _myBox.clear();
      await _myBox.addAll(cloudData);

      logsNotifier.value = cloudData;
    } catch (e) {}
  }

  Future<void> addLog(
    String title,
    String desc,
    String authorId,
    String teamId,
    bool isPublic,
    String category,
  ) async {
    final newLog = LogModel(
      id: ObjectId().oid,
      title: title,
      description: desc,
      date: DateTime.now().toIso8601String(),
      authorId: authorId,
      teamId: teamId,
      isPublic: isPublic,
      category: category,
    );

    await _myBox.add(newLog);

    logsNotifier.value = [...logsNotifier.value, newLog];

    try {
      await MongoService().insertLog(newLog);

      await LogHelper.writeLog(
        "SUCCESS: Data tersinkron ke Cloud",
        source: "log_controller.dart",
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "WARNING: Data tersimpan lokal",
        source: "log_controller.dart",
        level: 1,
      );
    }
  }

  Future<void> updateLog(
    String id,
    String title,
    String desc,
    bool isPublic,
    String category,
  ) async {
    final hiveIndex =
        _myBox.values.toList().indexWhere((e) => e.id == id);

    if (hiveIndex == -1) return;

    final oldLog = _myBox.getAt(hiveIndex)!;

    final updatedLog = LogModel(
      id: oldLog.id,
      title: title,
      description: desc,
      date: DateTime.now().toIso8601String(),
      authorId: oldLog.authorId,
      teamId: oldLog.teamId,
      isPublic: isPublic,
      category: category,
    );

    await _myBox.putAt(hiveIndex, updatedLog);

    final updatedList = [...logsNotifier.value];
    final listIndex =
        updatedList.indexWhere((e) => e.id == id);

    if (listIndex != -1) {
      updatedList[listIndex] = updatedLog;
    }

    logsNotifier.value = updatedList;

    try {
      await MongoService().updateLog(updatedLog);

      await LogHelper.writeLog(
        "SUCCESS: Update '${updatedLog.title}'",
        source: "log_controller.dart",
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "WARNING: Update lokal",
        source: "log_controller.dart",
        level: 1,
      );
    }
  }

  Future<void> removeLog(String id) async {
    final hiveIndex =
        _myBox.values.toList().indexWhere((e) => e.id == id);

    if (hiveIndex == -1) return;

    final target = _myBox.getAt(hiveIndex)!;

    bool isOwner = target.authorId == currentUser['uid'];

    if (!AccessControlService.canPerform(
      currentUser['role'],
      AccessControlService.actionDelete,
      isOwner: isOwner,
    )) {
      await LogHelper.writeLog(
        "SECURITY BREACH: Unauthorized delete attempt",
        source: "log_controller.dart",
        level: 1,
      );
      return;
    }

    await _myBox.deleteAt(hiveIndex);

    final updatedList =
        logsNotifier.value.where((e) => e.id != id).toList();

    logsNotifier.value = updatedList;

    try {
      if (target.id != null) {
        await MongoService().deleteLog(target.id!);
      }

      await LogHelper.writeLog(
        "SUCCESS: Delete '${target.title}'",
        source: "log_controller.dart",
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "WARNING: Delete lokal",
        source: "log_controller.dart",
        level: 1,
      );
    }
  }
}