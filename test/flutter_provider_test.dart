// @dart=2.9

import 'dart:collection';

import 'package:flutter/widgets.dart' hide TypeMatcher;
import 'package:flutter_provider/flutter_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart';

import 'assert_tests.dart' as assert_tests;

void main() {
  assert_tests.main();

  group('Test provider', () {
    testWidgets('simple usage', (tester) async {
      var buildCount = 0;
      int value;
      String s;

      final builder = Builder(
        builder: (context) {
          buildCount++;
          value = Provider.of<int>(context, listen: true);
          s = Provider.of<String>(context);
          return Container();
        },
      );

      await tester.pumpWidget(
        Provider<String>.value(
          'Hello',
          child: Provider<int>.value(
            1,
            child: builder,
          ),
        ),
      );

      expect(value, equals(1));
      expect(s, equals('Hello'));
      expect(buildCount, equals(1));

      await tester.pumpWidget(
        Provider<String>.value(
          'Hello',
          child: Provider<int>.value(
            1,
            child: builder,
          ),
        ),
      );
      expect(buildCount, equals(1));

      await tester.pumpWidget(
        Provider<String>.value(
          'Hello',
          child: Provider<int>.value(
            2,
            child: builder,
          ),
        ),
      );
      expect(value, equals(2));
      expect(s, equals('Hello'));
      expect(buildCount, equals(2));

      await tester.pumpWidget(
        Provider<String>.value(
          'Hello world',
          child: Provider<int>.value(
            2,
            child: builder,
          ),
        ),
      );
      expect(buildCount, equals(2));
      expect(value, equals(2));
      expect(s, equals('Hello'));
    });

    testWidgets('throws an error if no provider found', (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            Provider.of<String>(context);
            return Container();
          },
        ),
      );

      expect(
        tester.takeException(),
        const TypeMatcher<ProviderError>()
            .having((err) => err.type, 'type', String),
      );
    });

    testWidgets('update should notify', (tester) async {
      int old;
      int curr;
      var callCount = 0;
      final updateShouldNotify = (int o, int c) {
        callCount++;
        old = o;
        curr = c;
        return o != c;
      };

      var buildCount = 0;
      int buildValue;
      final builder = Builder(
        builder: (BuildContext context) {
          buildValue = Provider.of<int>(context, listen: true);
          buildCount++;
          return Container();
        },
      );

      await tester.pumpWidget(
        Provider<int>.value(
          69,
          updateShouldNotify: updateShouldNotify,
          child: builder,
        ),
      );
      expect(callCount, equals(0));
      expect(buildCount, equals(1));
      expect(buildValue, equals(69));

      // value changed
      await tester.pumpWidget(
        Provider<int>.value(
          96,
          updateShouldNotify: updateShouldNotify,
          child: builder,
        ),
      );
      expect(callCount, equals(1));
      expect(old, equals(69));
      expect(curr, equals(96));
      expect(buildCount, equals(2));
      expect(buildValue, equals(96));

      // value didn't change
      await tester.pumpWidget(
        Provider<int>.value(
          96,
          updateShouldNotify: updateShouldNotify,
          child: builder,
        ),
      );
      expect(callCount, equals(2));
      expect(old, equals(96));
      expect(curr, equals(96));
      expect(buildCount, equals(2));
    });

    testWidgets('update should notify has no effect if using Provider.factory',
        (tester) async {
      var buildCount = 0;
      int buildValue;
      final builder = Builder(
        builder: (BuildContext context) {
          buildValue = Provider.of<int>(context, listen: true);
          buildCount++;
          return Container();
        },
      );

      await tester.pumpWidget(
        Provider<int>.factory(
          (_) => 69,
          child: builder,
        ),
      );

      expect(buildCount, equals(1));
      expect(buildValue, equals(69));

      // value changed
      await tester.pumpWidget(
        Provider<int>.factory(
          (_) => 96,
          child: builder,
        ),
      );

      expect(buildCount, equals(1));
      expect(buildValue, equals(69));

      // value didn't change
      await tester.pumpWidget(
        Provider<int>.factory(
          (_) => 96,
          child: builder,
        ),
      );

      expect(buildCount, equals(1));
      expect(buildValue, equals(69));
    });

    testWidgets('extension method', (tester) async {
      String value;

      await tester.pumpWidget(
        Provider<String>.value(
          'Hello',
          child: Builder(
            builder: (context) {
              value = context.get<String>();
              return const SizedBox();
            },
          ),
        ),
      );

      expect(value, 'Hello');
    });

    testWidgets('disposer called', (tester) async {
      {
        String value;

        await tester.pumpWidget(
          Provider<String>.value(
            'Hello',
            disposer: expectAsync1(
              (v) {
                expect(value, 'Hello');
                expect(v, 'Hello');
              },
              count: 1,
            ),
            child: Builder(
              builder: (context) {
                value = context.get();
                return const SizedBox();
              },
            ),
          ),
        );

        await tester.pumpWidget(const SizedBox());
      }

      {
        String value;

        await tester.pumpWidget(
          Provider<String>.factory(
            (_) => 'Hello',
            disposer: expectAsync1(
              (v) {
                expect(value, 'Hello');
                expect(v, 'Hello');
              },
              count: 1,
            ),
            child: Builder(
              builder: (context) {
                value = context.get();
                return const SizedBox();
              },
            ),
          ),
        );

        await tester.pumpWidget(const SizedBox());
      }

      {
        await tester.pumpWidget(
          Provider<String>.factory(
            (_) => 'Hello',
            disposer: expectAsync1((v) => throw v, count: 0, max: 0),
            child: Builder(
              builder: (context) {
                return const SizedBox();
              },
            ),
          ),
        );

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 2));
      }
    });

    testWidgets('lazy evaluation if using Provider.factory', (tester) async {
      var call = 0;
      final key = GlobalKey();

      await tester.pumpWidget(
        Provider<String>.factory(
          (_) {
            call++;
            return 'Hello';
          },
          disposer: (v) {
            expect(v, 'Hello');
            expect(call, 1);
          },
          child: Builder(
            key: key,
            builder: (context) {
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 2));

      expect(call, 0);
      expect(key.currentContext.get<String>(), 'Hello');
      expect(call, 1);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('debugFillProperties', (tester) async {
      {
        var call = 0;
        final key = GlobalKey();

        await tester.pumpWidget(
          Provider<String>.factory(
            (_) {
              call++;
              return 'Hello';
            },
            disposer: (v) {
              expect(v, 'Hello');
              expect(call, 1);
            },
            child: Builder(
              key: key,
              builder: (context) {
                return const SizedBox();
              },
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 2));

        expect(call, 0);
        expect(
          tester.allElements.map((e) => e.toString()),
          contains(
              '_ProviderScope<String>(value: <not yet created>, type: String)'),
        );

        expect(key.currentContext.get<String>(), 'Hello');

        expect(call, 1);
        expect(
          tester.allElements.map((e) => e.toString()),
          contains('_ProviderScope<String>(value: Hello, type: String)'),
        );

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 2));
      }

      {
        final key = GlobalKey();

        await tester.pumpWidget(
          Provider<String>.value(
            'Hello',
            disposer: (v) => expect(v, 'Hello'),
            child: Builder(
              key: key,
              builder: (context) => const SizedBox(),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 2));

        expect(
          tester.allElements.map((e) => e.toString()),
          contains('_ProviderScope<String>(value: Hello, type: String)'),
        );

        expect(key.currentContext.get<String>(), 'Hello');

        expect(
          tester.allElements.map((e) => e.toString()),
          contains('_ProviderScope<String>(value: Hello, type: String)'),
        );

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 2));
      }
    });

    testWidgets(
        'didUpdateWidget called when providing difference value, using Provider.value constructor',
        (tester) async {
      await tester.pumpWidget(
        Provider<String>.factory(
          (_) => 'String 1',
          child: Builder(
            builder: (context) {
              expect(context.get<String>(), 'String 1');
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      await tester.pumpWidget(
        Provider<String>.value(
          'String 2',
          disposer: expectAsync1(
            (v) => expect(v, 'String 2'),
            count: 1,
          ),
          child: Builder(
            builder: (context) {
              expect(context.get<String>(), 'String 2');
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      await tester.pumpWidget(
        Provider<String>.value(
          'String 3',
          disposer: expectAsync1(
            (v) => expect(v, 'String 3'),
            count: 1,
          ),
          child: Builder(
            builder: (context) {
              expect(context.get<String>(), 'String 3');
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('Test Providers', () {
    testWidgets('Providers children can only access parent providers',
        (tester) async {
      final k = GlobalKey();
      final k1 = GlobalKey();
      final k2 = GlobalKey();
      final k3 = GlobalKey();

      final p1 = Provider<int>.value(42, key: k1);
      final p2 = Provider<String>.value('foo', key: k2);
      final p3 = Provider<double>.factory((_) => 44.0, key: k3);

      final keyChild = GlobalKey();
      await tester.pumpWidget(
        Providers(
          key: k,
          providers: [p1, p2, p3],
          child: Text(
            'Foo',
            key: keyChild,
            textDirection: TextDirection.ltr,
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Foo'), findsOneWidget);
      expect(
        find.byType(Providers).evaluate().single.widget,
        isA<Providers>().having((s) => s.key, 'key', k),
      );
      expect(
        find
            .byWidgetPredicate((widget) => widget is Provider<int>)
            .evaluate()
            .single
            .widget,
        isA<Provider<int>>().having((s) => s.key, 'key', k1),
      );
      expect(
        find
            .byWidgetPredicate((widget) => widget is Provider<String>)
            .evaluate()
            .single
            .widget,
        isA<Provider<String>>().having((s) => s.key, 'key', k2),
      );
      expect(
        find
            .byWidgetPredicate((widget) => widget is Provider<double>)
            .evaluate()
            .single
            .widget,
        isA<Provider<double>>().having((s) => s.key, 'key', k3),
      );

      expect(
        () => Provider.of<int>(k1.currentContext),
        throwsA(
          const TypeMatcher<ProviderError>().having(
            (err) => err.type,
            'type',
            int,
          ),
        ),
      );
      expect(
        () => Provider.of<String>(k1.currentContext),
        throwsA(
          const TypeMatcher<ProviderError>().having(
            (err) => err.type,
            'type',
            String,
          ),
        ),
      );
      expect(
        () => Provider.of<double>(k1.currentContext),
        throwsA(
          const TypeMatcher<ProviderError>().having(
            (err) => err.type,
            'type',
            double,
          ),
        ),
      );

      expect(Provider.of<int>(k2.currentContext), 42);
      expect(
        () => Provider.of<String>(k2.currentContext),
        throwsA(
          const TypeMatcher<ProviderError>().having(
            (err) => err.type,
            'type',
            String,
          ),
        ),
      );
      expect(
        () => Provider.of<double>(k2.currentContext),
        throwsA(
          const TypeMatcher<ProviderError>().having(
            (err) => err.type,
            'type',
            double,
          ),
        ),
      );

      expect(Provider.of<int>(k3.currentContext), 42);
      expect(Provider.of<String>(k3.currentContext), 'foo');
      expect(
        () => Provider.of<double>(k3.currentContext),
        throwsA(
          const TypeMatcher<ProviderError>().having(
            (err) => err.type,
            'type',
            double,
          ),
        ),
      );

      expect(Provider.of<int>(keyChild.currentContext), 42);
      expect(Provider.of<String>(keyChild.currentContext), 'foo');
      expect(Provider.of<double>(keyChild.currentContext), 44);
    });
  });

  group('Test Consumer', () {
    testWidgets('Obtains value from Provider<T> using Consumer',
        (tester) async {
      final key = GlobalKey();

      BuildContext ctx;
      int val;
      await tester.pumpWidget(
        Provider<int>.value(
          99,
          child: Consumer<int>(
            key: key,
            builder: (context, value) {
              ctx = context;
              val = value;
              return Container();
            },
          ),
        ),
      );

      expect(ctx, key.currentContext);
      expect(val, 99);
    });

    testWidgets('Obtains value from Provider<T> using Consumer2',
        (tester) async {
      final key = GlobalKey();

      BuildContext ctx;
      int ii;
      String ss;
      await tester.pumpWidget(
        Providers(
          providers: [
            Provider<int>.value(2),
            Provider<String>.value('Hello'),
          ],
          child: Consumer2<int, String>(
            key: key,
            builder: (context, i, s) {
              ctx = context;
              ii = i;
              ss = s;
              return Container();
            },
          ),
        ),
      );

      expect(ctx, key.currentContext);
      expect(ii, 2);
      expect(ss, 'Hello');
    });

    testWidgets('Obtains value from Provider<T> using Consumer3',
        (tester) async {
      final key = GlobalKey();

      BuildContext ctx;
      int ii;
      String ss1;
      String ss2;
      await tester.pumpWidget(
        Providers(
          providers: [
            Provider<int>.value(2),
            Provider<String>.value('Hello'),
            Provider<String>.value('Hello2'),
          ],
          child: Consumer3<int, String, String>(
            key: key,
            builder: (context, i, s1, s2) {
              ctx = context;
              ii = i;
              ss1 = s1;
              ss2 = s2;
              return Container();
            },
          ),
        ),
      );

      expect(ctx, key.currentContext);
      expect(ii, 2);
      expect(ss1, 'Hello2');
      expect(ss2, 'Hello2');
    });

    testWidgets('Consumer4', (tester) async {
      await tester.pumpWidget(
        Providers(
          providers: [
            Provider<int>.value(1),
            Provider<double>.value(2),
            Provider<String>.value('String'),
            Provider<bool>.value(true),
          ],
          child: Consumer4<int, double, String, bool>(
            builder: (context, v1, v2, v3, v4) {
              expect(v1, 1);
              expect(v2, 2);
              expect(v3, 'String');
              expect(v4, true);
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('Consumer5', (tester) async {
      await tester.pumpWidget(
        Providers(
          providers: [
            Provider<int>.value(1),
            Provider<double>.value(2),
            Provider<String>.value('String'),
            Provider<bool>.value(true),
            Provider<Object>.value(true),
          ],
          child: Consumer5<int, double, String, bool, Object>(
            builder: (context, v1, v2, v3, v4, v5) {
              expect(v1, 1);
              expect(v2, 2);
              expect(v3, 'String');
              expect(v4, true);
              expect(v5, true);
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('Consumer6', (tester) async {
      await tester.pumpWidget(
        Providers(
          providers: [
            Provider<int>.value(1),
            Provider<double>.value(2),
            Provider<String>.value('String'),
            Provider<bool>.value(true),
            Provider<Object>.value(true),
            Provider<List<int>>.value([1, 2, 3]),
          ],
          child: Consumer6<int, double, String, bool, Object, List<int>>(
            builder: (context, v1, v2, v3, v4, v5, v6) {
              expect(v1, 1);
              expect(v2, 2);
              expect(v3, 'String');
              expect(v4, true);
              expect(v5, true);
              expect(v6, [1, 2, 3]);
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('Consumer7', (tester) async {
      await tester.pumpWidget(
        Providers(
          providers: [
            Provider<int>.value(1),
            Provider<double>.value(2),
            Provider<String>.value('String'),
            Provider<bool>.value(true),
            Provider<Object>.value(true),
            Provider<List<int>>.value([1, 2, 3]),
            Provider<Set<int>>.value({1, 2, 3}),
          ],
          child:
              Consumer7<int, double, String, bool, Object, List<int>, Set<int>>(
            builder: (context, v1, v2, v3, v4, v5, v6, v7) {
              expect(v1, 1);
              expect(v2, 2);
              expect(v3, 'String');
              expect(v4, true);
              expect(v5, true);
              expect(v6, [1, 2, 3]);
              expect(v7, {1, 2, 3});
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('Consumer8', (tester) async {
      await tester.pumpWidget(
        Providers(
          providers: [
            Provider<int>.value(1),
            Provider<double>.value(2),
            Provider<String>.value('String'),
            Provider<bool>.value(true),
            Provider<Object>.value(true),
            Provider<List<int>>.value([1, 2, 3]),
            Provider<Set<int>>.value({1, 2, 3}),
            Provider<Map<int, String>>.value({1: '1', 2: '2', 3: '3'}),
          ],
          child: Consumer8<int, double, String, bool, Object, List<int>,
              Set<int>, Map<int, String>>(
            builder: (context, v1, v2, v3, v4, v5, v6, v7, v8) {
              expect(v1, 1);
              expect(v2, 2);
              expect(v3, 'String');
              expect(v4, true);
              expect(v5, true);
              expect(v6, [1, 2, 3]);
              expect(v7, {1, 2, 3});
              expect(v8, {1: '1', 2: '2', 3: '3'});
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('Consumer9', (tester) async {
      await tester.pumpWidget(
        Providers(
          providers: [
            Provider<int>.value(1),
            Provider<double>.value(2),
            Provider<String>.value('String'),
            Provider<bool>.value(true),
            Provider<Object>.value(true),
            Provider<List<int>>.value([1, 2, 3]),
            Provider<Set<int>>.value({1, 2, 3}),
            Provider<Map<int, String>>.value({1: '1', 2: '2', 3: '3'}),
            Provider<Queue<int>>.value(Queue.of([1, 2, 3])),
          ],
          child: Container(
            child: Consumer9<int, double, String, bool, Object, List<int>,
                Set<int>, Map<int, String>, Queue<int>>(
              builder: (context, v1, v2, v3, v4, v5, v6, v7, v8, v9) {
                expect(v1, 1);
                expect(v2, 2);
                expect(v3, 'String');
                expect(v4, true);
                expect(v5, true);
                expect(v6, [1, 2, 3]);
                expect(v7, {1, 2, 3});
                expect(v8, {1: '1', 2: '2', 3: '3'});
                expect(v9, Queue.of([1, 2, 3]));
                return Container();
              },
            ),
          ),
        ),
      );
    });
  });
}
