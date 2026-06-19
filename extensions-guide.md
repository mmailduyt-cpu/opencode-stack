# Hướng dẫn dùng VSCode extensions

## 1. AWS Toolkit

**Mục đích:** Bật/tắt VPS, xem trạng thái, logs mà không cần vào browser.

### Cách dùng:
- Click icon **AWS** ở thanh trái (⏃)
- Chọn **Explorer** → **Lightsail**
- Nếu chưa đăng nhập: Click **Create AWS Connection** → nhập Access Key
- Sau đó click phải vào VPS → **Start** / **Stop** / **Reboot**

Hoặc nhanh hơn: Ctrl+Shift+P → gõ `AWS:` → chọn lệnh

---

## 2. Docker

**Mục đích:** Xem 9Router đang chạy, restart, xem logs không cần gõ lệnh.

### Cách dùng:
- Click icon **Docker** ở thanh trái (🐳)
- Mục **Containers** → thấy `9router`
- Click phải vào `9router`:
  - **View Logs** → Xem logs realtime
  - **Restart** → Restart 9Router
  - **Stop** / **Start** → Tắt/bật

---

## 3. Thunder Client

**Mục đích:** Test API 9Router trực tiếp trong VSCode.

### Cách dùng:
- Click icon **Thunder Client** ở thanh trái (⚡)
- Click **New Request**
- Nhập:
  - **Method:** POST
  - **URL:** `http://54.169.102.155:20128/v1/chat/completions`
  - **Headers:**
    - `Content-Type: application/json`
    - `Authorization: Bearer sk-28d7e6aedbdc26a7-3wh26t-7183cd90`
  - **Body:**
    ```json
    {
      "model": "mmf/mimo-auto",
      "messages": [{"role": "user", "content": "hello"}]
    }
    ```
- Click **Send** → Xem response

---

## 4. GitHub Pull Requests

**Mục đích:** Xem code trên GitHub ngay trong VSCode.

### Cách dùng:
- Click icon **GitHub** ở thanh trái (🔄)
- Đăng nhập GitHub
- Xem được: Pull Requests, Issues, code

---

## 5. Remote - Tunnels

**Mục đích:** Khi gặp lỗi, người khác có thể kết nối vào VSCode của bạn để sửa.

### Cách dùng:
- Ctrl+Shift+P → gõ `Remote Tunnels: Sign in` → Đăng nhập GitHub
- Nó tạo 1 link, gửi link đó cho người hỗ trợ
- Người đó mở link trên browser → thấy toàn bộ VSCode của bạn
