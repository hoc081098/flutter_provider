import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Provides a [value] to all descendants of this Widget. This should
/// generally be a root widget in your App
class Provider<T> extends StatefulWidget {
  final T Function(BuildContext) _factory;
  final void Function(T) _disposer;
  final bool Function(T, T) _updateShouldNotify;
  final Widget _child;

  /// [updateShouldNotify] is a callback called whenever [InheritedWidget.updateShouldNotify] is called.
  /// It should return `false` when there's no need to update its dependents.
  /// Default value of [updateShouldNotify] is returning true if old value is not equal to current value.
  const Provider.factory({
    Key key,
    @required T Function(BuildContext) factory,
    void Function(T) disposer,
    bool Function(T previous, T current) updateShouldNotify,
    Widget child,
  })  : assert(factory != null),
        _factory = factory,
        _disposer = disposer,
        _updateShouldNotify = updateShouldNotify ?? _notEquals,
        _child = child,
        super(key: key);

  /// [updateShouldNotify] is a callback called whenever [InheritedWidget.updateShouldNotify] is called.
  /// It should return `false` when there's no need to update its dependents.
  /// Default value of [updateShouldNotify] is returning true if old value is not equal to current value.
  factory Provider.value(
    T value, {
    Key key,
    bool Function(T previous, T current) updateShouldNotify,
    Widget child,
  }) {
    assert(value != null);
    return Provider.factory(
      key: key,
      factory: (_) => value,
      updateShouldNotify: updateShouldNotify,
      child: child,
    );
  }

  /// A method that can be called by descendant Widgets to retrieve the [value]
  /// from the [Provider].
  ///
  /// Important: When using this method, pass through complete type information
  /// or Flutter will be unable to find the correct [Provider]!
  ///
  /// If [listen] is true (default), later value changes will
  /// trigger a new [State.build] to widgets, and [State.didChangeDependencies] for [StatefulWidget]
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
  static T of<T>(BuildContext context, {bool listen = true}) {
    if (T == dynamic) {
      throw ProviderError();
    }

    final inheritedWidget = listen
        ? context.dependOnInheritedWidgetOfExactType<_ProviderInherited<T>>()
        : (context
            .getElementForInheritedWidgetOfExactType<_ProviderInherited<T>>()
            ?.widget as _ProviderInherited<T>);

    if (inheritedWidget == null) {
      throw ProviderError(T);
    }

    return inheritedWidget.value;
  }

  @override
  _ProviderState<T> createState() => _ProviderState<T>();

  Provider<T> _copyWithChild(Widget child) => Provider<T>.factory(
        child: child,
        factory: _factory,
        key: key,
        updateShouldNotify: _updateShouldNotify,
      );
}

extension ProviderExtension on BuildContext {
  T value<T>([bool listen = true]) => Provider.of<T>(this, listen: listen);
}

bool _notEquals<T>(T previous, T current) => previous != current;

class _ProviderState<T> extends State<Provider<T>> {
  T value;

  @override
  void initState() {
    super.initState();
    initValue();
  }

  @override
  void didUpdateWidget(Provider<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget._factory != widget._factory) {
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
    value = widget._factory(context);
    assert(value != null);
  }

  void disposeValue() {
    assert(value != null);
    widget._disposer?.call(value);
    value = null;
  }

  @override
  Widget build(BuildContext context) => _ProviderInherited(
        value: value,
        updateShouldNotifyDelegate: widget._updateShouldNotify,
        child: widget._child,
      );
}

class _ProviderInherited<T> extends InheritedWidget {
  final T value;
  final bool Function(T, T) updateShouldNotifyDelegate;

  _ProviderInherited({
    Key key,
    @required this.value,
    @required this.updateShouldNotifyDelegate,
    @required Widget child,
  })  : assert(value != null),
        assert(updateShouldNotifyDelegate != null),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(_ProviderInherited<T> oldWidget) =>
      updateShouldNotifyDelegate(oldWidget.value, value);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<T>('value', value));
  }
}

/// If the [Provider.of] method fails, this error will be thrown.
///
/// Often, when the `of` method fails, it is difficult to understand why since
/// there can be multiple causes. This error explains those causes so the user
/// can understand and fix the issue.
class ProviderError extends Error {
  /// The type of the class the user tried to retrieve
  final Type type;

  /// Creates a [ProviderError]
  ProviderError([this.type]);

