import 'package:flutter/services.dart';
import 'package:excel/excel.dart';
import 'package:mini_games_alif/domain/models/level_model.dart';

/// Utility class to parse Excel file with level data
class LevelParser {
  /// Singleton instance
  static final LevelParser _instance = LevelParser._internal();
  factory LevelParser() => _instance;
  LevelParser._internal();

  /// Parse Excel file with level data
  Future<List<LevelModel>> parseLevelData(String assetPath) async {
    try {
      // Read the excel file
      final ByteData data = await rootBundle.load(assetPath);
      final List<int> bytes = data.buffer.asUint8List();
      final Excel excel = Excel.decodeBytes(bytes);

      final List<LevelModel> levels = [];

      // Get the first sheet
      final Sheet? sheet = excel.tables[excel.tables.keys.first];
      if (sheet == null) return [];

      // Find header row and column indices
      int? gameIdIndex, gameNameIndex, sectionIdIndex, sectionNameIndex;
      int? subSectionIdIndex, levelIdIndex, subSectionNameIndex, levelDescIndex;
      int? instructionsIndex,
          gameDescIndex,
          sectionDescIndex,
          subSectionDescIndex;
      int? gameIconIndex, sectionIconIndex, levelIconIndex;
      int? minValueIndex, maxValueIndex, stepIndex;

      // Check the first few rows for headers
      for (int r = 0; r < 5; r++) {
        if (sheet.rows.length <= r) continue;
        final row = sheet.rows[r];

        for (int c = 0; c < row.length; c++) {
          final cell = row[c];
          if (cell == null || cell.value == null) continue;

          final header = cell.value.toString().toLowerCase();

          if (header.contains('game') && header.contains('id'))
            gameIdIndex = c;
          else if (header == 'game')
            gameNameIndex = c;
          else if (header.contains('section') && header.contains('id'))
            sectionIdIndex = c;
          else if (header == 'section')
            sectionNameIndex = c;
          else if (header.contains('subsection') && header.contains('id'))
            subSectionIdIndex = c;
          else if (header == 'level')
            levelIdIndex = c;
          else if (header.contains('sub-section') ||
              header.contains('subsection'))
            subSectionNameIndex = c;
          else if (header.contains('level') && header.contains('desc'))
            levelDescIndex = c;
          else if (header == 'instructions')
            instructionsIndex = c;
          else if (header.contains('game') && header.contains('desc'))
            gameDescIndex = c;
          else if (header.contains('section') && header.contains('desc'))
            sectionDescIndex = c;
          else if (header.contains('sub-section') && header.contains('desc'))
            subSectionDescIndex = c;
          else if (header.contains('game') && header.contains('icon'))
            gameIconIndex = c;
          else if (header.contains('section') && header.contains('icon'))
            sectionIconIndex = c;
          else if (header.contains('level') && header.contains('icon'))
            levelIconIndex = c;
          else if (header.contains('min') && header.contains('value'))
            minValueIndex = c;
          else if (header.contains('max') && header.contains('value'))
            maxValueIndex = c;
          else if (header == 'step') stepIndex = c;
        }

        // If we found at least the basic columns, break
        if (gameIdIndex != null && levelIdIndex != null) break;
      }

      // If we couldn't find the necessary headers, return empty list
      if (gameIdIndex == null || levelIdIndex == null) return [];

      // Find the first data row (skip header rows)
      int dataStartRow = 0;
      for (int r = 0; r < sheet.rows.length; r++) {
        if (sheet.rows[r].length > gameIdIndex &&
            sheet.rows[r][gameIdIndex]?.value != null &&
            sheet.rows[r][gameIdIndex]?.value.toString().isNotEmpty == true) {
          // Try to parse as int to confirm it's a data row
          try {
            int.parse(sheet.rows[r][gameIdIndex]!.value.toString());
            dataStartRow = r;
            break;
          } catch (_) {}
        }
      }

      // Parse data rows
      for (int r = dataStartRow; r < sheet.rows.length; r++) {
        final row = sheet.rows[r];
        if (row.length <= gameIdIndex || row[gameIdIndex] == null) continue;

        try {
          // Create level model from row data
          final level = LevelModel(
            gameId: _getIntValue(row, gameIdIndex) ?? 0,
            gameName: _getStringValue(row, gameNameIndex) ?? 'Number Line',
            sectionId: _getIntValue(row, sectionIdIndex) ?? 0,
            sectionName: _getStringValue(row, sectionNameIndex) ?? 'Numbers',
            subSectionId: _getIntValue(row, subSectionIdIndex),
            levelId: _getIntValue(row, levelIdIndex) ?? 0,
            subSectionName:
                _getStringValue(row, subSectionNameIndex) ?? 'Number range',
            levelDescription: _getStringValue(row, levelDescIndex) ?? '',
            instructions: _getStringValue(row, instructionsIndex) ??
                'Place the marker on the correct number',
            gameDescription: _getStringValue(row, gameDescIndex) ??
                'Learn to place numbers on a number line',
            sectionDescription: _getStringValue(row, sectionDescIndex) ??
                'Practice number line skills',
            subSectionDescription: _getStringValue(row, subSectionDescIndex) ??
                'Work with numbers in this range',
            gameIcon:
                _getStringValue(row, gameIconIndex) ?? 'Game Icon Number Line',
            sectionIcon:
                _getStringValue(row, sectionIconIndex) ?? 'default_section',
            levelIcon: _getStringValue(row, levelIconIndex) ?? 'default_level',
            minValue: _getIntValue(row, minValueIndex) ??
                _parseMinValue(_getStringValue(row, levelDescIndex) ?? ''),
            maxValue: _getIntValue(row, maxValueIndex) ??
                _parseMaxValue(_getStringValue(row, levelDescIndex) ?? ''),
            step: _getIntValue(row, stepIndex) ??
                _parseStep(_getStringValue(row, levelDescIndex) ?? ''),
            isCompleted: false,
            isUnlocked: _getIntValue(row, levelIdIndex) == 0 ||
                _getIntValue(row, levelIdIndex) ==
                    1, // Tutorial and first level unlocked
            stars: 0,
          );

          levels.add(level);
        } catch (e) {
          print('Error parsing row $r: $e');
        }
      }

      // Add a tutorial level if not present
      if (!levels.any((level) => level.levelId == 0)) {
        levels.insert(
            0,
            LevelModel(
              gameId: levels.isNotEmpty ? levels.first.gameId : 3,
              gameName: 'Number Line',
              sectionId: levels.isNotEmpty ? levels.first.sectionId : 1,
              sectionName: 'Tutorial',
              subSectionId: 0,
              levelId: 0,
              subSectionName: 'Getting Started',
              levelDescription: 'Learn how to play',
              instructions:
                  'Follow the tutorial to learn how to use the number line',
              gameDescription:
                  'Learn to place numbers on a number line to understand numerical order and values.',
              sectionDescription:
                  'Tutorial to help you get started with the Number Line game.',
              subSectionDescription:
                  'Learn the basics of using the number line interface.',
              gameIcon: 'Game Icon Number Line',
              sectionIcon: 'tutorial',
              levelIcon: 'tutorial',
              minValue: 0,
              maxValue: 10,
              step: 1,
              isCompleted: false,
              isUnlocked: true,
              stars: 0,
            ));
      }

      return levels;
    } catch (e) {
      print('Error parsing level data: $e');
      return [];
    }
  }

  // Helper methods to safely extract values from cells
  String? _getStringValue(List<dynamic> row, int? index) {
    if (index == null || index >= row.length || row[index] == null) return null;
    return row[index]!.value?.toString();
  }

  int? _getIntValue(List<dynamic> row, int? index) {
    if (index == null || index >= row.length || row[index] == null) return null;
    try {
      return int.parse(row[index]!.value.toString());
    } catch (_) {
      return null;
    }
  }

  // Fallback parsers - extract values from level description if dedicated columns aren't available
  static int _parseMinValue(String desc) {
    try {
      final parts = desc.split('to');
      if (parts.length < 2) return 0;
      return int.parse(parts[0].trim());
    } catch (e) {
      return 0;
    }
  }

  static int _parseMaxValue(String desc) {
    try {
      final parts = desc.split('to');
      if (parts.length < 2) return 10;
      final maxPart = parts[1].split('by')[0].trim();
      return int.parse(maxPart);
    } catch (e) {
      return 10;
    }
  }

  static int _parseStep(String desc) {
    try {
      if (!desc.contains('by steps of')) return 1;
      final stepPart = desc.split('by steps of')[1].trim();
      return int.parse(stepPart);
    } catch (e) {
      return 1;
    }
  }
}
