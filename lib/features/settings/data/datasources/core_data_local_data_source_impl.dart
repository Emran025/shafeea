// path: lib/features/settings/data/datasources/core_data_local_data_source_impl.dart

import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shafeea/features/auth/data/datasources/auth_local_data_source.dart';

import '../../../../core/error/exceptions.dart';
import '../../../home/data/models/student_model.dart';
import 'core_data_local_data_source.dart';

const String _kUsersTable = 'users';

/// Implements the [CoreDataLocalDataSource] contract.

@LazySingleton(as: CoreDataLocalDataSource)
class CoreDataLocalDataSourceImpl implements CoreDataLocalDataSource {
  final Database database;
  final AuthLocalDataSource _authLocalDataSource;

  CoreDataLocalDataSourceImpl({
    required this.database,
    required AuthLocalDataSource authLocalDataSource,
  }) : _authLocalDataSource = authLocalDataSource;

  @override
  Future<List<StudentModel>> getStudentsForExport() async {
    final user = await _authLocalDataSource.getUser();
    final tenantId = "${user!.id}";
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        _kUsersTable,
        where: 'roleId = ? AND isDeleted = ? AND tenant_id = ?',
        whereArgs: [1, 0, tenantId],
      );
      return List.generate(maps.length, (i) {
        return StudentModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw CacheException(
        message: 'Failed to export students: ${e.toString()}',
      );
    }
  }

  @override
  Future<int> importStudents(
    List<StudentModel> students, [
    String conflictResolution = 'replace',
  ]) async {
    final user = await _authLocalDataSource.getUser();
    final tenantId = "${user!.id}";
    try {
      final batch = database.batch();
      for (final student in students) {
        final studentMap = student.toMap();
        studentMap['tenant_id'] = tenantId;
        batch.insert(
          _kUsersTable,
          studentMap,
          conflictAlgorithm: conflictResolution == 'skip'
              ? ConflictAlgorithm.ignore
              : ConflictAlgorithm.replace,
        );
      }
      final results = await batch.commit();
      return results.where((r) => r != 0).length;
    } catch (e) {
      throw CacheException(
        message: 'Failed to import students: ${e.toString()}',
      );
    }
  }

}
