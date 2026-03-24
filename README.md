# Supermarket Management System

He thong quan ly sieu thi gom 2 phan:
- **Backend**: Spring Boot + Spring Data JPA + MySQL
- **Frontend**: Flutter (Web/Android/iOS/Desktop)

## 1) Cau truc thu muc tong quan

```text
supermarket/
|- .github/                                  # CI/CD, workflow
|- docs/                                     # Tai lieu + sequence/diagram
|- supermarket/
|  \- supermarket/                           # Backend Spring Boot
|     |- .mvn/
|     |- src/
|     |- mvnw
|     |- mvnw.cmd
|     |- pom.xml
|     |- seed-data-mysql.sql
|     \- seed-data-mysql.txt
|- supermarket_Manager_System/               # Frontend Flutter
|  |- android/
|  |- ios/
|  |- linux/
|  |- macos/
|  |- web/
|  |- windows/
|  |- lib/
|  |- test/
|  \- pubspec.yaml
\- README.md
```

## 2) Cau truc chi tiet Backend

Path goc backend:
`supermarket/supermarket`

```text
supermarket/supermarket/
|- src/main/java/com/supermarket/supermarket/
|  |- config/                                # Security, CORS, app config
|  |- controller/                            # REST API controllers
|  |- dto/                                   # DTO request/response
|  |- entity/                                # JPA entities
|  |- exception/                             # Exception + handler
|  |- repository/                            # Spring Data repositories
|  |- service/                               # Business logic
|  |- BCryptGenerator.java
|  \- SupermarketApplication.java            # Spring Boot entry point
|- src/main/resources/
|  |- application.properties
|  |- static/
|  \- templates/
|- pom.xml
|- seed-data-mysql.sql
\- seed-data-mysql.txt
```

## 3) Cau truc chi tiet Frontend

Path goc frontend:
`supermarket_Manager_System`

```text
supermarket_Manager_System/
|- lib/
|  |- core/                                  # Core utilities (neu co)
|  |- data/
|  |  |- local/                              # Local storage
|  |  \- services/                           # Goi API backend
|  |- domain/
|  |  \- models/                             # Models
|  |- presentation/
|  |  |- pages/                              # Screens/pages
|  |  \- widgets/                            # Shared widgets
|  |- utils/
|  |  |- api_constants.dart
|  |  |- api_constants_io.dart
|  |  \- api_constants_stub.dart
|  \- main.dart                              # Flutter entry point
|- android/
|- ios/
|- web/
|- windows/
|- macos/
|- linux/
|- test/
\- pubspec.yaml
```

## 4) Yeu cau moi truong

- Java 21
- Maven 3.9+
- Flutter SDK (Dart SDK `^3.10.4`)
- MySQL 8.x

Kiem tra nhanh:

```bash
java -version
mvn -v
flutter --version
mysql --version
```

## 5) Cau hinh Backend (MySQL + Spring Boot)

File cau hinh:
`supermarket/supermarket/src/main/resources/application.properties`

Thong tin mac dinh hien tai:
- `spring.datasource.url=jdbc:mysql://localhost:3307/supermarket?...`
- `spring.datasource.username=root`
- `spring.datasource.password=123456`
- `spring.jpa.hibernate.ddl-auto=update`

Luu y bao mat:
- Khuyen nghi dua tai khoan mat khau DB va mail vao bien moi truong.
- Khong hard-code thong tin nhay cam khi deploy.

### Khoi dong MySQL bang Docker (tuy chon)

```bash
docker run --name supermarket-mysql -e MYSQL_ROOT_PASSWORD=123456 -e MYSQL_DATABASE=supermarket -p 3307:3306 -d mysql:8.4
```

### Seed du lieu mau

```bash
cd supermarket/supermarket
mysql -h 127.0.0.1 -P 3307 -u root -p supermarket < seed-data-mysql.txt
```

## 6) Huong dan chay Backend

Tu thu muc goc repo:

```bash
cd supermarket/supermarket
mvn clean install
mvn spring-boot:run
```

Backend mac dinh chay port `8080` (neu chua set `server.port`).

API base URL:
`http://localhost:8080`

## 7) Huong dan chay Frontend

Tu thu muc goc repo:

```bash
cd supermarket_Manager_System
flutter pub get
flutter run
```

Chay Web voi port cu the:

```bash
flutter run -d chrome --web-port 50707
```

## 8) Cau hinh Frontend goi API

Frontend dung:
`supermarket_Manager_System/lib/utils/api_constants.dart`

Da ho tro chon host theo platform va override bang `--dart-define`.

Vi du:

```bash
# Android emulator
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8080

# Thiet bi that (cung mang LAN voi backend)
flutter run --dart-define=API_BASE_URL=http://192.168.1.50:8080
```

> Thay `192.168.1.50` bang IP LAN cua may chay backend.

## 9) Doi port nhanh

### Doi port backend

Sua `application.properties`:

```properties
server.port=9090
```

### Doi port MySQL

Sua `spring.datasource.url`:

```properties
spring.datasource.url=jdbc:mysql://localhost:3308/supermarket?createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Ho_Chi_Minh
```

### Doi URL frontend toi backend moi

Chay app voi `--dart-define=API_BASE_URL=http://localhost:9090`
hoac cap nhat logic trong cac file `api_constants_*.dart`.

## 10) Lenh kiem tra nhanh

Backend:

```bash
cd supermarket/supermarket
mvn -DskipTests compile
```

Frontend:

```bash
cd supermarket_Manager_System
flutter analyze
flutter test
```

## 11) Ghi chu cho mobile local storage

Frontend dang su dung `sqflite` de luu session local (`supermarket_mobile.db`).

- Dang nhap thanh cong -> luu session
- Mo lai app -> restore session
- Dang xuat -> xoa session

Backend van su dung MySQL; SQLite chi dung cho local state tren app.

