# board_game_journal

Каталог и записи по настольным играм

## Начало

### Board Game Journal 🎲

Приложение для учета настольных игр с возможностью отслеживания статистики игроков, анимированным интерфейсом и мультиязычной поддержкой.

## Особенности ✨
- 📊 Учет игровой статистики и победителей
- 🖼️ Анимированный коллаж обложек игр
- 🌍 Поддержка нескольких языков (русский/английский)
- 🔥 Интеграция с Firebase Firestore
- 📱 Адаптивный интерфейс
- 🔄 Автоматическая подгрузка данных
- 🎨 Кастомизируемый интерфейс редактирования

## Требования 📋
- Flutter SDK ≥3.0.0
- Dart ≥2.17.0
- Firebase аккаунт
- Android Studio/VSCode с эмулятором или устройством

## Установка ⚙️

### 1. Клонировать репозиторий:

```bash
git clone https://github.com/sokrata/board-game-journal.git
```

### 2. Установить зависимости:

```
flutter pub get
```

### 3. Настроить Firebase:

* Создайте проект в Firebase Console (https://console.firebase.google.com/)
* Добавьте приложение Android/iOS
* Скачайте файлы конфигурации:
  * google-services.json для Android
  * GoogleService-Info.plist для iOS
* Включите Firestore в режиме тестирования

### 4. Запустить приложение:

```bash
flutter run
```

### Настройка базы данных 🔧
Создайте коллекцию games в Firestore со следующей структурой документа:

```javascript
{
  title: string,
  year: number,
  lastPlayed: timestamp,
  totalPlays: number,
  images: array<string>,
  winners: array<map> [
    {
      name: string,
      wins: number,
      averageWins: number
    }
  ]
}
```

#### Пример документа:

```javascript
{
  title: "Catan",
  year: 1995,
  lastPlayed: January 15, 2023 at 3:00:00 PM UTC-7,
  totalPlays: 42,
  images: ["https://example.com/image1.jpg"],
  winners: [
    {name: "Alice", wins: 15, averageWins: 3.2}
  ]
}
```

### Конфигурация ⚙️

###### Окружение

Создайте файл .env в корне проекта:

```env
FIREBASE_API_KEY=your_api_key
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
```

#### Используемые технологии 🛠️
Flutter - Основной фреймворк
Firebase Firestore - База данных
Provider - Управление состоянием
CachedNetworkImage - Кэширование изображений
AudioPlayers - Воспроизведение звуков

### Лицензия 📄
Этот проект распространяется под лицензией GNU.

Примечание: Для работы с изображениями используйте действительные URL-адреса. Для тестирования можно использовать imgur или аналогичные сервисы.

Поддержка: По вопросам настройки обращайтесь на sokrata@yandex.ru (Сергей)