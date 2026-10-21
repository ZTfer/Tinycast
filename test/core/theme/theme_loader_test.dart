import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tinycast/core/theme/theme_loader.dart';

/// HOCON 解析器与 include 链的最小单元测试
///
/// 覆盖 [HoconParser.parse] 的纯函数逻辑（无 Flutter 依赖）与
/// [ThemeLoader.loadStyles] 的 include 链（依赖 rootBundle）。
void main() {
  group('HoconParser.parse', () {
    // ─── 基础解析 ───────────────────────────────────────────

    test('解析基本键值对', () {
      const content = '''
{
  name = "Test"
  version = 0.1
}
''';
      final result = HoconParser.parse(content);
      expect(result['name'], equals('Test'));
      expect(result['version'], equals('0.1'));
    });

    test('解析 scope opener 嵌套对象 (key {)', () {
      const content = '''
{
  palettes {
    brand {
      primary {
        light = "#FF6200EE"
      }
    }
  }
}
''';
      final result = HoconParser.parse(content);
      final palettes = result['palettes'] as Map<String, dynamic>;
      final brand = palettes['brand'] as Map<String, dynamic>;
      final primary = brand['primary'] as Map<String, dynamic>;
      expect(primary['light'], equals('#FF6200EE'));
    });

    test('解析 value opener 嵌套对象 (key = {)', () {
      const content = '''
{
  background = {
    hover = "#10000000"
    pressed = "#30000000"
  }
}
''';
      final result = HoconParser.parse(content);
      final background = result['background'] as Map<String, dynamic>;
      expect(background['hover'], equals('#10000000'));
      expect(background['pressed'], equals('#30000000'));
    });

    // ─── 注释剥离 ───────────────────────────────────────────

    test('剥离 # 注释', () {
      const content = '''
# this is a comment
name = "Test" # trailing comment
''';
      final result = HoconParser.parse(content);
      expect(result['name'], equals('Test'));
    });

    test('剥离 // 注释', () {
      const content = '''
// this is a comment
name = "Test" // trailing comment
''';
      final result = HoconParser.parse(content);
      expect(result['name'], equals('Test'));
    });

    test('不剥离字符串内的 # 字符', () {
      const content = '''
color = "#FF0000#GG"
''';
      final result = HoconParser.parse(content);
      expect(result['color'], equals('#FF0000#GG'));
    });

    // ─── 引用解析 ───────────────────────────────────────────

    test('解析 \${} 简单引用', () {
      const content = r'''
{
  base = "#FF0000"
  ref = ${base}
}
''';
      final result = HoconParser.parse(content);
      expect(result['base'], equals('#FF0000'));
      expect(result['ref'], equals('#FF0000'));
    });

    test('解析嵌套路径引用', () {
      const content = r'''
{
  palettes {
    brand {
      primary = "#FF6200EE"
    }
  }
  ref = ${palettes.brand.primary}
}
''';
      final result = HoconParser.parse(content);
      expect(result['ref'], equals('#FF6200EE'));
    });

    test('未解析的引用返回空字符串（同时输出 warning 日志）', () {
      const content = r'''
{
  ref = ${nonexistent.path}
}
''';
      final result = HoconParser.parse(content);
      expect(result['ref'], equals(''));
    });

    // ─── include 指令 ───────────────────────────────────────

    test('include 指令在 parse 结果中被跳过', () {
      const content = '''
include "colors.conf"

{
  name = "Test"
}
''';
      final result = HoconParser.parse(content);
      expect(result['name'], equals('Test'));
      // include 指令不产生键值对
      expect(result.length, equals(1));
    });

    // ─── 花括号校验（可见失败信号） ───────────────────────

    test('花括号不配平时抛出 FormatException — 多余的闭括号', () {
      const broken = '''
{
  name = "Test"
}
}
''';
      expect(
        () => HoconParser.parse(broken),
        throwsA(isA<FormatException>()),
      );
    });

    test('花括号不配平时抛出 FormatException — 未闭合的开括号', () {
      const broken = '''
{
  name = "Test"
  palettes {
    brand {
      primary = "#FF0000"
''';
      expect(
        () => HoconParser.parse(broken),
        throwsA(isA<FormatException>()),
      );
    });

    test('故意损坏的 styles.conf 片段抛出 FormatException', () {
      // 模拟损坏的 styles 片段：缺少 title 的闭括号
      const brokenStyles = '''
widgets {
  episode_item {
    title {
      fontsize = "14"
    # missing closing brace for title
  }
}
''';
      expect(
        () => HoconParser.parse(brokenStyles),
        throwsA(isA<FormatException>()),
      );
    });

    test('空内容不抛出异常', () {
      expect(HoconParser.parse(''), isEmpty);
    });

    test('仅注释内容不抛出异常', () {
      const content = '''
# just a comment
// another comment
''';
      expect(HoconParser.parse(content), isEmpty);
    });
  });

  group('ThemeLoader.buildTextStyles', () {
    test('响应式变体未声明的属性应继承基础样式', () {
      final typography = <String, dynamic>{
        'textstyles': <String, dynamic>{
          'h3': <String, dynamic>{
            'fontsize': '20',
            'fontweight': '700',
            'lineheight': '1.5',
            'letterspacing': '0.5',
            'color': 'labelPrimary',
            'desktop': <String, dynamic>{'fontsize': '14'},
          },
        },
      };

      final styles = ThemeLoader.buildTextStyles(
        typography,
        ThemeLoader.cachedThemeConfigs,
      );

      final desktopLight = styles['h3_desktop_light']!;
      expect(desktopLight.fontSize, 14,
          reason: '变体显式声明的字号应覆盖基础值');
      expect(desktopLight.fontWeight, FontWeight.w700,
          reason: '变体未声明的字重应继承基础样式');
      expect(desktopLight.height, 1.5,
          reason: '变体未声明的行高应继承基础样式');
      expect(desktopLight.letterSpacing, 0.5,
          reason: '变体未声明的字距应继承基础样式');
    });

    test('响应式变体可覆盖基础颜色', () {
      final typography = <String, dynamic>{
        'textstyles': <String, dynamic>{
          'caption1': <String, dynamic>{
            'fontsize': '12',
            'color': 'labelPrimary',
            'desktop': <String, dynamic>{'color': 'labelTertiary'},
          },
        },
      };

      final styles = ThemeLoader.buildTextStyles(
        typography,
        ThemeLoader.cachedThemeConfigs,
      );

      expect(
        styles['caption1_desktop_light']!.color,
        ThemeLoader.cachedThemeConfigs['light']!.labelTertiary,
      );
      expect(
        styles['caption1_desktop_dark']!.color,
        ThemeLoader.cachedThemeConfigs['dark']!.labelTertiary,
      );
    });
  });

  group('ThemeLoader.loadStyles (include 链)', () {
    setUp(() {
      // rootBundle 需要 TestWidgetsFlutterBinding 初始化
      TestWidgetsFlutterBinding.ensureInitialized();
      ThemeLoader.clearCache();
    });

    test('通过 include 链加载 styles.conf 并解析引用', () async {
      final result = await ThemeLoader.loadStyles();

      expect(result, isNotNull);
      // styles.conf include 了 colors.conf 和 typography.conf
      // 所以结果应包含来自三个文件的键
      expect(result!.containsKey('palettes'), isTrue,
          reason: 'colors.conf 应通过 include 被合并');
      expect(result.containsKey('textstyles'), isTrue,
          reason: 'typography.conf 应通过 include 被合并');
      expect(result.containsKey('widgets'), isTrue,
          reason: 'widgets 来自 styles.conf 自身');

      // 验证 \${} 引用已通过 include 链解析
      final widgets = result['widgets'] as Map<String, dynamic>;
      final episodeItem = widgets['episode_item'] as Map<String, dynamic>;
      final title = episodeItem['title'] as Map<String, dynamic>;

      // fontsize = ${textstyles.h3.desktop.fontsize} → "14"
      expect(title['fontsize'], equals('14'),
          reason: '引用应解析为 typography.conf 中的值');
      // color = ${palettes.label.primary.light} → "#E6000000"
      expect(title['color'], equals('#E6000000'),
          reason: '引用应解析为 colors.conf 中的值');
    });

    test('loadColors 解析 colors.conf 调色板', () async {
      final result = await ThemeLoader.loadColors();

      expect(result.containsKey('palettes'), isTrue);
      final palettes = result['palettes'] as Map<String, dynamic>;
      expect(palettes.containsKey('brand'), isTrue);
      expect(palettes.containsKey('label'), isTrue);
    });
  });
}
