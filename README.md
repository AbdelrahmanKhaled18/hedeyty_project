# Hedieaty

Hedieaty is a Flutter-based mobile application designed to make every gift special. This project includes features such as user sign-up, event creation, and gift management.

## Features

- **User Sign-Up and Authentication**: Users can sign up and log in to the app using their email and password.
- **Event Creation and Management**: Users can create and manage events, including setting event details such as name, date, location, and description.
- **Gift List and Gift Management**: Users can create and manage a list of gifts for each event, including gift details such as name, category, description, and price.
- **Push Notifications using Firebase Cloud Messaging**: The app uses Firebase Cloud Messaging to send push notifications to users.
- **Animated Splash Screen**: The app features an animated splash screen using Lottie animations.

## Getting Started

### Prerequisites

- **Flutter SDK**: [Install Flutter](https://flutter.dev/docs/get-started/install)
- **Dart SDK**: Included with Flutter
- **Android Studio or Visual Studio Code**: Recommended IDEs for Flutter development
- **Firebase Account**: Required for Firebase services

### Installation

1. **Clone the repository**:
   ```sh
   git clone https://github.com/AbdelrahmanKhaled18/Hedieaty.git
   cd Hedieaty
   ```

2. **Install dependencies**:
   ```sh
   flutter pub get
   ```

3. **Set up Firebase**:
    - Follow the instructions to add Firebase to your Flutter app: [Add Firebase to your Flutter app](https://firebase.google.com/docs/flutter/setup)
    - Place the `google-services.json` file in the `android/app` directory.

4. **Run the app**:
   ```sh
   flutter run
   ```

## Project Structure

- `lib/`: Contains the main source code for the Flutter application.
    - `main.dart`: Entry point of the application.
    - `screens/`: Contains the UI screens of the application.
        - `splash_screen.dart`: Displays the animated splash screen.
        - `auth/`: Contains authentication-related screens.
        - `home/`: Contains the home screen and related widgets.
        - `event/`: Contains screens and widgets related to event creation and management.
        - `gift/`: Contains screens and widgets related to gift creation and management.
    - `widgets/`: Contains reusable widgets.
    - `services/`: Contains services for Firebase and other backend integrations.
- `integration_test/`: Contains integration tests for the application.
- `assets/`: Contains images, animations, and other assets.

## Running Tests

To run the integration tests, use the following command:
```sh
flutter test integration_test
```

## Contributing

Contributions are welcome! Please fork the repository and create a pull request with your changes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgements

- [Flutter](https://flutter.dev/)
- [Firebase](https://firebase.google.com/)
- [Lottie](https://lottiefiles.com/)
- [Google Fonts](https://fonts.google.com/)

For more information, please refer to the [online documentation](https://docs.flutter.dev/).
```