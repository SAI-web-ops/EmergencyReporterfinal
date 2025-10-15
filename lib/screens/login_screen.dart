import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/auth_repository.dart';
import '../providers/app_state_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isSignup = false;
  bool _loading = false;
  String _role = 'citizen';

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isSignup ? 'Create account' : 'Sign in')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordCtrl,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (v) =>
                        (v == null || v.length < 6) ? 'Min 6 chars' : null,
                  ),
                  if (_isSignup) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _role,
                      items: const [
                        DropdownMenuItem(
                          value: 'citizen',
                          child: Text('Citizen'),
                        ),
                        DropdownMenuItem(
                          value: 'dispatcher',
                          child: Text('Dispatcher'),
                        ),
                        DropdownMenuItem(
                          value: 'responder',
                          child: Text('Responder'),
                        ),
                      ],
                      onChanged: (v) => setState(() {
                        _role = v ?? 'citizen';
                      }),
                      decoration: const InputDecoration(labelText: 'Role'),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(_isSignup ? 'Sign up' : 'Sign in'),
                    ),
                  ),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () => setState(() {
                            _isSignup = !_isSignup;
                          }),
                    child: Text(
                      _isSignup
                          ? 'Have an account? Sign in'
                          : 'Create an account',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
    });
    try {
      final repo = context.read<AuthRepository>();
      final app = context.read<AppStateProvider>();
      final email = _emailCtrl.text.trim();
      final password = _passwordCtrl.text;
      Map<String, dynamic> data;
      if (_isSignup) {
        data = await repo.signup(email, password, role: _role);
      } else {
        data = await repo.login(email, password);
      }
      final access = data['accessToken'] as String;
      final refresh = data['refreshToken'] as String;
      final user = data['user'] as Map<String, dynamic>;
      await repo.saveTokens(access, refresh);
      app.setAuth(
        accessToken: access,
        refreshToken: refresh,
        role: user['role'] as String?,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Auth failed: $e')));
      }
    } finally {
      if (mounted)
        setState(() {
          _loading = false;
        });
    }
  }
}
