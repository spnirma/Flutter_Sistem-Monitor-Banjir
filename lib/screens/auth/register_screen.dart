import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String _role = 'masyarakat';
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).register(
            name: _nameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
            role: _role,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil! Silakan login.'),
          backgroundColor: Color(0xFF1a7a4a),
        ),
      );
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1a4fd4),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.water_drop, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 12),
                const Text('Buat Akun Baru',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                const Text('Sistem Drainase Pintar',
                    style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFDDE3F0)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nama
                        _label('Nama lengkap'),
                        TextFormField(
                          controller: _nameCtrl,
                          textCapitalization: TextCapitalization.words,
                          decoration: _inputDecoration('Nama lengkap Anda', Icons.person_outline),
                          validator: (v) => (v == null || v.isEmpty) ? 'Nama wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),

                        // Email
                        _label('Email'),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration('email@contoh.com', Icons.email_outlined),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Email wajib diisi';
                            if (!v.contains('@')) return 'Email tidak valid';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Password
                        _label('Password'),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscure,
                          decoration: _inputDecoration('Min. 8 karakter', Icons.lock_outline).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, size: 20),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Password wajib diisi';
                            if (v.length < 8) return 'Password minimal 8 karakter';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Konfirmasi password
                        _label('Konfirmasi password'),
                        TextFormField(
                          controller: _confirmCtrl,
                          obscureText: _obscure,
                          decoration: _inputDecoration('Ulangi password', Icons.lock_outline),
                          validator: (v) {
                            if (v != _passCtrl.text) return 'Password tidak cocok';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Role selector
                        _label('Daftar sebagai'),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _roleChip('masyarakat', 'Masyarakat', Icons.people_outline),
                            const SizedBox(width: 8),
                            _roleChip('pemerintah', 'Pemerintah', Icons.account_balance_outlined),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Tombol register
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1a4fd4),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Daftar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Sudah punya akun? ', style: TextStyle(fontSize: 13)),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: const Text('Masuk',
                          style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF1a4fd4),
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      );

  Widget _roleChip(String value, String label, IconData icon) {
    final selected = _role == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _role = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF1a4fd4) : const Color(0xFFF4F6FD),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? const Color(0xFF1a4fd4) : const Color(0xFFD0D8EE),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: selected ? Colors.white : Colors.grey),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: selected ? Colors.white : Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFAAABBB), fontSize: 13),
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF8899CC)),
        filled: true,
        fillColor: const Color(0xFFFAFBFF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD0D8EE))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD0D8EE))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF1a4fd4))),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red)),
      );
}
