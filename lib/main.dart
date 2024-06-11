import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // setLoginState(false);
  runApp(const MyApp());
}

// Assuming these methods are defined elsewhere in your project
Future<void> setLoginState(bool loggedIn) async {
  print("Setting login state to ${loggedIn}");
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool("login", loggedIn);
}

Future<void> setLoginName(String name) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString("loginName", name);
}

Future<bool?> getLoggedInStatus() async {
  final prefs = await SharedPreferences.getInstance();
  print("Getting Login ${prefs.getBool("login")}");
  return prefs.getBool("login");
}

Future<String?> getUserName() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("loginName");
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FutureBuilder<bool?>(
        future: getLoggedInStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data == true) {
              return const LoggedInView();
            } else {
              return const LoggedOutView();
            }
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

class LoggedInView extends StatelessWidget {
  const LoggedInView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logged In')),
      body: FutureBuilder<String?>(
          future: getUserName(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Text(
                "Welcome to the app, ${snapshot.data}",
                style: DefaultTextStyle.of(context)
                    .style
                    .apply(fontSizeFactor: 2.0),
              );
            } else {
              return const CircularProgressIndicator();
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setLoginState(false).then((_) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoggedOutView()));
          });
        },
        child: const Icon(Icons.logout),
      ),
    );
  }
}

class LoggedOutView extends StatelessWidget {
  const LoggedOutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logged Out')),
      body: const Center(child: Text('Please log in.')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginScreen()));
        },
        child: const Icon(Icons.login),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Login Form')),
        body: Column(
          children: [
            const Text("Input Name"),
            TextField(
              controller: _controller,
              onSubmitted: (String value) async {
                setLoginName(value);
                setLoginState(true);
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const LoggedInView()));
              },
            ),
          ],
        ));
  }
}
