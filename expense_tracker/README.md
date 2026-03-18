# Expense Tracker with Charts

A clean, minimal expense tracker built with Flutter that helps you stay on top of your finances without the clutter. Track your daily income and expenses, organize them by category, and see where your money goes through intuitive charts — all stored locally on your device.

## Screenshots

| Home Screen | Add Transaction | Analytics |
|:-----------:|:---------------:|:---------:|
| View balance & transactions | Log income or expenses | Visualize spending trends |

## What It Does

- **Track income & expenses** — Add transactions with a title, amount, category, date, and optional note
- **Monthly overview** — Navigate between months to see your balance, total income, and total spending at a glance
- **Category breakdown** — Organize transactions into categories like Food, Transport, Shopping, Salary, Freelance, and more
- **Visual analytics** — Interactive line charts show daily spending trends; pie charts break down where your money goes
- **Edit & delete** — Tap a transaction to update it, or swipe to delete
- **Offline-first** — All data is stored locally using Hive, so nothing leaves your device

## Tech Stack

| Tool | Purpose |
|------|---------|
| **Flutter** | Cross-platform UI framework |
| **Hive** | Lightweight, fast local storage (NoSQL) |
| **fl_chart** | Beautiful, customizable charts |
| **uuid** | Unique transaction IDs |
| **intl** | Date and number formatting |

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/
│   ├── transaction_model.dart         # Data model + Hive type adapters
│   └── transaction_model.g.dart       # Generated Hive adapter code
├── screens/
│   ├── home_screen.dart               # Main screen with balance & list
│   ├── add_transaction_screen.dart    # Form to add/edit transactions
│   └── chart_screen.dart              # Analytics with line & pie charts
├── services/
│   └── transaction_service.dart       # CRUD operations + data queries
├── utils/
│   ├── categories.dart                # Category definitions with icons
│   └── theme.dart                     # App-wide theme and colors
└── widgets/
    ├── balance_card.dart              # Gradient balance summary card
    └── transaction_list_item.dart     # Swipeable transaction row
```

## Getting Started

### Prerequisites

- Flutter SDK 3.1.0 or higher
- Dart SDK 3.1.0 or higher

### Installation

```bash
# Clone the repo
git clone https://github.com/Haris-Ahmed83/Flutter-Journey.git

# Navigate to the project
cd Flutter-Journey/expense_tracker

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Build for Production

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## How It Works

The app uses **Hive** as a local NoSQL database to persist transactions on the device. Each transaction is stored as a typed object with fields for title, amount, category, type (income/expense), date, and an optional note.

The **home screen** displays a gradient balance card with total income, expenses, and net balance for the selected month. Below it, a scrollable list shows all transactions — tap to edit, swipe left to delete.

The **analytics screen** renders a daily line chart (income vs. expenses) and pie charts that break down spending by category, with percentage labels and a color-coded legend.

## Contributing

Feel free to fork this repo and submit pull requests. If you find a bug or have a feature request, open an issue.

## License

This project is open source and available under the [MIT License](LICENSE).
