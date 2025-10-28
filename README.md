# Master's Thesis Project (Frontend): Sports Facilities Management System

## Introduction

This project implements a complete system to facilitate and automate the process of booking a sport facility and its underlying management, through the use of the telemetry data obtained from physical devices installed at those facilities. This result is achieved by means of a layered architecture implemented with a NestJS backend, a PostgreSQL database, and a cross-platform frontend developed in Flutter. The system provides secure, role-based management: Clients, Administrators, and Superusers via JWT, and IoT devices via API Keys; covering key functionalities such as reservation management, court status monitoring, and notifications.

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.35 or higher)
- IDE with Flutter support (VS Code or Android Studio)
- A physical device or emulator for testing.

### Installation
1.  Clone the repository:
```bash
git clone [repository-URL]
cd [repository-folder]
```
2.  Install Dart dependencies:
```bash
flutter pub get
```

### Running the Application
- Ensure the Backend API is running.
- Execute the application in your target environment:
```bash
flutter run
```

---

## Backend Connection Configuration

### API URL Setup
The frontend must be configured to point to the running NestJS backend. You will need to define the `BASE_URL` variable, often in a configuration file or using build *flavors*.

| Environment | Backend Location | `BASE_URL` Value | Notes |
| :--- | :--- | :--- | :--- |
| Android Emulator | Backend running on the host machine. | `http://10.0.2.2:3000` | `10.0.2.2` is the special alias to access the host machine from the Android emulator. |
| iOS Simulator | Backend running on the host machine. | `http://localhost:3000` or `http://127.0.0.1:3000` | The iOS simulator uses the host's loopback interface. |
| Web/Desktop | Backend running on the host machine. | `http://localhost:3000` | Standard local connection. |
| Physical Device (LAN/VPN) | Backend running on a different machine on the network. | `http://<host-IP-address>:3000` | Use the actual local IP address of the machine hosting the backend (e.g., `192.168.1.5`). |

---

## User Roles and Experience (UX)

The application interface is dynamically adjusted based on the authenticated user's role:

| User Role | Primary Functionalities |
| :--- | :--- |
| **CLIENT** | Search and book facilities, view personal profile, reservation history, and notifications. |
| **ADMINISTRATOR** | Manage courts and resources for *their* specific complex, and view real-time telemetry data. |

---

## Architecture and Testing

* **State Management:** Utilizes `Provider` for application state management.
* **Testing:** How to execute widget and integration tests:
```bash
flutter test
```

---
