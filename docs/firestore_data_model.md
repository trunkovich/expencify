## Firestore data model (фиксируем контракт)

### Namespace

- Все данные пользователя живут в `users/{uid}/...`
- Любой экран (категории/расходы) читает и пишет **только** внутри `users/{currentUid}`.

### Collections

#### `users/{uid}/categories/{categoryId}`

- **name**: String
- **emoji**: String? (optional)
- **sortOrder**: int
- **createdAt**: Timestamp
- **updatedAt**: Timestamp

#### `users/{uid}/expenses/{expenseId}`

- **amount**: num (Firestore number)
- **currency**: String (ISO 4217, напр. `USD`)
- **date**: Timestamp (дата/время расхода)
- **categoryId**: String (ссылка на id категории)
- **note**: String? (optional)
- **createdAt**: Timestamp
- **updatedAt**: Timestamp

### Planned queries (для UI/сервисов и будущих индексов)

#### Categories

- **List categories (sorted)**:
  - path: `users/{uid}/categories`
  - query: `orderBy(sortOrder, asc).orderBy(createdAt, asc)`

#### Expenses

- **List expenses by date (default screen)**:
  - path: `users/{uid}/expenses`
  - query: `orderBy(date, desc).limit(N)`

- **List expenses by date range**:
  - query: `where(date, >= from).where(date, < to).orderBy(date, desc)`

- **Filter by category**:
  - query: `where(categoryId, == someCategoryId).orderBy(date, desc)`

- **Filter by category + date range** (если понадобится):
  - query: `where(categoryId, == id).where(date, >= from).where(date, < to).orderBy(date, desc)`

