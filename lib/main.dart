import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'redux/app_state.dart';
import 'redux/reducers.dart';
import 'screens/main_tab_screen.dart';
import 'package:redux/redux.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final store = Store<AppState>(
    appReducer,
    initialState: AppState.initial(),
  );

  runApp(MyApp(store));
}

class MyApp extends StatelessWidget {
  final Store<AppState> store;

  const MyApp(this.store, {super.key});

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'English Words App',
        theme: ThemeData(primarySwatch: Colors.indigo),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
              if (snapshot.hasData) {
                return const MainTabScreen();
              } else {
              return const LoginScreen(); 
            }
          },
        ),
      ),
    );
  }
}

