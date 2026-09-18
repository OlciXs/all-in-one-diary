import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'services/secure_storage_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Sprawdzamy token przed uruchomieniem aplikacji
  final storage = SecureStorageService();
  final initialToken = await storage.getToken();

  runApp(MyApp(initialToken: initialToken));
}

class MyApp extends StatelessWidget {
  final String? initialToken;
  const MyApp({super.key, this.initialToken});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Diary App',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          useMaterial3: true,
        ),
        // Jeśli token istnieje, od razu wchodzimy na HomeScreen, w przeciwnym razie LoginScreen
        home: initialToken != null ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }
}