// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'root_router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $emptyTemplateRoute,
      $rootRouter,
    ];

RouteBase get $emptyTemplateRoute => GoRouteData.$route(
      path: '/templates/empty',
      factory: $EmptyTemplateRouteExtension._fromState,
    );

extension $EmptyTemplateRouteExtension on EmptyTemplateRoute {
  static EmptyTemplateRoute _fromState(GoRouterState state) =>
      EmptyTemplateRoute();

  String get location => GoRouteData.$location(
        '/templates/empty',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $rootRouter => GoRouteData.$route(
      path: '/',
      factory: $RootRouterExtension._fromState,
    );

extension $RootRouterExtension on RootRouter {
  static RootRouter _fromState(GoRouterState state) => RootRouter();

  String get location => GoRouteData.$location(
        '/',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}
