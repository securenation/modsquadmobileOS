import 'package:flutter/material.dart';
import 'package:modsquad_meetings/auth/auth_repository.dart';
import 'package:modsquad_meetings/theme/app_colors.dart';

class SignedInScreen extends StatelessWidget {
  const SignedInScreen({super.key, required this.auth});

  final AuthRepository auth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Mission Control',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                auth.currentEmail ?? 'Signed in',
                style: const TextStyle(color: AppColors.muted, fontSize: 14),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: auth.signOut,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.foreground,
                  side: const BorderSide(color: AppColors.border),
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
