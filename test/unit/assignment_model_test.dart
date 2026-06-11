import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pally/shared/models/assignment.dart';

void main() {
  group('Assignment', () {
    test('fromJson parses all fields correctly', () {
      final json = {
        'id': 'assign-1',
        'title': 'Fractions Homework',
        'type': 'PRE_CLASS',
        'dueDate': '2026-06-15',
        'status': 'PENDING',
        'modules': [
          {'id': 'mod-1', 'title': 'Fractions Intro', 'stage': 'LEARN'},
          {'id': 'mod-2', 'title': 'Adding Fractions', 'stage': 'TEST'},
        ],
      };
      final assignment = Assignment.fromJson(json);

      expect(assignment.id, 'assign-1');
      expect(assignment.title, 'Fractions Homework');
      expect(assignment.type, 'PRE_CLASS');
      expect(assignment.dueDate, '2026-06-15');
      expect(assignment.status, 'PENDING');
      expect(assignment.modules, hasLength(2));
      expect(assignment.modules[0].id, 'mod-1');
      expect(assignment.modules[0].title, 'Fractions Intro');
      expect(assignment.modules[0].stage, 'LEARN');
      expect(assignment.modules[1].stage, 'TEST');
    });

    test('fromJson uses defaults for missing optional fields', () {
      final json = {
        'id': 'assign-2',
        'title': 'Quick Review',
        'dueDate': '2026-06-20',
      };
      final assignment = Assignment.fromJson(json);

      expect(assignment.type, 'PRE_CLASS');
      expect(assignment.status, 'PENDING');
      expect(assignment.modules, isEmpty);
    });

    test('toJson round-trips correctly', () {
      const assignment = Assignment(
        id: 'assign-3',
        title: 'Revision Set',
        type: 'REVISION',
        dueDate: '2026-07-01',
        status: 'IN_PROGRESS',
        modules: [
          AssignmentModule(id: 'mod-a', title: 'Geometry', stage: 'PROVE'),
        ],
      );
      // Encode to JSON string and decode back to simulate network round-trip
      final jsonString = jsonEncode(assignment.toJson());
      final restored = Assignment.fromJson(
          jsonDecode(jsonString) as Map<String, dynamic>);

      expect(restored.id, assignment.id);
      expect(restored.title, assignment.title);
      expect(restored.type, assignment.type);
      expect(restored.status, assignment.status);
      expect(restored.modules, hasLength(1));
      expect(restored.modules[0].id, 'mod-a');
    });

    test('fromJson handles overdue status', () {
      final json = {
        'id': 'assign-4',
        'title': 'Late Work',
        'dueDate': '2026-06-01',
        'status': 'OVERDUE',
      };
      final assignment = Assignment.fromJson(json);
      expect(assignment.status, 'OVERDUE');
    });
  });

  group('AssignmentModule', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': 'mod-1',
        'title': 'Adding Fractions',
        'stage': 'TEST',
      };
      final module = AssignmentModule.fromJson(json);

      expect(module.id, 'mod-1');
      expect(module.title, 'Adding Fractions');
      expect(module.stage, 'TEST');
    });

    test('fromJson defaults stage to LEARN when missing', () {
      final json = {'id': 'mod-2', 'title': 'Decimals'};
      final module = AssignmentModule.fromJson(json);

      expect(module.stage, 'LEARN');
    });

    test('toJson round-trips correctly', () {
      const module = AssignmentModule(
        id: 'mod-3',
        title: 'Percentages',
        stage: 'COMPLETE',
      );
      final json = module.toJson();
      final restored = AssignmentModule.fromJson(json);

      expect(restored.id, module.id);
      expect(restored.title, module.title);
      expect(restored.stage, module.stage);
    });
  });
}
