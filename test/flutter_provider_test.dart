import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' hide TypeMatcher;
import 'package:flutter_provider/flutter_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_api/test_api.dart' show TypeMatcher;

Type _typeOf<T>() => T;

void main() {
  group('Test provider', () {
    testWidgets('Diagnosticable', (tester) async {
      await tester.pumpWidget(
        Provider<String>(
          child: Container(),
          value: 'Hello',
        ),
      );

      final widget =
          tester.widget(find.byWidgetPredicate((w) => w is Provider));

      final builder = DiagnosticPropertiesBuilder();
      widget.debugFillProperties(builder);

      expect(builder.properties.length, 1);
      expect(builder.properties.first.name, 'value');
      expect(builder.properties.first.value, 'Hello');
    });

    testWidgets('Simple usage', (tester) async {
      var buildCount = 0;
      int value;
      String s;

      // We voluntarily reuse the builder instance so that later call to pumpWidget
      // don't call builder again unless subscribed to an inheritedWidget
      final builder = Builder(
        builder: (context) {
          buildCount++;
          value = Provider.of<int>(context);
          s = Provider.of<String>(context, listen: false);
          return Container();
        },
      );

      await tester.pumpWidget(
        Provider<String>(
          value: 'Hello',
          child: Provider<int>(
            value: 1,
            child: builder,
          ),
        ),
      );

      expect(value, equals(1));
      expect(s, equals('Hello'));
      expect(buildCount, equals(1));

      // nothing changed
      await tester.pumpWidget(
        Provider<String>(
          value: 'Hello',
          child: Provider<int>(
            value: 1,
            child: builder,
          ),
        ),
      );
      // didn't rebuild
      expect(buildCount, equals(1));

      // changed a value we are subscribed to
      await tester.pumpWidget(
        Provider<String>(
          value: 'Hello',
          child: Provider<int>(
            value: 2,
            child: builder,
          ),
        ),
      );
      expect(value, equals(2));
      expect(s, equals("Hello"));
      // got rebuilt
      expect(buildCount, equals(2));

      // changed a value we are _not_ subscribed to
      await tester.pumpWidget(
        Provider<String>(
          value: 'Hello world',
          child: Provider<int>(
            value: 2,
            child: builder,
          ),
        ),
      );
      // didn't get rebuilt
      expect(buildCount, equals(2));

      expect(value, equals(2));
      expect(s, equals("Hello"));
    });

    testWidgets('Throws an error if no provider found', (tester) async {
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
            .having((err) => err.type, 'type', _typeOf<Provider<String>>())
            .having((err) => err.toString(), 'toString()',
                '''Error: No Provider<String> found. To fix, please try:
  * Wrapping your MaterialApp with the Provider<T>
  * Providing full type information to Provider<T> and Provider.of<T> method
If none of these solutions work, please file a bug at:
https://github.com/hoc081098/flutter_provider/issues/new
      '''),
      );
    });

    testWidgets('update should notify', (tester) async {
      int old;
      int curr;
      int callCount = 0;
      final updateShouldNotify = (int o, int c) {
        callCount++;
        old = o;
        curr = c;
        return o != c;
      };

      int buildCount = 0;
      int buildValue;
      final builder = Builder(
        builder: (BuildContext context) {
          buildValue = Provider.of<int>(context);
          buildCount++;
          return Container();
        },
      );

      await tester.pumpWidget(
        Provider<int>(
          value: 69,
          updateShouldNotify: updateShouldNotify,
          child: builder,
        ),
      );
      expect(callCount, equals(0));
      expect(buildCount, equals(1));
      expect(buildValue, equals(69));

      // value changed
      await tester.pumpWidget(
        Provider<int>(
          value: 96,
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
        Provider<int>(
          value: 96,
          updateShouldNotify: updateShouldNotify,
          child: builder,
        ),
      );
      expect(callCount, equals(2));
      expect(old, equals(96));
      expect(curr, equals(96));
      expect(buildCount, equals(2));
    });
  });

  group('Test Providers', () {
    testWidgets('Providers with empty providers returns child', (tester) async {
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
    testWidgets('MultiProvider children can only access parent providers',
        (tester) async {
      final k1 = GlobalKey();
      final k2 = GlobalKey();
      final k3 = GlobalKey();
      final p1 = Provider(key: k1, value: 42);
      final p2 = Provider(key: k2, value: 'foo');
      final p3 = Provider(key: k3, value: 44.0);

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

      expect(find.text('Foo'), findsOneWidget);

      // p1 cannot access to /p2/p3
      expect(Provider.of<int>(k1.currentContext), 42);
      expect(
        () => Provider.of<String>(k1.currentContext),
        throwsA(
          const TypeMatcher<ProviderError>()
              .having((err) => err.type, 'type', _typeOf<Provider<String>>())
              .having((err) => err.toString(), 'toString()',
                  '''Error: No Provider<String> found. To fix, please try:
  * Wrapping your MaterialApp with the Provider<T>
  * Providing full type information to Provider<T> and Provider.of<T> method
If none of these solutions work, please file a bug at:
https://github.com/hoc081098/flutter_provider/issues/new
      '''),
        ),
      );
      expect(
        () => Provider.of<String>(k1.currentContext),
        throwsA(
          const TypeMatcher<ProviderError>()
              .having((err) => err.type, 'type', _typeOf<Provider<String>>())
              .having((err) => err.toString(), 'toString()',
                  '''Error: No Provider<String> found. To fix, please try:
  * Wrapping your MaterialApp with the Provider<T>
  * Providing full type information to Provider<T> and Provider.of<T> method
If none of these solutions work, please file a bug at:
https://github.com/hoc081098/flutter_provider/issues/new
      '''),
        ),
      );

      // p2 can access only p1
      expect(Provider.of<int>(k2.currentContext), 42);
      expect(Provider.of<String>(k2.currentContext), 'foo');
      expect(
        () => Provider.of<double>(k2.currentContext),
        throwsA(
          const TypeMatcher<ProviderError>()
              .having(
            (err) => err.type,
            'type',
            _typeOf<Provider<double>>(),
          )
              .having((err) => err.toString(), 'toString()',
                  '''Error: No Provider<double> found. To fix, please try:
  * Wrapping your MaterialApp with the Provider<T>
  * Providing full type information to Provider<T> and Provider.of<T> method
If none of these solutions work, please file a bug at:
https://github.com/hoc081098/flutter_provider/issues/new
      '''),
        ),
      );

      // p3 can access both p1 and p2
      expect(Provider.of<int>(k3.currentContext), 42);
      expect(Provider.of<String>(k3.currentContext), 'foo');
      expect(Provider.of<double>(k3.currentContext), 44);

      // the child can access them all
      expect(Provider.of<int>(keyChild.currentContext), 42);
      expect(Provider.of<String>(keyChild.currentContext), 'foo');
      expect(Provider.of<double>(keyChild.currentContext), 44);
    });
  });

  group('Test Consumer', () {
    testWidgets('Crashed with no builder', (tester) async {
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
        Provider<int>(
          value: 99,
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
            Provider<int>(value: 2),
            Provider<String>(value: 'Hello'),
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
      expect(ss, "Hello");
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
            Provider<int>(value: 2),
            Provider<String>(value: 'Hello'),
            Provider<String>(value: 'Hello2'),
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
      expect(ss1, "Hello2");
      expect(ss2, "Hello2");
    });
  });
}
