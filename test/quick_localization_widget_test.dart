import 'dart:io';

import 'package:quick_localization/quick_localization.dart';
import 'package:quick_localization/src/exceptions.dart';
import 'package:quick_localization/src/localization.dart';
import 'package:easy_logger/easy_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils/test_asset_loaders.dart';

late BuildContext _context;
late String _contextTranslationValue;
late String _contextPluralValue;

class MyApp extends StatelessWidget {
  const MyApp({this.child = const MyWidget(), Key? key}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: QuickLocalization.of(context)!.locale,
      supportedLocales: QuickLocalization.of(context)!.supportedLocales,
      localizationsDelegates: QuickLocalization.of(context)!.delegates,
      home: child,
    );
  }
}

class MyWidget extends StatelessWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  Widget build(context) {
    _context = context;
    return Scaffold(
      body: Column(
        children: <Widget>[
          const Text('test').tr(),
          const Text('day').plural(1),
        ],
      ),
    );
  }
}

class MyLocalizedWidget extends StatelessWidget {
  const MyLocalizedWidget({Key? key}) : super(key: key);

  @override
  Widget build(context) {
    _context = context;
    _contextTranslationValue = context.tr('test');
    _contextPluralValue = context.plural('day', 1);

    return Scaffold(
      body: Column(
        children: <Widget>[
          Text(_contextTranslationValue),
          Text(_contextPluralValue),
        ],
      ),
    );
  }
}

