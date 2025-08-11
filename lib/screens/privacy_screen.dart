import 'package:flutter/material.dart';
import '../shared/widgets/index.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Политика конфиденциальности',
      child: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Политика конфиденциальности Shortsy\n\n'
          '1. Мы уважаем вашу конфиденциальность.\n'
          '2. Приложение хранит профиль локально для демо-версии.\n'
          '3. При выпуске 1.0, серверная часть и сбор данных будут описаны подробнее.',
        ),
      ),
    );
  }
}
