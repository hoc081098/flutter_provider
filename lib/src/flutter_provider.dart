import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ignore_for_file: unnecessary_null_comparison

/// Provides a [value] to all descendants of this Widget. This should
/// generally be a root widget in your App
abstract class Provider<T extends Object> extends StatefulWidget {
  const Provider._({Key? key}) : super(key: key);

  /// Provide a value to all descendants.
  /// The value created on first access by calling [factory].
  ///
  /// The [disposer] will called when [State] of [Provider] is removed from the tree permanently ([State.dispose] called).
  factory Provider.factory(
    T Function(BuildContext) factory, {
    Key? key,
    void Function(T)? disposer,
    Widget? child,
  }) {
    assert(factory != null);
    return _FactoryProvider<T>(
      key: key,
      factory: factory,
      disposer: disposer,
      child: child,
    );
  }

  /// Provide a [value] to all descendants.
  ///
  /// [updateShouldNotify] is a callback called whenever [InheritedWidget.updateShouldNotify] is called.
  /// It should return `false` when there's no need to update its dependents.
  /// Default value of [updateShouldNotify] is returning true if old value is not equal to current value.
  ///
  /// The [disposer] will called when [State] of [Provider] is removed from the tree permanently ([State.dispose] called),
  /// or whenever the widget configuration changes with difference value ([State.didUpdateWidget] called).
  factory Provider.value(
    T value, {
    Key? key,
    void Function(T)? disposer,
    bool Function(T previous, T current)? updateShouldNotify,
    Widget? child,
  }) {
    assert(value != null);
    return _ValueProvider<T>(
      value: value,
      disposer: disposer,
      updateShouldNotify: updateShouldNotify ?? _notEquals,
      child: child,
      key: key,
    );
  }

  /// A method that can be called by descendant Widgets to retrieve the [value]
  /// from the [Provider].
  ///
  /// Important: When using this method, pass through complete type information
  /// or Flutter will be unable to find the correct [Provider]!
  ///
  /// If [listen] is true , later value changes will
  /// trigger a new [State.build] to widgets, and [State.didChangeDependencies] for [StatefulWidget].
  ///
  /// ### Example
  ///
  /// ```
  /// class MyWidget extends StatelessWidget {
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     final int value = Provider.of<int>(context);
  ///
  ///     return Text(value.toString();
  ///   }
  /// }
  /// ```
  static T of<T extends Object>(BuildContext context, {bool listen = false}) {
    if (T == dynamic) {
      throw ProviderError();
    }

    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<_ProviderScope<T>>()
        : (context
            .getElementForInheritedWidgetOfExactType<_ProviderScope<T>>()
            ?.widget as _ProviderScope<T>?);

    if (scope == null) {
      throw ProviderError(T);
    }

    return scope.requireValue;
  }

  @factory
  Provider<T> _copyWithChild(Widget child);
}

/// Retrieve the value from the [Provider] by this [BuildContext].
extension ProviderExtension on BuildContext {
  /// Retrieve the value from the [Provider] by this [BuildContext].
  /// See [Provider.of].
  T get<T extends Object>({bool listen = false}) =>
      Provider.of<T>(this, listen: listen);
}

bool _notEquals<T>(T previous, T current) => previous != current;

class _FactoryProvider<T extends Object> extends Provider<T> {
  final T Function(BuildContext) factory;
  final void Function(T)? disposer;
  final Widget? child;

  const _FactoryProvider({
    Key? key,
    required this.factory,
    required this.disposer,
    required this.child,
  }) : super._(key: key);

  @override
  _FactoryProviderState<T> createState() => _FactoryProviderState<T>();

  @override
  Provider<T> _copyWithChild(Widget child) {
    return Provider<T>.factory(
      factory,
      child: child,
      key: key,
      disposer: disposer,
    );
  }
}

class _FactoryProviderState<T extends Object>
    extends State<_FactoryProvider<T>> {
  T? value;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    disposeValue();
    super.dispose();
  }

  void initValue() {
    if (value == null) {
      value = widget.factory(context);
      assert(value != null);
    }
  }

  void disposeValue() {
    if (value != null) {
      widget.disposer?.call(value!);
      value = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ProviderScope<T>(
      getValue: () {
        initValue();
        return value!;
      },
      getValueNullable: () => value,
      child: widget.child!,
    );
  }
}

class _ValueProvider<T extends Object> extends Provider<T> {
  final T value;
  final void Function(T)? disposer;
  final bool Function(T, T) updateShouldNotify;
  final Widget? child;

  const _ValueProvider({
    Key? key,
    required this.value,
    required this.disposer,
    required this.updateShouldNotify,
    this.child,
  }) : super._(key: key);