  @override
  String toString() {
    if (type == null) {
      return '''Error: please specify type instead of using dynamic when calling Provider.of<T>() or context.value<T>() method.''';
    }

    return '''Error: No Provider<$type> found. To fix, please try:
  * Wrapping your MaterialApp with the Provider<$type>
  * Providing full type information to Provider<$type>, Provider.of<$type> and context.value<$type>() method
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
/// Provider<Foo>(
///   value: foo,
///   child: Provider<Bar>(
///     value: bar,
///     child: Provider<Baz>(
///       value: baz,
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
///     Provider<Foo>(value: foo),
///     Provider<Bar>(value: bar),
///     Provider<Baz>(value: baz),
///   ],
///   child: someWidget,
/// )
/// ```
///
/// Technically, these two are identical. [Providers] will convert the array into a tree.
/// This changes only the appearance of the code.
class Providers extends StatelessWidget {
  /// The list of providers that will be transformed into a tree.
  /// The tree is created from top to bottom.
  /// The first item because to topmost provider, while the last item it the direct parent of [child].
  final List<Provider<dynamic>> providers;

  /// The child of the last provider in [providers].
  /// If [providers] is empty, then [Providers] just returns [child].
  final Widget child;

  const Providers({Key key, @required this.providers, @required this.child})
      : assert(providers != null),
        assert(child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) =>
      providers.reversed.fold(child, (acc, e) => e._copyWithChild(acc));
}

/// Obtain [Provider] from its ancestors and pass its value to [builder].
/// [builder] must not be null and may be called multiple times (such as when provided value change).
class Consumer<T> extends StatelessWidget {
  /// Build a widget tree based on the value from a [Provider].
  final Widget Function(BuildContext context, T t) builder;

  const Consumer({
    Key key,
    @required this.builder,
  })  : assert(builder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) =>
      builder(context, Provider.of<T>(context));
}

/// Obtain 2 [Provider] from its ancestors and pass its value to [builder].
/// [builder] must not be null and may be called multiple times (such as when provided values change).
class Consumer2<A, B> extends StatelessWidget {
  /// Build a widget tree based on the value from a [Provider].
  final Widget Function(BuildContext context, A a, B b) builder;

  const Consumer2({
    Key key,
    @required this.builder,
  })  : assert(builder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) =>
      builder(context, Provider.of<A>(context), Provider.of<B>(context));
}

/// Obtain 3 [Provider] from its ancestors and pass its value to [builder].
/// [builder] must not be null and may be called multiple times (such as when provided values change).
class Consumer3<A, B, C> extends StatelessWidget {
  /// Build a widget tree based on the value from a [Provider].
  final Widget Function(BuildContext context, A a, B b, C c) builder;

  const Consumer3({
    Key key,
    @required this.builder,
  })  : assert(builder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => builder(
        context,
        Provider.of<A>(context),
        Provider.of<B>(context),
        Provider.of<C>(context),
      );
}

/// Obtain 4 [Provider] from its ancestors and pass its value to [builder].
/// [builder] must not be null and may be called multiple times (such as when provided values change).
class Consumer4<A, B, C, D> extends StatelessWidget {
  /// Build a widget tree based on the value from a [Provider].
  final Widget Function(BuildContext context, A a, B b, C c, D d) builder;

  const Consumer4({
    Key key,
    @required this.builder,
  })  : assert(builder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => builder(
        context,
        Provider.of<A>(context),
        Provider.of<B>(context),
        Provider.of<C>(context),
        Provider.of<D>(context),
      );
}

/// Obtain 5 [Provider] from its ancestors and pass its value to [builder].
/// [builder] must not be null and may be called multiple times (such as when provided values change).
class Consumer5<A, B, C, D, E> extends StatelessWidget {
  /// Build a widget tree based on the value from a [Provider].
  final Widget Function(BuildContext context, A a, B b, C c, D d, E e) builder;

  const Consumer5({
    Key key,
    @required this.builder,
  })  : assert(builder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => builder(
        context,
        Provider.of<A>(context),
        Provider.of<B>(context),
        Provider.of<C>(context),
        Provider.of<D>(context),
        Provider.of<E>(context),
      );
}

/// Obtain 6 [Provider] from its ancestors and pass its value to [builder].
/// [builder] must not be null and may be called multiple times (such as when provided values change).
class Consumer6<A, B, C, D, E, F> extends StatelessWidget {
  /// Build a widget tree based on the value from a [Provider].
  final Widget Function(BuildContext context, A a, B b, C c, D d, E e, F f)
      builder;

  const Consumer6({
    Key key,
    @required this.builder,
  })  : assert(builder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => builder(
        context,
        Provider.of<A>(context),
        Provider.of<B>(context),
        Provider.of<C>(context),
        Provider.of<D>(context),
        Provider.of<E>(context),
        Provider.of<F>(context),
      );
}

/// Obtain 7 [Provider] from its ancestors and pass its value to [builder].
/// [builder] must not be null and may be called multiple times (such as when provided values change).
class Consumer7<A, B, C, D, E, F, G> extends StatelessWidget {
  /// Build a widget tree based on the value from a [Provider].
  final Widget Function(BuildContext context, A a, B b, C c, D d, E e, F f, G g)
      builder;

  const Consumer7({
    Key key,
    @required this.builder,
  })  : assert(builder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => builder(
        context,
        Provider.of<A>(context),
        Provider.of<B>(context),
        Provider.of<C>(context),
        Provider.of<D>(context),
        Provider.of<E>(context),
        Provider.of<F>(context),
        Provider.of<G>(context),
      );
}

// Obtain 8 [Provider] from its ancestors and pass its value to [builder].
/// [builder] must not be null and may be called multiple times (such as when provided values change).
class Consumer8<A, B, C, D, E, F, G, H> extends StatelessWidget {
  /// Build a widget tree based on the value from a [Provider].
  final Widget Function(
      BuildContext context, A a, B b, C c, D d, E e, F f, G g, H h) builder;

  const Consumer8({
    Key key,
    @required this.builder,
  })  : assert(builder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => builder(
        context,
        Provider.of<A>(context),
        Provider.of<B>(context),
        Provider.of<C>(context),
        Provider.of<D>(context),
        Provider.of<E>(context),
        Provider.of<F>(context),
        Provider.of<G>(context),
        Provider.of<H>(context),
      );
}

// Obtain 9 [Provider] from its ancestors and pass its value to [builder].
/// [builder] must not be null and may be called multiple times (such as when provided values change).
class Consumer9<A, B, C, D, E, F, G, H, I> extends StatelessWidget {
  /// Build a widget tree based on the value from a [Provider].
  final Widget Function(
          BuildContext context, A a, B b, C c, D d, E e, F f, G g, H h, I i)
      builder;

  const Consumer9({
    Key key,
    @required this.builder,
  })  : assert(builder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => builder(
        context,
        Provider.of<A>(context),
        Provider.of<B>(context),
        Provider.of<C>(context),
        Provider.of<D>(context),
        Provider.of<E>(context),
        Provider.of<F>(context),
        Provider.of<G>(context),
        Provider.of<H>(context),
        Provider.of<I>(context),
      );
}
