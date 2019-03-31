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

    testWidgets('Crashed with no builder', (tester) async {
      expect(
        () => Consumer<int>(builder: null),
        throwsAssertionError,
      );
    });

    testWidgets('Obtains value from Provider<T>', (tester) async {
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
  });
}
