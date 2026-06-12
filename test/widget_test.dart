// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());


    

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

   testWidgets('Get framework test', (WidgetTester tester) async {
    // 启动应用程序
    await tester.pumpWidget(MyApp());

    // 等待启动完成
    await tester.pumpAndSettle();


    // 找到按钮并进行点击
    await tester.tap(find.byKey(Key('to_sgb_btn')));
    await tester.pumpAndSettle();
    // 验证是否跳转到了指定页面
    expect(find.text('Your Target Page'), findsOneWidget);

    // // 找到目标页面上的按钮并进行点击
    // await tester.tap(find.byKey(Key('your_target_button_key')));
    // await tester.pumpAndSettle();
    // // 验证按钮点击后的结果，例如是否显示了特定的文本或widget
    // expect(find.text('Button Clicked!'), findsOneWidget);
  });


  
}
