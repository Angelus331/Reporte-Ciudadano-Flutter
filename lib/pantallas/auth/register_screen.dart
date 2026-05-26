import 'package:flutter/material.dart';

import '../../servicios/auth_services.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {

  final nameController = TextEditingController();

  final emailController = TextEditingController();

  final passwordController =
      TextEditingController();

  bool loading = false;

  Future<void> register() async {

    setState(() {
      loading = true;
    });

    bool success =
        await AuthService().register(

      nameController.text,
      emailController.text,
      passwordController.text,
    );

    setState(() {
      loading = false;
    });

    if (success) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario registrado'),
        ),
      );

      Navigator.pop(context);

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al registrar'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Registro'),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(

              onPressed:
                  loading ? null : register,

              child: loading
                  ? const CircularProgressIndicator()
                  : const Text('Registrarse'),
            )
          ],
        ),
      ),
    );
  }
}