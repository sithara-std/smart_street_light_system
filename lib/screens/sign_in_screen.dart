import 'package:flutter/material.dart';
import 'package:smart_street_light/theme_and_store.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isBusy = false;
  String _err = '';

  void _submit() async {
    setState(() { _err = ''; });
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() { _err = 'Please fill in all fields.'; });
      return;
    }
    setState(() { _isBusy = true; });
    
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on AuthException catch (e) {
      setState(() { _err = e.message; });
    } catch (e) {
      setState(() { _err = 'An unexpected error occurred.'; });
    } finally {
      if (mounted) setState(() { _isBusy = false; });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    const StreetLightIcon(size: 56, on: true),
                    const SizedBox(height: 16),
                    const Text(
                      'LUMEN',
                      style: TextStyle(color: AppColors.text, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 6),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Sign in to monitor your smart site',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 36),
                const Text('Email', style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: AppColors.text),
                  decoration: InputDecoration(
                    hintText: 'you@site.com',
                    hintStyle: const TextStyle(color: AppColors.textDim),
                    fillColor: AppColors.inputBg,
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.inputBorder)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Password', style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  style: const TextStyle(color: AppColors.text),
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    hintStyle: const TextStyle(color: AppColors.textDim),
                    fillColor: AppColors.inputBg,
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.inputBorder)),
                  ),
                ),
                if (_err.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(_err, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isBusy ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isBusy 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Color(0xFF0B1120), strokeWidth: 2))
                      : const Text('Sign In', style: TextStyle(color: Color(0xFF0B1120), fontSize: 16, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, '/signup'), // onTap 
                  child: const Center(
                    child: Text.rich(
                      TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                        children: [
                          TextSpan(text: 'Sign up', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}