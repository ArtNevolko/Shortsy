import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../shared/widgets/index.dart';

class SignInScreen extends StatefulWidget {
  final VoidCallback onSignedIn;
  const SignInScreen({super.key, required this.onSignedIn});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _c = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await AuthService().signIn(_c.text);
    widget.onSignedIn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const GlassHeader(title: 'Вход'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Glass(
                        borderRadius: BorderRadius.circular(18),
                        padding: const EdgeInsets.all(12),
                        child: TextFormField(
                          controller: _c,
                          decoration:
                              const InputDecoration(labelText: 'Никнейм'),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Введите ник'
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: AppButton.primary(
                          label: 'Войти',
                          icon: Icons.login_rounded,
                          onPressed: _submit,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
