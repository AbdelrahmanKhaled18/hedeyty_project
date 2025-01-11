# Hedieaty Project

## Overview

Hedieaty is a Flutter-based application designed to help users manage events and gifts efficiently. The app follows the MVC (Model-View-Controller) pattern to ensure modularity and maintainability. It integrates with Firebase for data storage and real-time updates.

## Features

- **User Authentication**: Users can sign up and sign in to the app.
- **Event Management**: Users can create, view, edit, and delete events.
- **Gift Management**: Users can create, view, edit, and delete gifts associated with events.
- **Sorting and Filtering**: Users can sort and filter gifts based on various criteria.
- **Firebase Integration**: The app uses Firebase for data storage, authentication, and real-time updates.

## Project Structure

The project is organized into the following main directories:

- `lib/models`: Contains the data models.
- `lib/controllers`: Contains the controllers that handle business logic.
- `lib/screens`: Contains the UI components (views).
- `lib/widgets`: Contains reusable UI components.
- `integration_test`: Contains integration tests for end-to-end testing.

### Models

Models represent the data and business logic of the application. For example, the `Gift` model defines the structure of a gift object.

### Controllers

Controllers handle the logic and data manipulation. For example, the `GiftController` manages fetching and deleting gifts from Firebase.

### Views

Views manage the UI and presentation logic. For example, the `GiftListScreen` displays a list of gifts and interacts with the `GiftController`.

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Firebase account

### Installation

1. **Clone the repository:**

    ```sh
    git clone https://github.com/AbdelrahmanKhaled18/hedieaty.git
    cd hedieaty
    ```

2. **Install dependencies:**

    ```sh
    flutter pub get
    ```

3. **Set up Firebase:**

    - Follow the [Firebase setup guide](https://firebase.google.com/docs/flutter/setup) to add Firebase to your Flutter project.
    - Update the `android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist` files with your Firebase configuration.

4. **Run the app:**

    ```sh
    flutter run
    ```

## Usage

### Running Tests

To run the integration tests, use the following command:

```sh
flutter test integration_test
```

### Project Structure

- **Models**: Define the data structures and business logic.
- **Controllers**: Handle the logic and data manipulation.
- **Views**: Manage the UI and presentation logic.

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Make your changes.
4. Commit your changes (`git commit -m 'Add new feature'`).
5. Push to the branch (`git push origin feature-branch`).
6. Create a pull request.

