import 'package:flutter_test/flutter_test.dart';
import 'package:tinycast/data/datasources/remote_sync_datasource.dart';

void main() {
  group('fetchAllSyncPages', () {
    test('应该按页取完所有记录并在不足一页时停止', () async {
      final all = List.generate(5, (i) => <String, dynamic>{'id': i});
      final offsets = <int>[];

      final result = await fetchAllSyncPages((offset, limit) async {
        offsets.add(offset);
        return all.skip(offset).take(limit).toList();
      }, pageSize: 2);

      expect(result, hasLength(5));
      expect(offsets, equals([0, 2, 4]));
    });

    test('总行数恰好为页大小整数倍时不应无限循环', () async {
      final all = List.generate(4, (i) => <String, dynamic>{'id': i});
      final offsets = <int>[];

      final result = await fetchAllSyncPages((offset, limit) async {
        offsets.add(offset);
        return all.skip(offset).take(limit).toList();
      }, pageSize: 2);

      expect(result, hasLength(4));
      expect(offsets, equals([0, 2, 4]));
    });

    test('空结果应只请求一次', () async {
      final offsets = <int>[];

      final result = await fetchAllSyncPages((offset, limit) async {
        offsets.add(offset);
        return <Map<String, dynamic>>[];
      }, pageSize: 2);

      expect(result, isEmpty);
      expect(offsets, equals([0]));
    });
  });
}
