import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/category.dart';

class CategoryPresets {
  CategoryPresets._();

  static List<Category> build({required Timestamp now}) {
    return [
      Category(
        id: 'food_groceries',
        name: 'Еда и продукты',
        emoji: '🛒',
        sortOrder: 10,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: 'restaurants',
        name: 'Кафе и рестораны',
        emoji: '🍽️',
        sortOrder: 20,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: 'transport',
        name: 'Транспорт',
        emoji: '🚌',
        sortOrder: 30,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: 'car',
        name: 'Авто',
        emoji: '🚗',
        sortOrder: 40,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: 'housing',
        name: 'Жильё',
        emoji: '🏠',
        sortOrder: 50,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: 'internet',
        name: 'Связь и интернет',
        emoji: '📶',
        sortOrder: 60,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: 'health',
        name: 'Здоровье',
        emoji: '🩺',
        sortOrder: 70,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: 'clothes',
        name: 'Одежда',
        emoji: '👕',
        sortOrder: 80,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: 'shopping',
        name: 'Покупки',
        emoji: '🛍️',
        sortOrder: 90,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: 'entertainment',
        name: 'Развлечения',
        emoji: '🎮',
        sortOrder: 100,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: 'subscriptions',
        name: 'Подписки',
        emoji: '🔁',
        sortOrder: 110,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: 'travel',
        name: 'Путешествия',
        emoji: '✈️',
        sortOrder: 120,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: 'gifts',
        name: 'Подарки и донаты',
        emoji: '🎁',
        sortOrder: 130,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: 'education',
        name: 'Образование',
        emoji: '📚',
        sortOrder: 140,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
