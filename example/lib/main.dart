import 'package:auth_management/models/base_user.dart';
import 'package:auth_management/services/base_auth_service.dart';
import 'package:example/models/example_user.dart';
import 'package:example/router.dart';
import 'package:example/screens/second_hand.dart';
import 'package:example/screens/without_signin.dart';
import 'package:example/services/auth_route_service.dart';
import 'package:example/services/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await BaseAuthService.initialize(ExampleUserSchema, authService);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    authService.linkAuthWithProvider(ref);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: authRouteService.routerConfig(ref),
    );

    // return MaterialApp(
    //     title: 'Flutter Demo',
    //     theme: ThemeData(
    //       // This is the theme of your application.
    //       //
    //       // Try running your application with "flutter run". You'll see the
    //       // application has a blue toolbar. Then, without quitting the app, try
    //       // changing the primarySwatch below to Colors.green and then invoke
    //       // "hot reload" (press "r" in the console where you ran "flutter run",
    //       // or simply save your changes to "hot reload" in a Flutter IDE).
    //       // Notice that the counter didn't reset back to zero; the application
    //       // is not restarted.
    //       primarySwatch: Colors.blue,
    //     ),
    //     home: AuthScreenHandler<ExampleUser>(
    //       authService: authService,
    //       authScreen: const MyHomePage(
    //         title: 'auth screen',
    //       ),
    //       afterAuthScreen: Consumer(builder: (context, ref, _) {
    //         return MyHomePage(
    //           title: ref.watch(userProvider)?.username ?? " Tidak direkod",
    //         );
    //       }),
    //     ));
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  void initState() {
    ref.read(userNotifierProvider);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          children: [
            TextButton(
              onPressed: authService.firebaseAuth.signInAnonymously,
              child: const Text("Sign In"),
            ),
            TextButton(
              onPressed: () {
                SecondRoute().go(context);
              },
              child: const Text("second screen"),
            ),
            TextButton(
              onPressed: () {
                WithoutSignInRoute().go(context);
              },
              child: const Text("new screen"),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: authService.signOut,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
