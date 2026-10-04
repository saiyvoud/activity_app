import 'package:activity/core/theme.dart';
import 'package:activity/providers/auth_provider.dart';
import 'package:activity/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _photo;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final u = context.read<AppAuthProvider>().profile;
    _name = TextEditingController(text: u?.name ?? '');
    _phone = TextEditingController(text: u?.phone ?? '');
    _photo = TextEditingController(text: u?.photoUrl ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _photo.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    final err = await context.read<AppAuthProvider>().updateProfile(
          name: _name.text,
          phone: _phone.text,
          photoUrl: _photo.text,
        );
    if (!mounted) return;
    setState(() => _loading = false);
    if (err != null) {
      showSnack(context, err, error: true);
      return;
    }
    showSnack(context, 'ບັນທຶກສຳເລັດ');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final email = context.read<AppAuthProvider>().profile?.email ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('ແກ້ໄຂໂປຣໄຟລ໌')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                    labelText: 'ຊື່ ແລະ ນາມສະກຸນ', prefixIcon: Icon(Icons.person_outline)),
                validator: (v) =>
                    (v == null || v.trim().length < 2) ? 'ກະລຸນາໃສ່ຊື່' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: email,
                enabled: false,
                decoration: const InputDecoration(
                    labelText: 'ອີເມວ (ປ່ຽນບໍ່ໄດ້)', prefixIcon: Icon(Icons.email_outlined)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                    labelText: 'ເບີໂທ', prefixIcon: Icon(Icons.phone_outlined)),
                validator: (v) => (v == null || v.trim().length < 8)
                    ? 'ເບີໂທຕ້ອງມີຢ່າງໜ້ອຍ 8 ຕົວເລກ'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _photo,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                    labelText: 'ລິ້ງຮູບໂປຣໄຟລ໌ (ບໍ່ບັງຄັບ)',
                    prefixIcon: Icon(Icons.image_outlined)),
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.isEmpty) return null;
                  return t.startsWith('http') ? null : 'ລິ້ງຕ້ອງຂຶ້ນຕົ້ນດ້ວຍ http';
                },
              ),
              const SizedBox(height: 28),
              LoadingButton(
                  loading: _loading, onPressed: _save, child: const Text('ບັນທຶກ')),
            ],
          ),
        ),
      ),
    );
  }
}

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _old = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _old.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool _loading = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    final err = await context
        .read<AppAuthProvider>()
        .changePassword(_old.text, _new.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (err != null) {
      showSnack(context, err, error: true);
      return;
    }
    showSnack(context, 'ປ່ຽນລະຫັດຜ່ານສຳເລັດ');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration deco(String label) => InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        );
    return Scaffold(
      appBar: AppBar(title: const Text('ປ່ຽນລະຫັດຜ່ານ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _old,
                obscureText: _obscure,
                decoration: deco('ລະຫັດຜ່ານເກົ່າ'),
                validator: (v) => (v == null || v.isEmpty) ? 'ກະລຸນາໃສ່ລະຫັດຜ່ານເກົ່າ' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _new,
                obscureText: _obscure,
                decoration: deco('ລະຫັດຜ່ານໃໝ່'),
                validator: (v) =>
                    (v == null || v.length < 6) ? 'ລະຫັດຜ່ານຕ້ອງມີຢ່າງໜ້ອຍ 6 ຕົວ' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirm,
                obscureText: _obscure,
                decoration: deco('ຢືນຢັນລະຫັດຜ່ານໃໝ່'),
                validator: (v) => v != _new.text ? 'ລະຫັດຜ່ານບໍ່ກົງກັນ' : null,
              ),
              const SizedBox(height: 28),
              LoadingButton(
                  loading: _loading, onPressed: _save, child: const Text('ບັນທຶກ')),
            ],
          ),
        ),
      ),
    );
  }
}
