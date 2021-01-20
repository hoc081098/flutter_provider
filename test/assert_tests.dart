// @dart=2.9

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Assert tests', () {
    test('Provider.factory with null factory', () {
      expect(
        () => Provider.factory(null),
        throwsAssertionError,
      );
    });

    test('Provider.value with null value', () {
      expect(
        () => Provider.value(null),
        throwsAssertionError,
      );
    });

    testWidgets('Provider with null child', (tester) async {
      {
        final completer = Completer<Object>.sync();

        FlutterError.onError = (e) {
          completer.complete(e.exception);
        };
        await tester.pumpWidget(
          Provider<String>.factory(
            (_) => 'String',
            child: null,
          ),
        );
        expect(await completer.future, isAssertionError);
      }

      {
        final completer = Completer<Object>.sync();

        FlutterError.onError = (e) {
          completer.complete(e.exception);
        };
        await tester.pumpWidget(
          Provider<String>.value(
            'String',
            child: null,
          ),
        );
        expect(await completer.future, isAssertionError);
      }
    });

    testWidgets('Provider.factory with factory that returns null',
        (tester) async {
      final k = GlobalKey();

      await tester.pumpWidget(
        Provider<String>.factory(
          (_) => null,
          child: SizedBox(key: k),
        ),
      );

      expect(
        () => k.currentContext.get<String>(),
        throwsAssertionError,
      );
    });

    test('Providers with null child', () {
      expect(
        () => Providers(
          providers: [Provider.value(0)],
          child: null,
        ),
        throwsAssertionError,
      );
    });

    test('Providers with null providers', () {
      expect(
        () => Providers(
          providers: null,
          child: const SizedBox(),
        ),
        throwsAssertionError,
      );
    });

    test('Providers with empty providers', () {
      expect(
        () => Providers(
          providers: [],
          child: const SizedBox(),
        ),
        throwsAssertionError,
      );
    });

    testWidgets('Provider.of with dynamic type', (tester) async {
      await tester.pumpWidget(
        Provider<String>.factory(
          (_) => 'String',
          child: Builder(
            builder: (context) {
              expect(
                () => context.get<dynamic>(),
                throwsA(isA<ProviderError>()),
              );
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
    });

    test('Consumer with null builder', () {
      [
        () => Consumer(builder: null),
        () => Consumer2(builder: null),
        () => Consumer3(builder: null),
        () => Consumer4(builder: null),
        () => Consumer5(builder: null),
        () => Consumer6(builder: null),
        () => Consumer7(builder: null),
        () => Consumer8(builder: null),
        () => Consumer9(builder: null),
      ].forEach((element) => expect(element, throwsAssertionError));
    });
  });
}
