# Chạy project Supermarket trong Cursor

Bạn có thể chạy **cả frontend (Flutter) và backend (Spring Boot)** ngay trong Cursor.

---

## 1. Cần cài đặt gì?

### Backend (Spring Boot)

| Công cụ        | Phiên bản | Ghi chú                                                   |
| -------------- | --------- | --------------------------------------------------------- |
| **Java (JDK)** | 21        | [Adoptium](https://adoptium.net/) hoặc Oracle JDK 21      |
| **Maven**      | 3.8+      | [maven.apache.org](https://maven.apache.org/download.cgi) |
| **MySQL**      | 8.x       | Chạy trên **port 3307**, user `root`, password `123456`   |

### Frontend (Flutter)

| Công cụ         | Ghi chú                                                                       |
| --------------- | ----------------------------------------------------------------------------- |
| **Flutter SDK** | [flutter.dev](https://flutter.dev/docs/get-started/install) — đã bao gồm Dart |

### Kiểm tra nhanh

```powershell
java -version    # Java version 21
mvn -version     # Apache Maven 3.x
flutter --version
mysql --version  # hoặc kiểm tra MySQL đang chạy port 3307
```

---

## 2. Extension nên cài trong Cursor

Mở **Extensions** (Ctrl+Shift+X), tìm và cài:

| Extension                   | ID                            | Dùng cho                                         |
| --------------------------- | ----------------------------- | ------------------------------------------------ |
| **Extension Pack for Java** | `vscodejava.vscode-java-pack` | Backend: soạn thảo, chạy, debug Java/Spring Boot |
| **Flutter**                 | `Dart-Code.flutter`           | Frontend: Flutter + Dart (đã gồm Dart extension) |

Gợi ý thêm (không bắt buộc):

- **REST Client** hoặc **Thunder Client** — gọi thử API
- **MySQL** — xem DB nếu dùng MySQL client trong Cursor

---

## 3. Chuẩn bị database (MySQL)

1. Cài và chạy MySQL, mở **port 3307** (mặc định thường là 3306; có thể đổi config MySQL hoặc đổi `application.properties` cho đúng port).
2. Tạo database và seed data (tùy chọn):
   ```powershell
   cd supermarket\supermarket
   mysql -u root -p -P 3307 -h 127.0.0.1 < seed-data-mysql.sql
   ```
   Hoặc dùng `createDatabaseIfNotExist=true` trong `application.properties` và để Spring Boot tạo bảng (JPA `ddl-auto=update`).

---

## 4. Chạy Backend trong Cursor

1. Mở **Terminal** (Ctrl+`) trong Cursor.
2. Chạy:
   ```powershell
   cd supermarket\supermarket
   mvn spring-boot:run
   ```
3. Đợi đến khi thấy dòng kiểu: `Started SupermarketApplication in ...`
4. Backend chạy tại: **http://localhost:8080**

---

## 5. Chạy Frontend trong Cursor

1. Mở **terminal mới** (dấu + trong panel Terminal hoặc Ctrl+Shift+`).
2. Chạy:
   ```powershell
   cd supermarket_Manager_System
   flutter pub get
   flutter run -d chrome
   ```
   Hoặc:
   - `flutter run -d windows` — chạy app Windows
   - `flutter run -d edge` — chạy trên Edge
3. App Flutter sẽ gọi API tại `http://localhost:8080` (xem `lib/utils/api_constants.dart`).

---

## 6. Chạy cả hai cùng lúc (gợi ý)

- **Cách 1:** Mở 2 terminal trong Cursor:
  - Terminal 1: `cd supermarket\supermarket` → `mvn spring-boot:run`
  - Terminal 2: `cd supermarket_Manager_System` → `flutter run -d chrome`
- **Cách 2:** Dùng **Run and Debug** (Ctrl+Shift+D): chọn cấu hình "Backend" hoặc "Flutter Web" (nếu đã thêm trong `.vscode/launch.json`).

---

## 7. Lưu ý

- **CORS:** Backend đã bật CORS cho `*` (trong `SecurityConfig`), nên Flutter web chạy trên localhost không bị chặn.
- **API base URL:** Flutter đang dùng `http://localhost:8080`. Chạy trên **Android emulator** thì đổi trong `api_constants.dart` thành `http://10.0.2.2:8080`.
- **MySQL port:** Nếu MySQL của bạn chạy port **3306**, sửa trong `supermarket/supermarket/src/main/resources/application.properties`: đổi `3307` → `3306`.

Sau khi cài đủ Java 21, Maven, MySQL (3307), Flutter và 2 extension trên, bạn có thể chạy cả frontend và backend trực tiếp trong Cursor.
