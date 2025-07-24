# 🍳 Resepin - Recipe App for Home Ingredients

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://developer.android.com)

**Resepin** is a recipe application powered by artificial intelligence (AI). Get recipes based on the ingredients you have at home without the hassle of searching manually. Transform your lifestyle to be more convenient and delicious with Resepin.

> ⚠️ **Disclaimer**: AI can generate inaccurate data, so please double-check the generated recipes.

## 📱 Download APK

**[📥 Download Resepin APK](https://drive.google.com/file/d/1FxfW5dY-lNt-W5NpOZzqJ_BhlVL0Qj5Z/view?usp=sharing)**

## ✨ Key Features

### 🔍 **AI-Powered Recipe Recommendation**
- Upload photos of ingredients you have
- AI will recognize ingredients and provide recipe recommendations
- Machine learning technology for accurate recipe predictions

### 📖 **Recipe Management**
- View complete recipe details with ingredients and cooking instructions
- Bookmark favorite recipes for quick access
- Search and filter recipes by name or ingredients

### 👤 **User Authentication**
- Register and login with email
- Editable user profile
- Bookmark synchronization across devices

### 🔎 **Smart Search**
- Real-time search in bookmarks
- Filter by recipe name or ingredients
- Relevant and fast search results

## 🛠️ Tech Stack

- **Frontend**: Flutter (Dart)
- **State Management**: GetX
- **HTTP Client**: http package
- **UI Components**: Google Fonts, Custom Widgets
- **Image Processing**: AI-powered ingredient recognition
- **Backend API**: Laravel REST API

## 📸 Screenshots

| Home Page | AI Scan | Profile | Recipe Recommendation |
|-----------|---------|---------|----------------------|
| ![Home](assets/screenshots/home.png) | ![Scan AI](assets/screenshots/scan.png) | ![Profile](assets/screenshots/profile.png) | ![Recipe Recommendation](assets/screenshots/rekomendasi.png) |

## 🏗️ Project Structure

```
lib/
├── api/                    # API configurations
├── controllers/            # GetX controllers
│   ├── auth/              # Authentication controllers
│   ├── bookmark_controller.dart
│   └── recipe_controller.dart
├── models/                # Data models
├── pages/                 # UI pages
│   ├── auth/              # Login & Register pages
│   ├── profile/           # Profile related pages
│   ├── home_page.dart
│   └── detail_resep_page.dart
├── services/              # API services
├── theme/                 # App theme & colors
├── widgets/               # Reusable widgets
└── main.dart              # App entry point
```

## 🔧 Configuration

### API Endpoints

The app connects to the following API endpoints:

```dart
// Authentication
POST /login
POST /register
GET  /user
POST /logout

// Recipe Management
POST /recipe/recommend     # AI recipe recommendation
POST /recipe/predict       # Ingredient prediction
GET  /recipe/bookmark/detail/{id}

// Bookmark Management
POST /recipe/bookmark/add
POST /recipe/bookmark/remove
GET  /recipe/bookmark/list
```

## 👥 Team

- **AI Engineer**: Seno Aji
- **Mobile Developer**: Muhammad Firdaus Chuzaeni  
- **Backend Developer**: Daffa Ahmad Saifullah Mubaroki

## 📞 Contact & Support

- **GitHub Issues**: [Create an issue](https://github.com/username/resepin/issues)

## 🔄 Version History

### v1.0.0 (July 2025)
- ✅ Initial release
- ✅ AI-powered recipe recommendation
- ✅ User authentication system
- ✅ Bookmark functionality
- ✅ Recipe search and filtering
- ✅ Responsive UI design

---

**Made with ❤️ by Team Resepin**

[![Download APK](https://img.shields.io/badge/Download-APK-green?style=for-the-badge&logo=android)](https://drive.google.com/file/d/1FxfW5dY-lNt-W5NpOZzqJ_BhlVL0Qj5Z/view?usp=sharing)
