import 'package:flutter/widgets.dart' hide TypeMatcher;
import 'package:flutter_provider/flutter_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart';

void main() {
  group('Test provider', () {
    testWidgets('simple usage', (tester) async {
      var buildCount = 0;
      int value;
      String s;

      final builder = Builder(
        builder: (context) {
          buildCount++;
          value = Provider.of<int>(context);
          s = Provider.of<String>(context, listen: false);
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
          buildValue = Provider.of<int>(context);
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

    testWidgets('extension method', (tester) async {
      String value;

      await tester.pumpWidget(
        Provider<String>.value(
          'Hello',
          child: Builder(
            builder: (context) {
              value = context.value<String>();
              return const SizedBox();
            },
          ),
        ),
      );

      expect(value, 'Hello');
    });

    testWidgets('disposer called', (tester) async {
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
              value = context.value(false);
              return const SizedBox();
            },
          ),
        ),
      );

      await tester.pumpWidget(const SizedBox());
    });
  });

  group(
    'Test Providers',
    () {
      testWidgets('Providers with empty providers returns child',
          (tester) async {
        await tester.pumpWidget(
          Providers(
            child: Text(
              'Hello',
              textDirection: TextDirection.ltr,
            ),
            providers: [],
          ),
        );

        expect(find.text('Hello'), findsOneWidget);
      });
      testWidgets('Providers children can only access parent providers',
          (tester) async {
        final k1 = GlobalKey();
        final k2 = GlobalKey();
        final k3 = GlobalKey();
        final p1 = Provider<int>.value(42, key: k1);
        final p2 = Provider<String>.value('foo', key: k2);
        final p3 = Provider<double>.value(44.0, key: k3);

        final keyChild = GlobalKey();
        await tester.pumpWidget(
          Providers(
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
    },
  );

  group('Test Consumer', () {
    testWidgets('Assert null builder', (tester) async {
      expect(
        () => Consumer<int>(builder: null),
        throwsAssertionError,
      );
    });

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

    testWidgets('Crashed with no builder', (tester) async {
      expect(
        () => Consumer2<int, int>(builder: null),
        throwsAssertionError,
      );
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
  });
}
