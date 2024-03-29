import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http/browser_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  String _email = "";
  String _password = "";

  bool _isLoading = false;

  String _errorMessage = "";

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    print(_email);
    print(_password);
    final client = BrowserClient();
    final response = await client.post(
      Uri.parse('https://askme-service.onrender.com/auth/authenticate'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': _email, 'password': _password}),
    );

    print("----------------------------------");
    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

    // Save user data to local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userToken', data['token']);
    await prefs.setString('userEmail', data['email']);
      await prefs.setString('userName', data['userName']);
      await prefs.setString('id', data['id'].toString());

    // Navigate to main app screen
    Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = "error in email or password";
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                onSaved: (value) {
                  _password = value!;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text('Login'),
                onPressed: _isLoading
                    ? null
                    : () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _login();
                  }
                },
              ),
              if (_errorMessage != "")
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              SizedBox(height: 16.0),
              TextButton(
                child: Text('Create an account'),
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}