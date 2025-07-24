# 🍳 Resepin - Recipe App for Home Ingredients

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://developer.android.com)

**Resepin** adalah aplikasi resep makanan yang didukung oleh artificial intelligence (AI). Dapatkan resep berdasarkan bahan-bahan yang tersedia di rumah tanpa perlu repot mencari secara manual. Ubah gaya hidup Anda menjadi lebih mudah dan lezat dengan Resepin.

> ⚠️ **Disclaimer**: AI dapat menghasilkan data yang tidak akurat, jadi pastikan untuk memeriksa kembali resep yang dihasilkan.

## 📱 Download APK

**[📥 Download Resepin APK](https://drive.google.com/file/d/1FxfW5dY-lNt-W5NpOZzqJ_BhlVL0Qj5Z/view?usp=sharing)**

## ✨ Fitur Utama

### 🔍 **AI-Powered Recipe Recommendation**
- Upload foto bahan makanan yang Anda miliki
- AI akan mengenali bahan dan memberikan rekomendasi resep
- Teknologi machine learning untuk prediksi resep yang akurat

### 📖 **Recipe Management**
- Lihat detail resep lengkap dengan bahan dan cara memasak
- Bookmark resep favorit untuk akses cepat
- Search dan filter resep berdasarkan nama atau bahan

### 👤 **User Authentication**
- Register dan login dengan email
- Profil pengguna yang dapat diedit
- Sinkronisasi bookmark antar device

### 🔎 **Smart Search**
- Pencarian real-time di bookmark
- Filter berdasarkan nama resep atau bahan
- Hasil pencarian yang relevan dan cepat

## 🛠️ Tech Stack

- **Frontend**: Flutter (Dart)
- **State Management**: GetX
- **HTTP Client**: http package
- **UI Components**: Google Fonts, Custom Widgets
- **Image Processing**: AI-powered ingredient recognition
- **Backend API**: Laravel REST API

## 📸 Screenshots

| Home Page | Recipe Detail | Camera Upload | Profile |
|-----------|---------------|---------------|---------|
| ![Home](assets/screenshots/home.png) | ![Scan AI](assets/screenshots/scan.png) | ![Profile](assets/screenshots/profile.png) | ![Rekomendasi Resep](assets/screenshots/rekomendasi.png) |

<!-- ## 🚀 Getting Started

### Prerequisites

Pastikan Anda memiliki tools berikut terinstall:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (≥ 3.0.0)
- [Dart SDK](https://dart.dev/get-dart) (≥ 2.17.0)
- [Android Studio](https://developer.android.com/studio) atau [VS Code](https://code.visualstudio.com)
- Android SDK dan emulator

### Installation

1. **Clone repository**
   ```bash
   git clone https://github.com/username/resepin.git
   cd resepin
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint**
   
   Edit file `lib/api/api_controller.dart`:
   ```dart
   static const String baseUrl = 'YOUR_API_BASE_URL';
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

<!-- ### Build APK

Untuk build production APK:

```bash
flutter build apk --release
```

APK akan tersedia di: `build/app/outputs/flutter-apk/app-release.apk` --> -->

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

<!-- ### Environment Variables

Create a `.env` file in the root directory:

```env
API_BASE_URL=https://your-api-domain.com/api
API_TIMEOUT=30000
```

## 🤝 Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. -->

## 👥 Team

- **AI Engineer**: Seno Aji
- **Mobile Developer**: Muhammad Firdaus Chuzaeni  
- **Backend Developer**: Daffa Ahmad Saifullah Mubaroki

## 📞 Contact & Support

<!-- - **Email**: support@resepin.com -->
- **GitHub Issues**: [Create an issue](https://github.com/username/resepin/issues)

## 🔄 Version History

### v1.0.0 (Juli 2025)
- ✅ Initial release
- ✅ AI-powered recipe recommendation
- ✅ User authentication system
- ✅ Bookmark functionality
- ✅ Recipe search and filtering
- ✅ Responsive UI design

<!-- ## 🙏 Acknowledgments

- [Flutter Team](https://flutter.dev) for the amazing framework
- [GetX](https://pub.dev/packages/get) for state management
- [Google Fonts](https://fonts.google.com) for beautiful typography
- AI/ML team for ingredient recognition technology

## 📱 Minimum Requirements

- **Android**: 5.0 (API level 21) or higher
- **Storage**: 50 MB free space
- **RAM**: 2 GB minimum, 4 GB recommended
- **Internet**: Required for AI features and recipe sync -->

---

**Made with ❤️ by Tim Kosongin Dulu**

[![Download APK](https://img.shields.io/badge/Download-APK-green?style=for-the-badge&logo=android)](https://drive.google.com/file/d/1FxfW5dY-lNt-W5NpOZzqJ_BhlVL0Qj5Z/view?usp=sharing)
