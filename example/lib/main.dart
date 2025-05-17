import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';

import 'package:talker_flutter/talker_flutter.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger.dart';
import 'package:twa/twa.dart';

final talker = TalkerFlutter.init();

Future<void> main() async {
  runTalkerZonedGuarded(
    talker,
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      try {
        if (Twa.instance.isSupported) {
          Twa.instance.ready();
        }
      } catch (e) {
        print("Error happened in Flutter while loading Telegram $e");
        // add delay for 'Telegram not loading sometimes' bug
        await Future.delayed(const Duration(milliseconds: 200));
        main();
        return;
      }

      usePathUrlStrategy();

      runApp(
        ProviderScope(
          observers: [
            TalkerRiverpodObserver(
              talker: talker,
              settings: TalkerRiverpodLoggerSettings(
                printProviderDisposed: true,
              ),
            ),
          ],
          child: TelegramMediaQueryProvider(child: const AppWidget()),
        ),
      );
    },
    (e, s) {
      // TODO: add sentry here
    },
  );
}

class TelegramMediaQueryProvider extends StatelessWidget {
  const TelegramMediaQueryProvider({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final safeAreaInset = Twa.instance.safeAreaInset;
    final contentSafeAreaInset = Twa.instance.contentSafeAreaInset;
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        viewInsets: EdgeInsets.only(
          left: safeAreaInset.left,
          top: safeAreaInset.top,
          right: safeAreaInset.right,
          bottom: safeAreaInset.bottom,
        ),
        viewPadding: EdgeInsets.only(
          left: contentSafeAreaInset.left,
          top: contentSafeAreaInset.top,
          right: contentSafeAreaInset.right,
          bottom: contentSafeAreaInset.bottom,
        ),
      ),
      child: child,
    );
  }
}

final routerProvider = Provider.autoDispose<GoRouter>((ref) {
  return GoRouter(
    initialLocation: "/",
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: '/modal',
        pageBuilder:
            (context, state) => CupertinoSheetPage(child: ModalScreen()),
      ),
    ],
  );
});

class CupertinoSheetPage<T> extends Page<T> {
  final Widget child;
  const CupertinoSheetPage({super.key, required this.child});

  @override
  Route<T> createRoute(BuildContext context) {
    return CupertinoSheetRoute<T>(settings: this, builder: (context) => child);
  }
}

class AppWidget extends ConsumerWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      routerConfig: ref.watch(routerProvider),
      builder:
          (context, child) => Padding(
            padding: EdgeInsets.only(top: MediaQuery.viewInsetsOf(context).top),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Column(
                children: [
                  Container(
                    height: MediaQuery.viewPaddingOf(context).top,
                    color: Colors.amber,
                    alignment: Alignment.center,
                    width: double.infinity,
                    child: Text(
                      "Your Logo",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(child: child ?? SizedBox()),
                ],
              ),
            ),
          ),
    );
  }
}

class ModalScreen extends StatelessWidget {
  const ModalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      showDragHandle: true,
      enableDrag: true,
      onClosing: () {},
      builder:
          (context) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Modal Screen"),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: const Text("Close"),
                ),
              ],
            ),
          ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plugin example app')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text('isSupported: ${Twa.instance.isSupported}\n'),
            Text("platform: ${Twa.instance.platform}"),
            Text("initData: ${Twa.instance.initData}"),
            Text("initDataUnsafe: ${Twa.instance.initDataUnsafe}"),

            ExpansionTile(
              title: const Text("LocationManager"),
              children: [
                Text("isInited: ${Twa.instance.locationManager.isInited}"),
                Text(
                  "isLocationAvailable: ${Twa.instance.locationManager.isLocationAvailable}",
                ),
                Text(
                  "isAccessRequested: ${Twa.instance.locationManager.isAccessRequested}",
                ),
                Text(
                  "isAccessGranted: ${Twa.instance.locationManager.isAccessGranted}",
                ),
                FilledButton(
                  onPressed: () async {
                    final _ = await Twa.instance.locationManager.init();
                    print(
                      "init location manager result: ${Twa.instance.locationManager}",
                    );
                  },
                  child: const Text("Init LocationManager"),
                ),
                FilledButton(
                  onPressed: () async {
                    try {
                      final result =
                          await Twa.instance.locationManager.getLocation();
                      print("get location result: $result");
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: const Text("Get Location"),
                ),

                FilledButton(
                  onPressed: () {
                    Twa.instance.locationManager.openSettings();
                  },
                  child: const Text("Open Settings"),
                ),
              ],
            ),
            ListTile(
              title: const Text("requestContact"),
              subtitle: const Text("Request contact access"),
              trailing: FilledButton(
                onPressed: () async {
                  final result = await Twa.instance.requestContact();
                  print("request contact result: ${result.response?.contact}");
                },
                child: Text("Request"),
              ),
            ),
            ListTile(
              title: const Text("requestFullscreen"),
              subtitle: const Text("request fullscreen mode"),
              trailing: FilledButton(
                onPressed: () async {
                  final _ = Twa.instance.requestFullscreen();
                  print("request fullscreen result: ");
                },
                child: Text("Request"),
              ),
            ),
            ListTile(
              title: const Text("disableVerticalSwipes"),
              subtitle: const Text("for disable vertical swipes"),
              trailing: FilledButton(
                onPressed: () async {
                  final _ = Twa.instance.disableVerticalSwipes();
                  print("request fullscreen result: ");
                },
                child: Text("disable"),
              ),
            ),
            Row(
              children: [
                FloatingActionButton(
                  onPressed: () async {
                    final result = await Twa.instance.requestContact();

                    print("result: $result");
                  },
                  tooltip: 'Request Contact',
                  child: const Icon(Icons.add),
                ),

                IconButton(
                  onPressed: () async {
                    final result = await Twa.instance.requestWriteAccess();

                    print("result: $result");
                  },
                  tooltip: 'Request Write Access',
                  icon: const Icon(Icons.add),
                ),
                Builder(
                  builder: (context) {
                    return IconButton(
                      onPressed: () async {
                        context.push('/modal');
                      },
                      tooltip: 'Request Fullscreen',
                      icon: const Icon(Icons.open_in_browser),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
