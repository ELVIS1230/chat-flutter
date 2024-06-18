import 'package:chatflutter/auth_provider.dart';
import 'package:chatflutter/home_screen.dart';
import 'package:chatflutter/singup_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text("Login"),
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      labelText: 'Email', border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Ingresar un correo";
                    }
                    return null;
                  }),
              SizedBox(height: 16),
              TextFormField(
                  controller: _passController,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                      labelText: 'Contraseña', border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Ingresar la contraseña";
                    }
                    return null;
                  }),
              SizedBox(height: 50),
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.5,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await authProvider.singnin(
                          _emailController.text, _passController.text);
                      Fluttertoast.showToast(msg: "Inicio exitoso");

                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomeScreen()));
                    } catch (e) {
                      print(e);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3876FD),
                      foregroundColor: Colors.white),
                  child: Text(
                    "Iniciar Sesion",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text("O"),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => SingUpScreen()));
                },
                child: Text("Crear cuenta",
                    style: TextStyle(
                        color: Color(0xFF3876FD),
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              )
            ],
          ),
        ));
  }
}
