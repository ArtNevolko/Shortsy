import 'package:flutter/material.dart';
import '../shared/widgets/index.dart';
import '../services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _name = TextEditingController();
  final _bio = TextEditingController();
  final _link = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _name.text = await AuthService().getUserName();
    _bio.text = (await AuthService().getBio()) ?? '';
    _link.text = (await AuthService().getLink()) ?? '';
    _avatarPath = await AuthService().getAvatarPath();
    if (mounted) setState(() {});
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final x =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x != null) {
      setState(() => _avatarPath = x.path);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await AuthService().saveProfile(
        name: _name.text,
        bio: _bio.text,
        link: _link.text,
        avatarPath: _avatarPath);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Профиль сохранён')));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Редактирование профиля',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              InkWell(
                onTap: _pickAvatar,
                borderRadius: BorderRadius.circular(44),
                child: Glass(
                  borderRadius: BorderRadius.circular(44),
                  padding: const EdgeInsets.all(6),
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.white24,
                    backgroundImage: (_avatarPath != null)
                        ? FileImage(File(_avatarPath!))
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Glass(
                borderRadius: BorderRadius.circular(20),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(labelText: 'Имя'),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Введите имя' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _bio,
                      decoration: const InputDecoration(labelText: 'Био'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _link,
                      decoration: const InputDecoration(labelText: 'Ссылка'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: AppButton.primary(
                  label: 'Сохранить',
                  icon: Icons.check_rounded,
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
