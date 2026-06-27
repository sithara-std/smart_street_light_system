import 'package:flutter/material.dart';
import 'package:smart_street_light/theme_and_store.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _siteController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isBusy = false;
  String _err = '';

  void _submit() async {
    setState(() { _err = ''; });
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _siteController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() { _err = 'Please complete all fields.'; });
      return;
    }
    if (_passwordController.text.length < 6) {
      setState(() { _err = 'Password must be at least 6 characters.'; });
      return;
    }

    setState(() { _isBusy = true; });

    try {
      await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {
          'full_name': _nameController.text.trim(),
          'site': _siteController.text.trim(),
        },
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
    _nameController.dispose();
    _emailController.dispose();
    _siteController.dispose();
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    const StreetLightIcon(size: 48, on: true),
                    const SizedBox(height: 16),
                    const Text('Create Account', style: TextStyle(color: AppColors.text, fontSize: 24, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    const Text('Register your smart streetlight site', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 28),
                _buildInputField('Full Name', _nameController, 'Jane Operator'),
                _buildInputField('Email', _emailController, 'you@site.com'),
                _buildInputField('Site / Sector', _siteController, 'Downtown Sector 7'),
                _buildInputField('Password', _passwordController, 'At least 6 characters', obscure: true),
                if (_err.isNotEmpty) ...[
                  Text(_err, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                  const SizedBox(height: 12),
                ],
                ElevatedButton(
                  onPressed: _isBusy ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isBusy 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Color(0xFF0B1120), strokeWidth: 2))
                      : const Text('Create Account', style: TextStyle(color: Color(0xFF0B1120), fontSize: 16, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 22),
                GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, '/signin'), 
                  child: const Center(
                    child: Text.rich(
                      TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                        children: [
                          TextSpan(text: 'Sign in', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
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

  Widget _buildInputField(String label, TextEditingController controller, String hint, {bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(color: AppColors.text),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textDim),
            fillColor: AppColors.inputBg,
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.inputBorder)),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}