  @override
  _ValueProviderState<T> createState() => _ValueProviderState<T>();

  @override
  Provider<T> _copyWithChild(Widget child) {
    return Provider<T>.value(
      value,
      child: child,
      key: key,
      updateShouldNotify: updateShouldNotify,
      disposer: disposer,
    );
  }
}

class _ValueProviderState<T extends Object> extends State<_ValueProvider<T>> {
  @override
  void didUpdateWidget(covariant _ValueProvider<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      oldWidget.disposer?.call(oldWidget.value);
    }
  }

  @override
  void dispose() {
    widget.disposer?.call(widget.value);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final val = widget.value;

    return _ProviderScope<T>(
      value: val,
      getValueNullable: () => val,
      updateShouldNotifyDelegate: widget.updateShouldNotify,
      child: widget.child!,
    );
  }
}

class _ProviderScope<T extends Object> extends InheritedWidget {
  final T Function()? getValue;
  final T? value;
  final bool Function(T, T)? updateShouldNotifyDelegate;

  /// get value but not require initialization, returns `null` when value is not created. debug purpose.
  final T? Function() getValueNullable;

  T get requireValue => value ?? getValue!();

  _ProviderScope({
    Key? key,
    this.getValue,
    this.value,
    this.updateShouldNotifyDelegate,
    required Widget child,
    required this.getValueNullable,
  })   : assert(() {
          if (getValue == null && value == null) {
            return false;
          }
          if (getValue != null && value != null) {
            return false;
          }

          return value != null
              ? updateShouldNotifyDelegate != null
              : updateShouldNotifyDelegate == null;
        }()),
        assert(child != null),
        assert(getValueNullable != null),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(_ProviderScope<T> oldWidget) {
    if (oldWidget.value != null &&
        value != null &&
        updateShouldNotifyDelegate != null) {
      return updateShouldNotifyDelegate!(oldWidget.value!, value!);
    }
    return false;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(
      DiagnosticsProperty<T>(
        'value',
        getValueNullable(),
        ifNull: '<not yet created>',
      ),
    );
    properties.add(DiagnosticsProperty<Type>('type', T));
  }
}

/// If the [Provider.of] method fails, this error will be thrown.
///
/// Often, when the `of` method fails, it is difficult to understand why since
/// there can be multiple causes. This error explains those causes so the user
/// can understand and fix the issue.
class ProviderError extends Error {
  /// The type of the class the user tried to retrieve
  final Type? type;

  /// Creates a [ProviderError]
  ProviderError([this.type]);

  @override
  String toString() {
    if (type == null) {
      return '''Error: please specify type instead of using dynamic when calling Provider.of<T>() or context.get<T>() method.''';
    }

    return '''Error: No Provider<$type> found. To fix, please try:
  * Wrapping your MaterialApp with the Provider<$type>.
  * Providing full type information to Provider<$type>, Provider.of<$type> and context.get<$type>() method.
If none of these solutions work, please file a bug at:
https://github.com/hoc081098/flutter_provider/issues/new
      ''';
  }
}

/// A provider that exposes that merges multiple other [Provider]s into one.
///
/// [Providers] is used to improve the readability and reduce the boilerplate of
/// having many nested providers.
///
/// As such, we're going from:
///
/// ```dart
/// Provider<Foo>.value(
///   foo,
///   child: Provider<Bar>.value(
///     bar,
///     child: Provider<Baz>.value(
///       baz,
///       child: someWidget,
///     )
///   )
/// )
/// ```
///
/// To:
///
/// ```dart
/// Providers(
///   providers: [
///     Provider<Foo>.value(foo),
///     Provider<Bar>.value(bar),
///     Provider<Baz>.value(baz),
///   ],
///   child: someWidget,
/// )
/// ```
///
/// Technically, these two are identical. [Providers] will convert the array into a tree.
/// This changes only the appearance of the code.
class Providers extends StatelessWidget {
  final Widget _child;

  /// The [providers] is a list of providers that will be transformed into a tree.
  /// The tree is created from top to bottom.
  /// The first item because to topmost provider, while the last item it the direct parent of [child].
  ///
  /// The [child] is child of the last provider in [providers].
  ///
  /// If [providers] is empty, then [Providers] just returns [child].
  Providers({
    Key? key,
    required List<Provider<dynamic>> providers,
    required Widget child,
  })   : assert(providers != null),
        assert(child != null),
        _child =
            providers.reversed.fold(child, (acc, e) => e._copyWithChild(acc)),
        super(key: key);

  @override
  Widget build(BuildContext context) => _child;
}
