import 'package:flutter/material.dart';

import '../../servicios/auth_services.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool _obscurePassword = true; // Controla la visibilidad de la contraseña

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
    });

    bool success = await AuthService().register(
      nameController.text.trim(),
      emailController.text.trim(),
      passwordController.text,
    );

    if (mounted) {
      setState(() {
        loading = false;
      });
    }

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Un Insanito se registro con éxito!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Regresa de forma limpia al LoginScreen
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al registrar. Inténtalo de nuevo o no quieres ser un Insanito'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDarkMode ? Colors.white : const Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),

                // ÍCONO SUPERIOR PREMIUM
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_add_alt_1_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // TEXTOS DE ENCABEZADO
                Center(
                  child: Text(
                    'Crear una Cuenta Insana',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Únete para ayudar a tu ciudad y ser un verdadero Insanito',
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                    textAlign: TextAlign.center, // Soporta alineación opcional o estilo por defecto
                  ),
                ),

                const SizedBox(height: 40),

                // INPUT: NOMBRE
                TextFormField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Nombre Completo',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    filled: true,
                    fillColor: surfaceColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es obligatorio';
                    }
                    if (value.trim().length < 3) {
                      return 'Ingresa un nombre válido';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // INPUT: EMAIL
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Correo Electrónico',
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: surfaceColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El correo es obligatorio';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                      return 'Ingresa un correo electrónico válido';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // INPUT: PASSWORD
                TextFormField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    filled: true,
                    fillColor: surfaceColor,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La contraseña es obligatoria';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 36),

                // BOTÓN DE REGISTRO PREMIUM
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: loading ? null : register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Registrarse',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}