import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../profile/profile_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();

  Box<Profile>? _profileBox;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    _profileBox = await Hive.openBox<Profile>('profileBox');
    if (_profileBox!.isNotEmpty) {
      final profile = _profileBox!.getAt(0);
      if (profile != null) {
        _nameController.text = profile.name;
        _ageController.text = profile.age.toString();
        _emailController.text = profile.email;
        _bioController.text = profile.bio ?? '';
      }
    }
    setState(() {});
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final profile = Profile(
        name: _nameController.text.trim(),
        age: int.tryParse(_ageController.text.trim()) ?? 0,
        email: _emailController.text.trim(),
        bio: _bioController.text.trim(),
      );

      if (_profileBox!.isEmpty) {
        await _profileBox!.add(profile);
      } else {
        await _profileBox!.putAt(0, profile);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile saved successfully")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter your name" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Age"),
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter your age" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter your email" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: "Bio"),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text("Save Profile"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
