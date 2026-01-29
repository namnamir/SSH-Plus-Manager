**Language / زبان:** [English](SSH-MULTIPORT.md) | [فارسی](SSH-MULTIPORT.fa.md)

<div dir="rtl">

# تنظیم چند پورت SSH (systemd + UFW)

**این تنظیم از قبل در SSH Plus Manager پیاده شده است.** اسکریپت OpenSSH، فعال‌سازی سوکت systemd و UFW را برای شما تنظیم می‌کند. از **menu** → **[08] CONNECTIONS** → **SSH Multi-Port Setup** استفاده کنید تا پورت اضافه/حذف کنید، تنظیم سریع چند پورت بزنید یا پیکربندی را بررسی کنید — لازم نیست دستی فایل edit کنید مگر ترجیح دهید.

این سند **نحوه کار** و روش انجام دستی در صورت نیاز را توضیح می‌دهد: **OpenSSH** روی **چند پورت** با **فعال‌سازی سوکت systemd** و **UFW** برای کنترل پورت‌های مجاز. با رفتار **تنظیم چند پورت SSH** داخل منو یکسان است.

روی Debian/Ubuntu مدرن با **ssh.socket** تست شده است.

کاربردها:

- SSH روی شبکه‌های محدودکننده (مثلاً ۴۴۳، ۸۰)
- پورت‌های جایگزین (مثلاً ۳۳۹۸، ۸۰۸۰، ۸۴۴۳)
- تونل یا مدیریت مبتنی بر SSH روی پورت‌های غیراستاندارد

---

## ۱. نصب SSH Plus Manager

SSH Plus Manager ابزار چند پورت را دارد. نصب:

<div dir="ltr">

```bash
# با curl:
bash <(curl -Ls https://raw.githubusercontent.com/namnamir/SSH-Plus-Manager/main/install.sh)

# یا با wget:
wget -qO- https://raw.githubusercontent.com/namnamir/SSH-Plus-Manager/main/install.sh | bash
```

</div>

بعد **menu** را بزنید و بروید **[08] CONNECTIONS** → **SSH Multi-Port Setup**.

> **مهم:** تنظیم چند پورت به **UFW** نیاز دارد. اگر UFW نصب نباشد، اسکریپت ادامه نمی‌دهد. نصب:  
> `apt install -y ufw`

---

## ۲. پورت‌های بازشده توسط نصب‌کننده و ابزار چند پورت

وقتی UFW هست، **نصب‌کننده** این‌ها را مجاز می‌کند:

- ۴۴۳، ۸۰، ۳۱۲۸ (Squid)، ۸۷۹۹، ۸۰۸۰

برای **چند پورت SSH** باید هر پورتی که SSH روی آن گوش می‌دهد در UFW مجاز باشد. مجموعه متداول:

<div dir="ltr">

```bash
ufw allow 22/tcp
ufw allow 443/tcp
ufw allow 80/tcp
ufw allow 8080/tcp
ufw allow 8443/tcp
ufw allow 993/tcp
ufw allow 995/tcp
ufw allow 3398/tcp
ufw allow 53/tcp
```

</div>

بارگذاری مجدد:

<div dir="ltr">

```bash
ufw reload
```

</div>

---

## ۳. تنظیم پورت‌های مجاز SSH (`sshd_config`)

فایل تنظیم SSH را ویرایش کنید:

<div dir="ltr">

```bash
nano /etc/ssh/sshd_config
```

</div>

**همه پورت‌های مورد نظر** را نزدیک بالای فایل (قبل از هر بلاک `Match`) اضافه کنید:

<div dir="ltr">

```conf
Port 22
Port 3398
Port 443
Port 80
Port 8080
Port 8443
Port 53
Port 993
Port 995
```

</div>

اعتبار تنظیمات را بررسی کنید:

<div dir="ltr">

```bash
sshd -t
```

</div>

بدون خروجی یعنی درست است.

---

## ۴. تنظیم فعال‌سازی سوکت systemd (`ssh.socket`)

با فعال‌سازی سوکت، **پورت‌ها باید در `ssh.socket` هم فهرست شوند**.

### ۴.۱ پوشه override

<div dir="ltr">

```bash
mkdir -p /etc/systemd/system/ssh.socket.d
```

</div>

### ۴.۲ فایل override سوکت

<div dir="ltr">

```bash
nano /etc/systemd/system/ssh.socket.d/override.conf
```

</div>

نمونه برای پورت‌های بالا:

<div dir="ltr">

```ini
[Socket]
ListenStream=
ListenStream=0.0.0.0:22
ListenStream=[::]:22

ListenStream=0.0.0.0:3398
ListenStream=[::]:3398

ListenStream=0.0.0.0:443
ListenStream=[::]:443

ListenStream=0.0.0.0:80
ListenStream=[::]:80

ListenStream=0.0.0.0:8080
ListenStream=[::]:8080

ListenStream=0.0.0.0:8443
ListenStream=[::]:8443

ListenStream=0.0.0.0:53
ListenStream=[::]:53

ListenStream=0.0.0.0:993
ListenStream=[::]:993

ListenStream=0.0.0.0:995
ListenStream=[::]:995
```

</div>

توضیح:

- خط خالی `ListenStream=` قبل از افزودن پورت‌های جدید، گوش‌دهندگان پیش‌فرض را پاک می‌کند.
- پورت تکراری نگذارید.
- هر دو IPv4 (`0.0.0.0`) و IPv6 (`[::]`) در صورت استفاده صریحاً گذاشته شده‌اند.

---

## ۵. بارگذاری مجدد systemd (اجباری)

بعد از تغییر سوکت (یا sshd_config):

