# Supermarket Management System

Du an gom 2 phan:
- Backend: Spring Boot + JPA + MySQL
- Frontend: Flutter (Web/Android)

## 1) Cau truc thu muc

```text
supermarket/
|- supermarket/
|  \- supermarket/                  # Backend Spring Boot
|     |- pom.xml
|     |- seed-data-mysql.txt        # Du lieu mau SQL
|     \- src/
|        |- main/java/com/supermarket/supermarket/
|        |  |- config/              # Cau hinh (Security, CORS, ...)
|        |  |- controller/          # REST API
|        |  |- dto/                 # Request/Response DTO
|        |  |- entity/              # JPA entities
|        |  |- repository/          # JPA repositories
|        |  \- service/             # Business logic
|        \- main/resources/
|           \- application.properties
|
\- supermarket_Manager_System/      # Frontend Flutter
   |- pubspec.yaml
   \- lib/
      |- data/services/             # Goi API
      |- domain/models/             # Model du lieu
      |- presentation/pages/        # Giao dien
      |- utils/api_constants.dart   # baseUrl + API path
      \- main.dart                  # Entry point app
```

## 2) Yeu cau moi truong

- Java 21
- Maven 3.9+
- Flutter SDK (Dart 3.10+)
- MySQL 8.x

## 3) Cau hinh database (MySQL)

File dang dung: `supermarket/supermarket/supermarket/src/main/resources/application.properties`

Gia tri hien tai:
- MySQL host/port: `localhost:3307`
- Database: `supermarket`
- Username: `root`
- Password: `123456`

Datasource URL hien tai:

```properties
spring.datasource.url=jdbc:mysql://localhost:3307/supermarket?createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Ho_Chi_Minh
```

### Chay MySQL nhanh bang Docker (tuy chon)

```bash
docker run --name supermarket-mysql -e MYSQL_ROOT_PASSWORD=123456 -e MYSQL_DATABASE=supermarket -p 3307:3306 -d mysql:8.4
```

### Nap du lieu mau (seed)

Tu folder backend:

```bash
cd supermarket/supermarket/supermarket
mysql -h 127.0.0.1 -P 3307 -u root -p supermarket < seed-data-mysql.txt
```

## 4) Chay backend (Spring Boot)

Tu root workspace:

```bash
cd supermarket/supermarket/supermarket
mvn clean install
mvn spring-boot:run
```

Mac dinh backend chay port `8080` (neu chua set `server.port`).

## 5) Chay frontend (Flutter)

Tu root workspace:

```bash
cd supermarket_Manager_System
flutter pub get
flutter run 
```

Neu muon fix web port cu the:

```bash
flutter run -d chrome --web-port 50707
```

## 6) Sua port

### 6.1 Doi port backend

Mo file:
`supermarket/supermarket/supermarket/src/main/resources/application.properties`

Them hoac sua:

```properties
server.port=9090
```

Sau do restart backend.

### 6.2 Doi port MySQL

Cung file `application.properties`, sua:

```properties
spring.datasource.url=jdbc:mysql://localhost:3308/supermarket?createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Ho_Chi_Minh
```

### 6.3 Doi frontend goi sang backend port moi

Mo file:
`supermarket_Manager_System/lib/utils/api_constants.dart`

Sua `baseUrl`:

```dart
static const String baseUrl = 'http://localhost:9090';
```

> Frontend da ho tro `API_BASE_URL` qua `--dart-define` de chay mobile that.
> Mac dinh:
> - Android emulator: `http://10.0.2.2:8080`
> - Web/Desktop: `http://localhost:8080`

Vi du chay Android emulator:

```bash
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

Vi du chay tren dien thoai that (cung wifi voi may chay backend):

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.50:8080
```

> Thay `192.168.1.50` bang IP LAN cua may tinh chay Spring Boot.

## 7) Lenh kiem tra nhanh

Backend:

```bash
cd supermarket/supermarket/supermarket
mvn -DskipTests compile
```

Frontend:

```bash
cd supermarket_Manager_System
flutter analyze
flutter test
```

## 8) SQLite local cho mobile

Frontend da tich hop `sqflite` de luu session dang nhap local (table `session` trong file DB `supermarket_mobile.db`).

Tac dung:
- Dang nhap xong, app luu session vao SQLite.
- Mo lai app tren mobile se tu restore session.
- Logout se xoa session trong SQLite.

Luu y:
- Backend van dung MySQL (khong doi sang SQLite o Spring Boot).
- SQLite chi dung cho local state/caching tren app mobile.

