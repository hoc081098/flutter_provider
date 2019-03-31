import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Provides a [value] to all descendants of this Widget. This should
/// generally be a root widget in your App
class Provider<T> extends InheritedWidget {
  /// The value exposed to other widgets.
  ///
  /// You can obtain this value this widget's descendants
  /// using [Provider.of] method
  final T value;

  /// A callback called whenever [InheritedWidget.updateShouldNotify] is called.
  /// It should return `false` when there's no need to update its dependents.
  ///
  /// Default value of [_updateShouldNotify] is [_notEquals]
  final bool Function(T, T) _updateShouldNotify;

  const Provider({
    Key key,
    @required Widget child,
    @required this.value,
    bool updateShouldNotify(T previous, T current),
  })  : assert(child != null),
        assert(value != null),
        _updateShouldNotify = updateShouldNotify ?? _notEquals,
        super(key: key, child: child);

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
    final Type type = _typeOf<Provider<T>>();
    final Provider<T> provider = listen
        ? context.inheritFromWidgetOfExactType(type)
        : context.ancestorInheritedElementForWidgetOfExactType(type)?.widget;
    if (provider == null) {
      throw ProviderError(type);
    }
    return provider.value;
  }

  @override
  bool updateShouldNotify(Provider<T> old) =>
      _updateShouldNotify(old.value, value);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('value', value));
  }

  static bool _notEquals(previous, current) => previous != current;

  static Type _typeOf<T>() => T;
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
  ProviderError(this.type);

  @override
  String toString() {
    return '''Error: No $type found. To fix, please try:
  * Wrapping your MaterialApp with the Provider<T>
  * Providing full type information to Provider<T> and Provider.of<T> method
If none of these solutions work, please file a bug at:
https://github.com/hoc081098/flutter_provider/issues/new
      ''';
  }
}

/// Obtain [Provider] from its ancestors and pass its value to [builder].
///
/// [builder] must not be null and may be called multiple times (such as when provided value change).
class Consumer<T> extends StatelessWidget {
  /// Build a widget tree based on the value from a [Provider].
  final Widget Function(BuildContext, T) builder;

  const Consumer({
    Key key,
    @required this.builder,
  })  : assert(builder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) =>
      builder(context, Provider.of<T>(context));
}