void main() async {
  SharedPreferences.setMockInitialValues({});
  QuickLocalization.logger.enableLevels = <LevelMessages>[
    LevelMessages.error,
    LevelMessages.warning,
  ];
  await QuickLocalization.ensureInitialized();

  testWidgets('[QuickLocalization with  JsonAssetLoader]  test', (
    WidgetTester tester,
  ) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        QuickLocalization(
          path: 'path',
          supportedLocales: const [Locale('en', 'US')],
          assetLoader: const JsonAssetLoader(),
          child: const MyApp(),
        ),
      );
      await tester.idle();
      // The async delegator load will require build on the next frame. Thus, pump
      await tester.pump();

      expect(Localization.of(_context), isInstanceOf<Localization>());
      expect(Localization.instance, isInstanceOf<Localization>());
      expect(Localization.instance, Localization.of(_context));
      expect(QuickLocalization.of(_context)!.supportedLocales, [
        const Locale('en', 'US'),
      ]);
      expect(QuickLocalization.of(_context)!.locale, const Locale('en', 'US'));

      final trFinder = find.text('test');
      expect(trFinder, findsOneWidget);
      final pluralFinder = find.text('1 day');
      expect(pluralFinder, findsOneWidget);

      expect(tr('test'), 'test');

      expect('test'.tr(), 'test');
    });
  });

  testWidgets('[QuickLocalization with  RootBundleAssetLoader] test', (
    WidgetTester tester,
  ) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        QuickLocalization(
          path: '../../i18n',
          assetLoader: RootBundleAssetLoader.fromRootBundle(),
          supportedLocales: const [Locale('en', 'US')],
          child: const MyApp(),
        ),
      );
      await tester.idle();
      // The async delegator load will require build on the next frame. Thus, pump
      await tester.pump();

      expect(QuickLocalization.of(_context)!.supportedLocales, [
        const Locale('en', 'US'),
      ]);
      expect(QuickLocalization.of(_context)!.locale, const Locale('en', 'US'));

      final trFinder = find.text('test_en-US');
      expect(trFinder, findsOneWidget);
      final pluralFinder = find.text('1 day');
      expect(pluralFinder, findsOneWidget);
      expect(tr('test'), 'test_en-US');
    });
  });

  testWidgets('[QuickLocalization with  Default AssetLoader] test', (
    WidgetTester tester,
  ) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        QuickLocalization(
          path: '../../i18n',
          supportedLocales: const [Locale('en', 'US')],
          child: const MyApp(),
        ),
      );
      await tester.idle();
      // The async delegator load will require build on the next frame. Thus, pump
      await tester.pump();

      expect(QuickLocalization.of(_context)!.supportedLocales, [
        const Locale('en', 'US'),
      ]);
      expect(QuickLocalization.of(_context)!.locale, const Locale('en', 'US'));

      final trFinder = find.text('test_en-US');
      expect(trFinder, findsOneWidget);
      final pluralFinder = find.text('1 day');
      expect(pluralFinder, findsOneWidget);

      expect(tr('test'), 'test_en-US');
    });
  });
  testWidgets('[QuickLocalization with  Error path] test', (
    WidgetTester tester,
  ) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        QuickLocalization(
          path: 'i18',
          supportedLocales: const [Locale('en', 'US')],
          child: const MyApp(),
        ),
      );
      await tester.idle();
      // The async delegator load will require build on the next frame. Thus, pump
      await tester.pump();
      final trFinder = find.byWidgetPredicate(
        (widget) => widget is ErrorWidget,
      );
      expect(trFinder, findsOneWidget);
      await tester.pump();
    });
  });
  testWidgets('[QuickLocalization] change loacle test', (
    WidgetTester tester,
  ) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        QuickLocalization(
          path: '../../i18n',
          supportedLocales: const [Locale('en', 'US')],
          child: const MyApp(),
        ),
      );
      await tester.idle();
      // The async delegator load will require build on the next frame. Thus, pump
      await tester.pump();

      expect(QuickLocalization.of(_context)!.supportedLocales, [
        const Locale('en', 'US'),
      ]);
      expect(QuickLocalization.of(_context)!.locale, const Locale('en', 'US'));

      var l = const Locale('en', 'US');
      await QuickLocalization.of(_context)!.setLocale(l);
      await tester.pump();
      expect(QuickLocalization.of(_context)!.locale, const Locale('en', 'US'));

      final trFinder = find.text('test_en-US');
      expect(trFinder, findsOneWidget);
      final pluralFinder = find.text('1 day');
      expect(pluralFinder, findsOneWidget);

      expect(tr('test'), 'test_en-US');
      expect(QuickLocalization.of(_context)!.locale, const Locale('en', 'US'));

      l = const Locale('ar', 'DZ');
      expect(() async {
        await QuickLocalization.of(_context)!.setLocale(l);
      }, throwsAssertionError);
      await tester.pump();
      expect(QuickLocalization.of(_context)!.locale, const Locale('en', 'US'));
    });
  });

  testWidgets('[QuickLocalization] change locale test', (
    WidgetTester tester,
  ) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        QuickLocalization(
          path: '../../i18n',
          supportedLocales: const [Locale('en', 'US'), Locale('ar', 'DZ')],
          child: const MyApp(),
        ),
      );
      await tester.idle();
      // The async delegator load will require build on the next frame. Thus, pump
      await tester.pump();

      expect(Localization.of(_context), isInstanceOf<Localization>());
      expect(QuickLocalization.of(_context)!.supportedLocales, [
        const Locale('en', 'US'),
        const Locale('ar', 'DZ'),
      ]);
      expect(QuickLocalization.of(_context)!.locale, const Locale('en', 'US'));

      var trFinder = find.text('test_en-US');
      expect(trFinder, findsOneWidget);
      var pluralFinder = find.text('1 day');
      expect(pluralFinder, findsOneWidget);

      expect(tr('test'), 'test_en-US');

      var l = const Locale('en', 'US');
      await QuickLocalization.of(_context)!.setLocale(l);
      await tester.pump();
      expect(QuickLocalization.of(_context)!.locale, l);

      l = const Locale('ar', 'DZ');
      await QuickLocalization.of(_context)!.setLocale(l);
      await tester.idle();
      await tester.pump();
      expect(QuickLocalization.of(_context)!.locale, l);

      l = const Locale('en', 'US');
      await QuickLocalization.of(_context)!.setLocale(l);
      await tester.idle();
      await tester.pump();
      expect(QuickLocalization.of(_context)!.locale, l);

      l = const Locale('en', 'UK');
      expect(
        () async => {await QuickLocalization.of(_context)!.setLocale(l)},
        throwsAssertionError,
      );

      l = const Locale('ar', 'DZ');
      await QuickLocalization.of(_context)!.setLocale(l);
      await tester.idle();
      await tester.pump();
      expect(QuickLocalization.of(_context)!.locale, l);
    });
  });

  testWidgets('[QuickLocalization] loacle ar_DZ test', (
    WidgetTester tester,
  ) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        QuickLocalization(
          path: '../../i18n',
          supportedLocales: const [Locale('en', 'US'), Locale('ar', 'DZ')],
          ignorePluralRules: false,
          child: const MyApp(),
        ),
      );

      await tester.idle();
      // The async delegator load will require build on the next frame. Thus, pump
      await tester.pump();

      await QuickLocalization.of(_context)!.setLocale(const Locale('ar', 'DZ'));

      await tester.pump();

      expect(QuickLocalization.of(_context)!.supportedLocales, [
        const Locale('en', 'US'),
        const Locale('ar', 'DZ'),
      ]);
      expect(QuickLocalization.of(_context)!.locale, const Locale('ar', 'DZ'));

      var trFinder = find.text('اختبار');
      expect(trFinder, findsOneWidget);
      var pluralFinder = find.text('1 يوم');
      expect(pluralFinder, findsOneWidget);

      expect(Localization.of(_context), isInstanceOf<Localization>());
      expect(tr('test'), 'اختبار');
      expect(plural('day', 1), '1 يوم');
      expect(plural('day', 2), '2 أيام');
      expect(plural('day', 3), '3 أيام');

      // var l = Locale('en', 'US');
      // QuickLocalization.of(_context).locale = l;
      // expect(QuickLocalization.of(_context).locale, l);
    });
  });

  testWidgets(
    '[QuickLocalization] fallbackLocale with doesn\'t saveLocale test',
    (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          QuickLocalization(
            path: '../../i18n',
            saveLocale: false,
            useOnlyLangCode: true,
            supportedLocales: const [Locale('en'), Locale('ar')],
            child: const MyApp(), // Locale('en', 'US'), Locale('ar','DZ')
          ),
        );
        await tester.idle();
        // The async delegator load will require build on the next frame. Thus, pump
        await tester.pump();

        expect(QuickLocalization.of(_context)!.supportedLocales, [
          const Locale('en'),
          const Locale('ar'),
        ]);
        expect(QuickLocalization.of(_context)!.locale, const Locale('en'));

        var l = const Locale('en');
        await QuickLocalization.of(_context)!.setLocale(l);
        expect(QuickLocalization.of(_context)!.locale, l);
      });
    },
  );

  testWidgets(
    '[QuickLocalization] fallbackLocale=null with doesn\'t saveLocale test',
    (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          QuickLocalization(
            path: '../../i18n',
            saveLocale: false,
            useOnlyLangCode: true,
            supportedLocales: const [Locale('en'), Locale('ar')],
            child: const MyApp(), // Locale('en', 'US'), Locale('ar','DZ')
          ),
        );
        await tester.idle();
        // The async delegator load will require build on the next frame. Thus, pump
        await tester.pump();

        expect(QuickLocalization.of(_context)!.supportedLocales, [
          const Locale('en'),
          const Locale('ar'),
        ]);
        expect(QuickLocalization.of(_context)!.locale, const Locale('en'));

        var l = const Locale('en');
        await QuickLocalization.of(_context)!.setLocale(l);
        expect(QuickLocalization.of(_context)!.locale, l);
      });
    },
  );

  testWidgets(
    '[QuickLocalization] _getFallbackLocale() fallbackLocale!=null test',
    (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          QuickLocalization(
            path: '../../i18n',
            saveLocale: false,
            useOnlyLangCode: true,
            supportedLocales: const [Locale('ar')],
            fallbackLocale: const Locale('ar'),
            child: const MyApp(),
          ),
        );
        await tester.idle();
        // The async delegator load will require build on the next frame. Thus, pump
        await tester.pump();

        expect(QuickLocalization.of(_context)!.supportedLocales, [
          const Locale('ar'),
        ]);
        expect(QuickLocalization.of(_context)!.locale, const Locale('ar'));
        expect(
          QuickLocalization.of(_context)!.fallbackLocale,
          const Locale('ar'),
        );
      });
    },
  );

  testWidgets(
    '[QuickLocalization] _getFallbackLocale()  fallbackLocale==null test',
    (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          QuickLocalization(
            path: '../../i18n',
            saveLocale: false,
            useOnlyLangCode: true,
            // fallbackLocale:Locale('en') ,
            supportedLocales: const [Locale('ar')],
            child: const MyApp(), // Locale('en', 'US'), Locale('ar','DZ')
          ),
        );
        await tester.idle();
        // The async delegator load will require build on the next frame. Thus, pump
        await tester.pump();

        expect(QuickLocalization.of(_context)!.supportedLocales, [
          const Locale('ar'),
        ]);
        expect(QuickLocalization.of(_context)!.locale, const Locale('ar'));
        expect(QuickLocalization.of(_context)!.fallbackLocale, null);
      });
    },
  );

  group('SharedPreferences SavedLocale NULL', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({'locale': ''});
    });

    testWidgets(
      '[QuickLocalization] SavedLocale()  null locale without country code',
      (WidgetTester tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(
            QuickLocalization(
              path: '../../i18n',
              // fallbackLocale:Locale('en') ,
              supportedLocales: const [Locale('en'), Locale('ar')],
              child: const MyApp(), //
            ),
          );
          await tester.idle();
          await tester.pump(const Duration(seconds: 2));
          // The async delegator load will require build on the next frame. Thus, pump
          await tester.pump();

          expect(QuickLocalization.of(_context)!.supportedLocales, [
            const Locale('en'),
            const Locale('ar'),
          ]);
          expect(QuickLocalization.of(_context)!.locale, const Locale('en'));
          expect(QuickLocalization.of(_context)!.fallbackLocale, null);
        });
      },
    );
    testWidgets('[QuickLocalization] SavedLocale()  test', (
      WidgetTester tester,
    ) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          QuickLocalization(
            path: '../../i18n',
            // fallbackLocale:Locale('en') ,
            supportedLocales: const [Locale('en', 'US'), Locale('ar', 'DZ')],
            child: const MyApp(), //
          ),
        );
        await tester.idle();
        await tester.pump(const Duration(seconds: 2));
        // The async delegator load will require build on the next frame. Thus, pump
        await tester.pump();

        expect(QuickLocalization.of(_context)!.supportedLocales, [
          const Locale('en', 'US'),
          const Locale('ar', 'DZ'),
        ]);
        expect(
          QuickLocalization.of(_context)!.locale,
          const Locale('en', 'US'),
        );
        expect(QuickLocalization.of(_context)!.fallbackLocale, null);
      });
    });
    testWidgets('[QuickLocalization] startLocale  test', (
      WidgetTester tester,
    ) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          QuickLocalization(
            path: '../../i18n',
            startLocale: const Locale('ar', 'DZ'),
            // fallbackLocale:Locale('en') ,
            supportedLocales: const [Locale('en', 'US'), Locale('ar', 'DZ')],
            child: const MyApp(), //
          ),
        );
        await tester.idle();
        await tester.pump(const Duration(seconds: 2));
        // The async delegator load will require build on the next frame. Thus, pump
        await tester.pump();

        expect(QuickLocalization.of(_context)!.supportedLocales, [
          const Locale('en', 'US'),
          const Locale('ar', 'DZ'),
        ]);
        expect(
          QuickLocalization.of(_context)!.locale,
          const Locale('ar', 'DZ'),
        );
        expect(QuickLocalization.of(_context)!.fallbackLocale, null);
      });
    });
  });

  group('SharedPreferences saveLocale', () {
    setUpAll(() async {
      SharedPreferences.setMockInitialValues({'locale': 'ar'});
      await QuickLocalization.ensureInitialized();
    });

    testWidgets('[QuickLocalization] useOnlyLangCode true test', (
      WidgetTester tester,
    ) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          QuickLocalization(
            path: '../../i18n',
            saveLocale: true,
            // fallbackLocale:Locale('en') ,
            useOnlyLangCode: true,
            supportedLocales: const [Locale('en'), Locale('ar')],
            child: const MyApp(), // Locale('en', 'US'), Locale('ar','DZ')
          ),
        );
        await tester.idle();
        // The async delegator load will require build on the next frame. Thus, pump
        await tester.pump();

        expect(QuickLocalization.of(_context)!.supportedLocales, [
          const Locale('en'),
          const Locale('ar'),
        ]);
        expect(QuickLocalization.of(_context)!.locale, const Locale('ar'));
        expect(QuickLocalization.of(_context)!.fallbackLocale, null);
      });
    });
  });

  group('SharedPreferences saveLocale', () {
    setUpAll(() async {
      SharedPreferences.setMockInitialValues({'locale': 'ar_DZ'});
      await QuickLocalization.ensureInitialized();
    });

    testWidgets('[QuickLocalization] saveLocale true  test', (
      WidgetTester tester,
    ) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          QuickLocalization(
            path: '../../i18n',
            saveLocale: true,
            // fallbackLocale:Locale('en') ,
            supportedLocales: const [Locale('en', 'US'), Locale('ar', 'DZ')],
            child: const MyApp(), // Locale('en', 'US'), Locale('ar','DZ')
          ),
        );
        await tester.idle();
        // The async delegator load will require build on the next frame. Thus, pump
        await tester.pump();

        expect(QuickLocalization.of(_context)!.supportedLocales, [
          const Locale('en', 'US'),
          const Locale('ar', 'DZ'),
        ]);
        expect(
          QuickLocalization.of(_context)!.locale,
          const Locale('ar', 'DZ'),
        );
        expect(QuickLocalization.of(_context)!.fallbackLocale, null);
      });
    });

    testWidgets('[QuickLocalization] saveLocale false test', (
      WidgetTester tester,
    ) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          QuickLocalization(
            path: '../../i18n',
            saveLocale: false,
            // fallbackLocale:Locale('en') ,
            supportedLocales: const [Locale('en', 'US'), Locale('ar', 'DZ')],
            child: const MyApp(), // Locale('en', 'US'), Locale('ar','DZ')
          ),
        );
        await tester.idle();
        // The async delegator load will require build on the next frame. Thus, pump
        await tester.pump();

        expect(QuickLocalization.of(_context)!.supportedLocales, [
          const Locale('en', 'US'),
          const Locale('ar', 'DZ'),
        ]);
        expect(
          QuickLocalization.of(_context)!.locale,
          const Locale('en', 'US'),
        );

        await QuickLocalization.of(_context)!
            .setLocale(const Locale('en', 'US'));
      });
    });
  });
  group('SharedPreferences deleteSaveLocale()', () {
    setUpAll(() async {
      SharedPreferences.setMockInitialValues({'locale': 'ar_DZ'});
      await QuickLocalization.ensureInitialized();
    });
    testWidgets('[QuickLocalization] deleteSaveLocale  test', (
      WidgetTester tester,
    ) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          QuickLocalization(
            path: '../../i18n',
            // fallbackLocale:Locale('en') ,
            supportedLocales: const [Locale('en', 'US'), Locale('ar', 'DZ')],
            child: const MyApp(), // Locale('en', 'US'), Locale('ar','DZ')
          ),
        );
        await tester.idle();
        // The async delegator load will require build on the next frame. Thus, pump
        await tester.pump();

        expect(
          QuickLocalization.of(_context)!.locale,
          const Locale('ar', 'DZ'),
        );
        await QuickLocalization.of(_context)!.deleteSaveLocale();
      });
    });

    testWidgets('[QuickLocalization] after deleteSaveLocale test', (
      WidgetTester tester,
    ) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          QuickLocalization(
            path: '../../i18n',
            // fallbackLocale:Locale('en') ,
            supportedLocales: const [Locale('en', 'US'), Locale('ar', 'DZ')],
            child: const MyApp(), // Locale('en', 'US'), Locale('ar','DZ')
          ),
        );
        await tester.idle();
        // The async delegator load will require build on the next frame. Thus, pump
        await tester.pump();

        expect(
          QuickLocalization.of(_context)!.locale,
          const Locale('en', 'US'),
        );
      });
    });

    testWidgets('[QuickLocalization] device locale  test', (
      WidgetTester tester,
    ) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          QuickLocalization(
            path: '../../i18n',
            supportedLocales: const [Locale('en', 'US'), Locale('ar', 'DZ')],
            child: const MyApp(), // Locale('en', 'US'), Locale('ar','DZ')
          ),
        );
        await tester.idle();
        // The async delegator load will require build on the next frame. Thus, pump
        await tester.pump();

        expect(
          QuickLocalization.of(_context)!.deviceLocale.toString(),
          Platform.localeName,
        );
      });
    });

    testWidgets('[QuickLocalization] reset device locale  test', (
      WidgetTester tester,
    ) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          QuickLocalization(
            path: '../../i18n',
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('ar', 'DZ'),
            ], // Locale('en', 'US'), Locale('ar','DZ')
            startLocale: const Locale('ar', 'DZ'),
            child: const MyApp(),
          ),
        );
        await tester.idle();
        // The async delegator load will require build on the next frame. Thus, pump
        await tester.pump();

        expect(
          QuickLocalization.of(_context)!.locale,
          const Locale('ar', 'DZ'),
        );
        // reset to device locale
        await _context.resetLocale();
        await tester.pump();
        expect(
          QuickLocalization.of(_context)!.locale,
          const Locale('en', 'US'),
        );
      });
    });

    testWidgets('[QuickLocalization] device locale  test', (
      WidgetTester tester,
    ) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          QuickLocalization(
            path: '../../i18n',
            supportedLocales: const [Locale('en', 'US'), Locale('ar', 'DZ')],
            child: const MyApp(), // Locale('en', 'US'), Locale('ar','DZ')
          ),
        );
        await tester.idle();
        // The async delegator load will require build on the next frame. Thus, pump
        await tester.pumpAndSettle();

        expect(
          QuickLocalization.of(_context)!.deviceLocale.toString(),
          Platform.localeName,
        );
      });
    });

    testWidgets('[QuickLocalization] reset device locale  test', (
      WidgetTester tester,
    ) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          QuickLocalization(
            path: '../../i18n',
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('ar', 'DZ'),
            ], // Locale('en', 'US'), Locale('ar','DZ')
            startLocale: const Locale('ar', 'DZ'),
            child: const MyApp(),
          ),
        );
        await tester.idle();
        // The async delegator load will require build on the next frame. Thus, pump
        await tester.pumpAndSettle();

        expect(
          QuickLocalization.of(_context)!.locale,
          const Locale('ar', 'DZ'),
        );
        // reset to device locale
        await _context.resetLocale();
        await tester.pumpAndSettle();
        expect(
          QuickLocalization.of(_context)!.locale,
          const Locale('en', 'US'),
        );
      });
    });
  });

  group('Context extensions tests', () {
    final testWidget = QuickLocalization(
      path: '../../i18n',
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ar', 'DZ'),
      ], // Locale('en', 'US'), Locale('ar','DZ')
      startLocale: const Locale('en', 'US'),
      child: const MyApp(child: MyLocalizedWidget()),
    );

    testWidgets(
      '[QuickLocalization] Throws LocalizationNotFoundException without QuickLocalization widget',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MyLocalizedWidget());
        final exception = tester.takeException();

        expect(exception, isA<LocalizationNotFoundException>());
      },
    );

    testWidgets(
      '[QuickLocalization] context.translate and context.plural text widgets are in the tree',
      (WidgetTester tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(testWidget);

          await tester.idle();
          // The async delegator load will require build on the next frame. Thus, pump
          await tester.pumpAndSettle();

          expect(find.text(_contextTranslationValue), findsOneWidget);
          expect(find.text(_contextPluralValue), findsOneWidget);
        });
      },
    );

    testWidgets(
      '[QuickLocalization] context.translate and context.plural provide relevant texts',
      (WidgetTester tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(testWidget);

          const expectedEnTranslateTextWidgetValue = 'test_en-US';
          const expectedArTranslateTextWidgetValue = 'اختبار';
          const expectedEnPluralTextWidgetValue = '1 day';
          const expectedArPluralTextWidgetValue = '1 يوم';
          const arabyLocale = Locale('ar', 'DZ');

          await tester.idle();
          // The async delegator load will require build on the next frame. Thus, pump

          await tester.pumpAndSettle();
          final initialTranslationValue = _contextTranslationValue;
          final initialPluralValue = _contextPluralValue;

          expect(
            initialTranslationValue == expectedEnTranslateTextWidgetValue,
            true,
          );
          expect(initialPluralValue == expectedEnPluralTextWidgetValue, true);

          QuickLocalization.of(_context)?.setLocale(arabyLocale);

          await tester.pumpAndSettle();

          expect(
            initialTranslationValue != _contextTranslationValue &&
                _contextTranslationValue == expectedArTranslateTextWidgetValue,
            true,
          );
          expect(
            initialPluralValue != _contextPluralValue &&
                _contextPluralValue == expectedArPluralTextWidgetValue,
            true,
          );
        });
      },
    );
  });
}
