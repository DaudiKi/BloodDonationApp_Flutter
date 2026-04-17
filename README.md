# 🩸 Blood Donation App (Flutter)

A cross-platform blood donation management system built with Flutter and Supabase. This application is a direct conversion from the original iOS/Swift version, maintaining 1:1 visual parity while upgrading the backend to a scalable PostgreSQL infrastructure.

---

## ✨ Features

### 👤 Donor Experience
- **Dynamic Dashboard**: View your current donation streaks, history, and upcoming appointments at a glance.
- **Streak System**: Earn streaks for every approved donation. Stay motivated to save lives!
- **Appointment Booking**: Book your next donation slot. (Note: Requires at least 1 streak to book).
- **Notifications**: Stay informed about donation milestones and app updates.
- **Google Sign-In**: Quick and secure authentication.

### 🛡️ Admin Management
- **User Control**: Enable or disable donor accounts and manage roles.
- **Donation Logging**: Professional interface for logging donations with built-in limit checks (4 donations per year max).
- **Approval Workflow**: Review pending donations and approve or reject them to update donor status/streaks.
- **Real-time Stats**: View active donors and recent activity.

---

## 🎨 Design System

The app follows a premium "Deep Red & Cream" design language replicated from the original Swift implementation:
- **Primary Color**: Deep Red (`#B31A1A`)
- **Background**: Cream (`#FAF5E6`)
- **Typography**: Clean, professional sans-serif (Roboto).
- **UI Elements**: Glassmorphism effects on login, smooth gradients, and rounded card layouts.

---

## 🚀 Tech Stack

- **Framework**: [Flutter](https://flutter.dev)
- **Backend-as-a-Service**: [Supabase](https://supabase.com)
  - **Auth**: Email/Password & Google OAuth.
  - **Database**: PostgreSQL with Row-Level Security (RLS).
- **State Management**: Provider
- **Utilities**: `intl` for formatting, `supabase_flutter` for real-time data.

---

## 🛠️ Getting Started

### Prerequisites
- Flutter SDK (v3.6.0+)
- A Supabase project with the appropriate schema.

### Configuration
1. Clone the repository.
2. Update the Supabase configuration in `lib/main.dart`:
   ```dart
   await Supabase.initialize(
     url: 'YOUR_SUPABASE_URL',
     anonKey: 'YOUR_ANON_KEY',
   );
   ```
3. Update the Google Sign-In `webClientId` (if applicable) in `lib/services/auth_service.dart`.

### Installation
```bash
# Get dependencies
flutter pub get

# Run the app
flutter run
```

---

## 📝 Database Schema

The app expects the following tables in Supabase:
- `users`: `id`, `email`, `name`, `role`, `is_active`, `streaks`, `has_notified_four_donations`.
- `donations`: `id`, `donor_id`, `hospital`, `blood_type`, `date`, `status`.
- `appointments`: `id`, `donor_id`, `hospital_id`, `hospital_name`, `hospital_address`, `date`, `status`.
- `hospitals`: `id`, `name`, `address`.

---

## 👨‍💻 Developer Notes

This project was developed as a high-fidelity conversion. Special care was taken to ensure that every `VStack`, `HStack`, and `ZStack` from the Swift source was accurately mapped to its Flutter equivalent (`Column`, `Row`, `Stack`), ensuring the user experience remains identical across platforms.
