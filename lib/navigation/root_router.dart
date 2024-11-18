import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:invoice_bot/modules/empty_template/empty_template.dart';

part 'root_router.g.dart';

@TypedGoRoute<EmptyTemplateRoute>(path: '/templates/empty')
@immutable
class EmptyTemplateRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const EmptyTemplateScreen();
  }
}

@TypedGoRoute<RootRouter>(
  path: '/',
)
@immutable
class RootRouter extends GoRouteData {}
