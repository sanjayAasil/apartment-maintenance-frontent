import 'dart:io';
import 'dart:ui' as ui;

import 'package:apartment_maintenance_frontent/app/theme/app_theme.dart';
import 'package:apartment_maintenance_frontent/core/widgets/app_shell.dart';
import 'package:apartment_maintenance_frontent/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:apartment_maintenance_frontent/features/dashboard/domain/entities/dashboard.dart';
import 'package:apartment_maintenance_frontent/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:apartment_maintenance_frontent/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../core/widgets/app_shell_test.dart' show MockAuthBloc;
import '../../helpers/fakes.dart';
import 'dashboard_test.dart' show FakeReport;

void main() {
  for (final size in [
    const Size(390, 844),
    const Size(768, 900),
    const Size(1440, 1000),
  ]) {
    testWidgets('dashboard and shell fit ${size.width} web viewport', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      // Optional local design-review PNGs; normal tests have no filesystem dependency.
      final preview = Platform.environment['UI_PREVIEW_DIR'];
      if (preview != null) {
        final root = Platform.environment['FLUTTER_ROOT'];
        final font = File(
          '$root/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf',
        );
        if (font.existsSync()) {
          await tester.runAsync(() async {
            final loader = FontLoader('Roboto')
              ..addFont(
                Future.value(ByteData.sublistView(font.readAsBytesSync())),
              );
            await loader.load();
            final icons = File(
              '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
            );
            if (icons.existsSync()) {
              final iconLoader = FontLoader('MaterialIcons')
                ..addFont(
                  Future.value(ByteData.sublistView(icons.readAsBytesSync())),
                );
              await iconLoader.load();
            }
          });
        }
      }
      final auth = MockAuthBloc();
      when(() => auth.state).thenReturn(
        const AuthState(status: AuthStatus.authenticated, user: adminUser),
      );
      when(() => auth.stream).thenAnswer((_) => const Stream.empty());
      final cubit = DashboardCubit(FakeReport());
      await cubit.load(
        DashboardRange(
          from: DateTime.utc(2026, 9, 1),
          to: DateTime.utc(2026, 9, 30),
        ),
      );
      final router = GoRouter(
        initialLocation: '/dashboard',
        routes: [
          ShellRoute(
            builder: (_, _, child) => AppShell(child: child),
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (_, _) => const DashboardView(),
              ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);
      addTearDown(cubit.close);
      final boundaryKey = GlobalKey();
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: auth),
            BlocProvider<DashboardCubit>.value(value: cubit),
          ],
          child: RepaintBoundary(
            key: boundaryKey,
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              routerConfig: router,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Open Requests'), findsOneWidget);
      expect(tester.takeException(), isNull);
      if (preview != null) {
        await tester.runAsync(() async {
          final image =
              await (boundaryKey.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary)
                  .toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await Directory(preview).create(recursive: true);
          await File(
            '$preview/dashboard-${size.width.toInt()}.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
      if (size.width < 900) {
        await tester.tap(find.byTooltip('Open navigation menu'));
        await tester.pumpAndSettle();
        expect(find.text('Apartments'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  }
}