<div dir="ltr">

```bash
systemctl daemon-reload
systemctl restart ssh.socket
```

</div>

اختیاری ولی توصیه‌شده:

<div dir="ltr">

```bash
systemctl restart ssh.service
```

</div>

---

## ۶. تنظیم UFW

در صورت نیاز UFW را روشن کنید:

<div dir="ltr">

```bash
ufw enable
```

</div>

پورت‌های SSH مورد استفاده را مجاز کنید، مثلاً:

<div dir="ltr">

```bash
ufw allow 22/tcp
ufw allow 3398/tcp
ufw allow 443/tcp
ufw allow 80/tcp
ufw allow 8080/tcp
ufw allow 8443/tcp
ufw allow 53/tcp
ufw allow 993/tcp
ufw allow 995/tcp
```

</div>

بررسی:

<div dir="ltr">

```bash
ufw status verbose
```

</div>

---

## ۷. بررسی

### پورت‌های در حال گوش دادن

<div dir="ltr">

```bash
ss -ltnp | grep ssh
```

</div>

همه پورت‌های انتخاب‌شده باید در حالت `LISTEN` باشند.

### وضعیت سوکت

<div dir="ltr">

```bash
systemctl status ssh.socket
```

</div>

باید چیزی شبیه این باشد:

<div dir="ltr">

```
Active: active (running)
```

</div>

### پورت‌های پذیرفته‌شده توسط sshd

<div dir="ltr">

```bash
sshd -T | grep '^port'
```

</div>

---

## ۸. نمونه اتصال از سمت کلاینت

<div dir="ltr">

```bash
ssh -p 22   user@SERVER_IP
ssh -p 3398 user@SERVER_IP
ssh -p 443  user@SERVER_IP
ssh -p 8080 user@SERVER_IP
```

</div>

---

## ۹. خطاهای رایج

### فراموش کردن `systemctl daemon-reload`

اگر دیدید:

```
Warning: unit file or drop-ins changed on disk
```

اجرا کنید:

```bash
systemctl daemon-reload
```

بعد `ssh.socket` (و در صورت تمایل `ssh.service`) را ریستارت کنید.

### ListenStream یا Port تکراری

پورت تکراری می‌تواند باعث شود:

<div dir="ltr">

```
Address already in use
```

</div>

هر پورت فقط یک بار در override سوکت و یک بار در `sshd_config` بیاید.

### اضافه کردن پورتی که از قبل در تنظیمات است

اسکریپت چند پورت پورت‌های موجود در `sshd_config` را نادیده می‌گیرد. اگر همان پورت را دوباره دستی اضافه کنید ممکن است «Address already in use» یا تنظیمات نامعتبر بگیرید. همیشه فقط یک خط به ازای هر پورت بگذارید.

### ویرایش مستقیم `/usr/lib/systemd/system/ssh.socket`

فایل سیستمی را مستقیم edit نکنید. فقط از drop-in استفاده کنید:

`/etc/systemd/system/ssh.socket.d/override.conf`

### مجاز نبودن پورت جدید در UFW

بعد از اضافه کردن پورت در sshd و systemd، آن را در UFW مجاز کنید:

<div dir="ltr">

```bash
ufw allow PORT/tcp
ufw reload
```

</div>

---

## ۱۰. پیشنهادهای امنیتی

نمونه سخت‌گیری در `sshd_config`:

<div dir="ltr">

```conf
PermitRootLogin prohibit-password
PasswordAuthentication no
PubkeyAuthentication yes
MaxAuthTries 3
LoginGraceTime 20
```

</div>

بعد:

<div dir="ltr">

```bash
systemctl restart ssh.service
```

</div>

(یا از منو **[15] RESTART SERVICES** استفاده کنید.)

---

## ۱۱. ارتباط سه لایه با هم

| بخش | نقش |
|-----|-----|
| `sshd_config` | تعیین پورت‌هایی که SSH روی آن‌ها اتصال می‌پذیرد |
| `ssh.socket` | تعیین پورت‌هایی که واقعاً توسط systemd باز می‌شوند |
| UFW | تعیین پورت‌های عبوری از فایروال |

**هر سه باید با هم جور باشند.** اگر پورتی در `sshd_config` باشد ولی در سوکت نباشد، گوش داده نمی‌شود. اگر گوش دهد ولی UFW مسدود کند، کلاینت وصل نمی‌شود.

---

## ۱۲. استفاده از منو به‌جای کار دستی

همین کارها از داخل مدیر ممکن است:

1. **menu** را اجرا کنید.
2. **[08] CONNECTIONS** را بزنید.
3. **SSH Multi-Port Setup** (یا گزینه‌ای که اسکریپت multiport را اجرا می‌کند) را باز کنید.
4. استفاده کنید از:
   - **Add port** — افزودن یک پورت (sshd + سوکت + UFW).
   - **Remove port** — حذف یک پورت از تنظیمات و UFW.
   - **Setup multiple ports (quick)** — لیست جدا شده با کاما (مثلاً `22, 3398, 443, 80, 8080`)؛ اسکریپت فاصله‌ها را حذف می‌کند و فقط پورت‌های هنوز نبوده در config را اضافه می‌کند.
   - **Verify setup** — بررسی پورت‌های در حال گوش دادن و تنظیمات.

اسکریپت فرض می‌کند **UFW** نصب است؛ اگر UFW نباشد ادامه نمی‌دهد تا پورت‌ها بدون محافظ نمانند.

برای رفع مشکلات بیشتر (مثلاً «Configuration validation failed»، از دست دادن دسترسی) ببینید [TROUBLESHOOTING.fa.md](TROUBLESHOOTING.fa.md).

</div>
