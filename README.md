# Hướng dẫn: OpenCode + 9Router trên VPS

## Mục đích

Dùng OpenCode trên VPS (AWS), laptop yếu vẫn chạy mượt.
Tự động chuyển đổi AI providers qua 9Router, không lo hết quota.

---

## 1. Những thứ cần có

- Tài khoản AWS (đã tạo Lightsail VPS)
- File `.pem` key từ AWS
- Laptop có VSCode

---

## 2. Các bước làm (từ VPS mới tinh)

### Cách nhanh nhất: 1 lệnh

```bash
curl -fsSL https://raw.githubusercontent.com/mmailduyt-cpu/opencode-stack/master/setup.sh | bash
```

Chạy xong, mở browser `http://VPS-IP:20128` → copy API key → `opencode -m 9r/mmf/mimo-auto`

### Cách chi tiết:

### Bước 1: Tạo VPS trên AWS Lightsail

1. Vào https://lightsail.aws.amazon.com
2. Click **Create instance**
3. Chọn: Ubuntu 22.04, 2GB RAM ($10/tháng)
4. Click **Create**, đợi 2 phút
5. Vào instance → tab Account → SSH keys → **Download .pem**
6. Lưu file `.pem` vào `C:\Users\Admin\Downloads\`

### Bước 2: Fix quyền file .pem

Mở **PowerShell** trên laptop, chạy 1 dòng:

```powershell
icacls "C:\Users\Admin\Downloads\*.pem" /reset; icacls "C:\Users\Admin\Downloads\*.pem" /inheritance:r; icacls "C:\Users\Admin\Downloads\*.pem" /grant "${env:USERNAME}:R"
```

### Bước 3: Kết nối VSCode đến VPS

1. Mở VSCode → Ctrl+Shift+X → Gõ **Remote - SSH** → Cài
2. Ctrl+Shift+P → Gõ **Remote-SSH: Open Configuration File**
3. Chọn file `C:\Users\Admin\.ssh\config`
4. Thêm nội dung:

```
Host aws-vps
    HostName [IP_VPS_CUA_BAN]
    User ubuntu
    IdentityFile C:/Users/Admin/Downloads/[TEN_FILE_PEM].pem
```

5. Lưu file
6. Ctrl+Shift+P → **Remote-SSH: Connect to Host** → Chọn `aws-vps` → Chọn Linux

### Bước 4: Chạy script cài đặt (QUAN TRỌNG)

Giờ bạn đang ở trong VSCode, terminal đang chạy trên VPS (thấy `ubuntu@ip-...:~$`).

Chạy 1 lệnh này trong terminal VSCode:

```bash
curl -fsSL https://raw.githubusercontent.com/mmailduyt-cpu/opencode-stack/master/setup.sh | bash
```

**Lệnh này tự động:**
- Cài Docker
- Chạy 9Router (cổng 20128)
- Cài OpenCode
- Cấu hình OpenCode kết nối 9Router
- Thêm PATH

### Bước 5: Cấu hình 9Router

1. Mở browser trên laptop → vào `http://[IP_VPS]:20128`
2. Dashboard 9Router hiện ra
3. Vào **Providers** → Thêm API keys (OpenAI, Gemini, v.v.)
4. Vào tab **Endpoint** → Copy **API Key** (dạng `sk-xxxx...`)

Nếu script chưa tự lấy được API key, chạy tiếp:

```bash
nano ~/.local/share/opencode/auth.json
```

Sửa `"GET_FROM_DASHBOARD"` thành API key thật, lưu (Ctrl+X, Y, Enter).

### Bước 6: Dùng OpenCode

Trong VSCode terminal (đang SSH vào VPS), gõ:

```bash
opencode -m 9r/mmf/mimo-auto
```

Giao diện chat hiện ra. Gõ tin nhắn, Enter để gửi.
Thoát: nhấn `Esc` hoặc `Ctrl+C`.

---

## 3. Cách dùng hằng ngày

### Mỗi lần muốn dùng:

1. Mở VSCode → Ctrl+Shift+P → **Remote-SSH: Connect to Host** → Chọn `aws-vps`
2. Mở terminal (Ctrl+`)
3. Gõ:
```bash
opencode -m 9r/mmf/mimo-auto
```

### Muốn thêm model khác:

Vào `http://[IP_VPS]:20128` → Providers → Thêm API key mới
Rồi dùng tên model tương ứng trong OpenCode.

### Cập nhật 9Router:

```bash
cd ~/opencode-stack
sudo docker compose pull
sudo docker compose up -d
```

### Cập nhật OpenCode:

```bash
curl -fsSL https://opencode.ai/install | bash
```

---

## 4. Cấu trúc file trên VPS

```
/home/ubuntu/
├── setup.sh                      # Script cài đặt (tự xóa sau khi chạy)
├── opencode-stack/
│   └── docker-compose.yml        # Config Docker chạy 9Router
├── .opencode/bin/opencode        # OpenCode binary
├── .config/opencode/
│   └── opencode.jsonc            # Config OpenCode
└── .local/share/opencode/
    └── auth.json                 # API key 9Router
```

---

## 5. Lỗi thường gặp

**"opencode: command not found"**
```bash
source ~/.bashrc
# hoặc dùng đường dẫn đầy đủ:
~/.opencode/bin/opencode
```

**"Cannot connect to API"**
- Kiểm tra 9Router đang chạy: `sudo docker ps`
- Vào `http://[IP_VPS]:20128` xem dashboard có load không

**Không vào được web 9Router**
- Vào AWS Lightsail → Networking → Thêm rule TCP 20128 và 3000

---

## 6. Tổng kết

| Cái gì | Ở đâu |
|--------|-------|
| OpenCode | Gõ `opencode` trong VSCode terminal |
| 9Router dashboard | `http://[IP_VPS]:20128` |
| File cấu hình | `~/.config/opencode/` và `~/.local/share/opencode/` |
| Docker compose | `~/opencode-stack/docker-compose.yml` |
