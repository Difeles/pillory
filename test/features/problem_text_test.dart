import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillory/l10n/app_localizations.dart';
import 'package:pillory/l10n/labels.dart';

void main() {
  // Every message the domain throws, as written there.
  const thrown = [
    'Количество не может быть отрицательным',
    'Остаток не может быть отрицательным',
    'Лекарство в архиве',
    'Название обязательно',
    'Укажите единицу учёта',
    'Порог не может быть отрицательным',
    'Дозировка должна быть больше нуля',
    'Укажите единицу дозировки',
    'Выберите дни недели',
    'Выберите даты',
    'Дата окончания раньше даты начала',
    'Некорректное время',
    'Приём уже отмечен как принятый',
    'Списания для этой отметки не сохранены',
    'Заполните хотя бы одно поле',
    'Не больше 12 пунктов в записи',
  ];

  test('every thrown message has an English text and Russian stays as is', () {
    final en = lookupAppLocalizations(const Locale('en'));
    final ru = lookupAppLocalizations(const Locale('ru'));
    for (final m in thrown) {
      expect(ru.problem(m), m);
      expect(en.problem(m), isNot(m), reason: m);
    }
    expect(en.problem('Единица должна быть «шт.»'), contains('pcs'));
    expect(
      ru.problem('Единица должна быть «шт.»'),
      'Единица должна быть «шт.»',
    );
  });
}
