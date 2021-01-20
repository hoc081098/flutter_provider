import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ignore_for_file: unnecessary_null_comparison

/// Provides a [value] to all descendants of this Widget. This should
/// generally be a root widget in your App
class Provider<T extends Object> extends StatefulWidget {
  final T Function(BuildContext)? _factory;
  final T? _value;

  final void Function(T)? _disposer;
  final bool Function(T, T)? _updateShouldNotify;
  final Widget? _child;

  /// Provide a value to all descendants.
  /// The value created on first access by calling [factory].
  ///
  /// The [disposer] will called when [State] of [Provider] is removed from the tree permanently ([State.dispose] called).
  const Provider.factory(
    T Function(BuildContext) factory, {
    Key? key,
    void Function(T)? disposer,
    Widget? child,
  })  : assert(factory != null),
        _factory = factory,
        _value = null,
        _disposer = disposer,
        _updateShouldNotify = null,
        _child = child,
        super(key: key);

  /// Provide a [value] to all descendants.
  ///
  /// [updateShouldNotify] is a callback called whenever [InheritedWidget.updateShouldNotify] is called.
  /// It should return `false` when there's no need to update its dependents.
  /// Default value of [updateShouldNotify] is returning true if old value is not equal to current value.
  ///
  /// The [disposer] will called when [State] of [Provider] is removed from the tree permanently ([State.dispose] called),
  /// or whenever the widget configuration changes with difference value ([State.didUpdateWidget] called).
  const Provider.value(
    T value, {
    Key? key,
    void Function(T)? disposer,
    bool Function(T previous, T current)? updateShouldNotify,
    Widget? child,
  })  : assert(value != null),
        _factory = null,
        _value = value,
        _disposer = disposer,
        _updateShouldNotify = updateShouldNotify ?? _notEquals,
        _child = child,
        super(key: key);

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

  @override
  State<Provider<T>> createState() {
    return _value != null
        ? _ValueProviderState<T>()
        : _FactoryProviderState<T>();
  }

  Provider<T> _copyWithChild(Widget child) {
    if (_value != null) {
      return Provider<T>.value(
        _value!,
        child: child,
        key: key,
        updateShouldNotify: _updateShouldNotify!,
        disposer: _disposer,
      );
    } else {
      assert(_factory != null);
      return Provider<T>.factory(
        _factory!,
        child: child,
        key: key,
        disposer: _disposer,
      );
    }
  }
}

/// Retrieve the value from the [Provider] by this [BuildContext].
extension ProviderExtension on BuildContext {
  /// Retrieve the value from the [Provider] by this [BuildContext].
  /// See [Provider.of].
  T get<T extends Object>({bool listen = false}) =>
      Provider.of<T>(this, listen: listen);
}

bool _notEquals<T>(T previous, T current) => previous != current;

class _FactoryProviderState<T extends Object> extends State<Provider<T>> {
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
      value = widget._factory!(context);
      assert(value != null);
    }
  }

  void disposeValue() {
    if (value != null) {
      widget._disposer?.call(value!);
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
      child: widget._child!,
    );
  }
}

class _ValueProviderState<T extends Object> extends State<Provider<T>> {
  T? value;

  @override
  void initState() {
    super.initState();
    initValue();
  }

  @override
  void didUpdateWidget(covariant Provider<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldValue = oldWidget._value;
    assert(oldValue != null, 'Only support for Provider.value constructor');

    if (oldValue! != widget._value!) {
      disposeValue();
      initValue();
    }
  }

  @override
  void dispose() {
    disposeValue();
    super.dispose();
  }

  void initValue() {
    value = widget._value!;
    assert(value != null);
  }

  void disposeValue() {
    assert(value != null);
    widget._disposer?.call(value!);
    value = null;
  }

  @override
  Widget build(BuildContext context) {
    return _ProviderScope<T>(
      value: value!,
      updateShouldNotifyDelegate: widget._updateShouldNotify,
      child: widget._child!,
    );
  }
}

class _ProviderScope<T extends Object> extends InheritedWidget {
  final T Function()? getValue;
  final T? value;
  final bool Function(T, T)? updateShouldNotifyDelegate;

  T get requireValue => value ?? getValue!();

  _ProviderScope({
    Key? key,
    this.getValue,
    this.value,
    this.updateShouldNotifyDelegate,
    required Widget child,
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

    properties.add(DiagnosticsProperty<T>('value', requireValue));
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
