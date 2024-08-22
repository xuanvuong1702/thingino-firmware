
# Home

### Giới thiệu

Thingino là một firmware mã nguồn mở cho camera IP được xây dựng trên SoC Ingenic.
Đây là một dự án độc lập với tầm nhìn và phương pháp tiếp cận tuân thủ lý tưởng mã nguồn mở.

Thingino không cố gắng xây dựng một tệp firmware phổ quát có thể được sử dụng trên nhiều mô hình camera.
Thay vào đó, chúng tôi xây dựng một firmware được tùy chỉnh đẹp cho phần cứng mục tiêu, với tối thiểu overhead.

Thingino mới nhưng phát triển nhanh. Bạn nên mong đợi cập nhật thường xuyên, các tính năng mới hấp dẫn, và thay đổi đột ngột từ thời gian đến thời gian.

Thingino sử dụng một phiên bản tùy chỉnh của [prudynt][1] như một streamer đi đến trong khi làm việc trên giải pháp modular hoàn toàn mở của riêng mình - [Raptor][2].

Để biết thêm chi tiết về triết lý dự án của chúng tôi, vui lòng xem trang [Triết lý Dự án](https://github.com/themactep/thingino-firmware/wiki/Project-Philosophy).

Hãy tham gia [kênh Telegram][3] và [máy chủ Discord][4] của chúng tôi để trò chuyện trực tiếp với các nhà phát triển và người dùng của firmware.

Người dùng mới có thể bắt đầu bằng cách truy cập vào mục [[Bắt đầu|getting-started]].

[1]: https://github.com/gtxaspec/prudynt-t
[2]: https://github.com/gtxaspec/raptor
[3]: https://t.me/thingino
[4]: https://discord.gg/gFc9jR2eXV  

# Tự động hóa

Thingino có các tính năng giúp dễ dàng nâng cấp và cấu hình camera chỉ bằng cách sử dụng thẻ SD.

### Nâng cấp từ hình ảnh nhị phân trên thẻ SD

Trình khởi động Thingino có thể flash firmware mới từ thẻ SD trong quá trình khởi động.
Sao chép phiên bản mới của firmware vào thư mục gốc của thẻ SD, đổi tên tệp firmware thành `autoupdate-full.bin`,
và khởi động lại camera với thẻ đã chèn vào. Hình ảnh sẽ được nhận biết khi khởi động và được flash thay vì phiên bản hiện tại.
Sau khi flash thành công, một tệp dừng có tên `autoupdate-full.done` sẽ được tạo trên thẻ để ngăn chặn việc flash lại liên tục.
Nếu bạn muốn flash lại camera khác bằng cùng một thẻ, hãy xóa tệp dừng này trước.

Bạn cũng có thể cập nhật chỉ trình khởi động. Thủ tục vẫn giữ nguyên, nhưng đổi tên hình ảnh trình khởi động thành `autoupdate-uboot.bin`.

### Sử dụng tệp trên thẻ SD để thay đổi môi trường U-Boot

Cung cấp và cập nhật môi trường trình khởi động có thể được thực hiện bằng cách sử dụng tệp `uEnv.txt` trong thư mục gốc của thẻ SD.
Tạo một tệp như vậy theo định dạng sau:

```
parameter1=value
parameter2=multiword value
parameter3='complex value using %{variable} data'
```
Chèn thẻ và khởi động lại camera. Giá trị mới sẽ được nhập vào môi trường trình khởi động, thêm vào hoặc ghi đè các tham số hiện có trong đó.

### Chạy script từ thẻ SD

Thingino nhận biết hai tên script shell trên thẻ SD được thực thi khi khởi động:

- `run.sh` sẽ được thực thi mỗi khi hệ thống khởi động, miễn là nó được tìm thấy trên thẻ.
- `runonce.sh` được thực thi lần đầu tiên nó được tìm thấy, sau đó một tệp dừng `runonce.done` được tạo để ngăn chặn các thực thi liên tục. Xóa tệp dừng này nếu bạn cần chạy lại script `runonce.sh`.

# Xây dựng từ mã nguồn

## Yêu cầu trước

Để biên dịch thành công firmware, bạn cần một bản phân phối Linux hiện đại được trang bị các thư viện hệ thống và công cụ cập nhật. Cụ thể:

> [!QUAN TRỌNG]  
> Việc xây dựng hiện chỉ được hỗ trợ trên các nền tảng **x86_64**. Cố gắng xây dựng trên máy chủ RISC-V hoặc ARM64 sẽ dẫn đến thất bại.

- **Phân phối yêu cầu**: Phiên bản gần đây của Debian hoặc Ubuntu, được khuyến nghị.
- **Thư viện và công cụ thiết yếu**:
  - **glibc 2.31 hoặc mới hơn**: Đảm bảo thư viện C của hệ thống bạn được cập nhật để tránh vấn đề tương thích.
  - **GNU awk**: Cần thiết để xử lý các script trong quá trình xây dựng.

Nếu bạn đang sử dụng hệ điều hành cũ hơn hoặc không muốn cài đặt các gói bổ sung trên hệ thống hiện tại của mình, hãy xem xét sử dụng các container **Podman**, **Docker** hoặc **LXC**. Những cái này cung cấp một môi trường sạch và tách biệt, lý tưởng để đảm bảo tương thích và khả năng tái tạo quá trình xây dựng.

Để biết hướng dẫn chi tiết về cách thiết lập và sử dụng các container để biên dịch firmware, hãy truy cập [Trang Phát triển Container](https://github.com/themactep/thingino-firmware/wiki/Development#containers) của chúng tôi.

## Tải xuống kho lưu trữ

### Bước 1: Sao chép Kho lưu trữ

Bắt đầu bằng cách sao chép kho lưu trữ firmware Thingino vào máy của bạn. Mở một terminal và chạy lệnh sau:

```bash
git clone --depth=1 --recurse-submodules \
--shallow-submodules https://github.com/themactep/thingino-firmware
```

### Bước 2: Điều hướng đến Thư mục Firmware

Chuyển vào thư mục đã sao chép:

```bash
cd thingino-firmware
```

## Hướng dẫn Biên dịch

### Bước 1:Mở Menu Cấu hình

Chạy script cấu hình người dùng:

```bash
./user-menu.sh
```
Khi chạy script, bạn sẽ thấy menu chính:

![image](https://github.com/themactep/thingino-firmware/assets/12115272/ec95798b-2b1c-44c7-b0fe-d27f5809a7c9)

Chọn **"Biên dịch theo hướng dẫn"** từ menu.

![image](https://github.com/themactep/thingino-firmware/assets/12115272/98997b30-847b-4b4d-89ce-a3682aec636b)

### Bước 2: Chọn Hồ sơ Thiết bị của bạn

1. **Chọn Thiết bị**: Chọn một hồ sơ thiết bị từ danh sách. Bạn có thể chọn **Hồ sơ Camera** hoặc **Hồ sơ Module**:
   - **Hồ sơ Camera**: Bao gồm tất cả các cấu hình cần thiết cho thiết bị, như GPIOs.
   - **Hồ sơ Module**: Cấu hình cơ bản phù hợp cho các nhà phát triển có kinh nghiệm.

![image](https://github.com/themactep/thingino-firmware/assets/12115272/d1fb2108-b001-4fea-a754-f88f767d2351)

Nhấp **OK** để xác nhận lựa chọn của bạn.

### Bước 3: Cài đặt Yêu cầu trước

Chọn **"Cài đặt yêu cầu trước"** từ menu để cài đặt các thành phần cần thiết cho quá trình biên dịch.

![image](https://github.com/themactep/thingino-firmware/assets/12115272/d04e3196-c33f-404a-b7e2-217473486585)

### Bước 4: Biên dịch Firmware

Chọn **"Bước 3: Tạo Firmware"** để bắt đầu quá trình biên dịch.

![image](https://github.com/themactep/thingino-firmware/assets/12115272/542d8b95-b18f-43db-b4ec-b458a60b19d8)

Hãy đợi trong khi firmware được biên dịch; điều này có thể mất một thời gian. Bước này cũng tạo ra các hình ảnh cần thiết để flash firmware lên thiết bị của bạn.

### Bước 5: Lấy Firmware đã Biên dịch

![image](https://github.com/themactep/thingino-firmware/assets/12115272/be4a8911-9dfc-4659-9a1a-60bc985f4f30)

Khi hoàn thành, một thông báo sẽ cho biết quá trình đã hoàn tất. Bạn có thể tìm thấy các hình ảnh firmware trong thư mục home của bạn dưới:

```
HOME FOLDER/output/<profile_name>/images
```
Ví dụ:
- `thingino-teacup.bin` – Hình ảnh đầy đủ này bao gồm bootloader và được sử dụng cho các cài đặt mới.
- `thingino-teacup-update.bin` – Hình ảnh này không bao gồm bootloader và phù hợp để cập nhật thiết bị của bạn mà không xóa bootloader hoặc các biến môi trường.

### Kết luận

Chúc mừng! Bạn đã thành công biên dịch và chuẩn bị firmware Thingino để cài đặt. Theo các bước trên để biên dịch lại hoặc cập nhật firmware khi cần.
## Biên dịch Thủ công

- Chạy `make` và chọn một hồ sơ thiết bị.
- Khi hoàn thành, một thông báo sẽ cho biết quá trình đã hoàn tất. Bạn có thể tìm thấy các hình ảnh firmware trong thư mục home của bạn dưới:
```
HOME FOLDER/output/<profile_name>/images
```

Ví dụ:
- `thingino-teacup.bin` – Hình ảnh đầy đủ này bao gồm bootloader và được sử dụng cho các cài đặt mới.
- `thingino-teacup-update.bin` – Hình ảnh này không bao gồm bootloader và phù hợp để cập nhật thiết bị của bạn mà không xóa bootloader hoặc các biến môi trường.


# Buildroot

Chúng tôi sử dụng phiên bản mới nhất có sẵn của [Buildroot][1] với [một số chỉnh sửa nhỏ][2] cho phép chúng tôi tạo ra một môi trường xây dựng hoàn toàn di động.

## Camera, Module và Fragment

Phần cứng camera chủ yếu dựa trên mô hình SoC, cảm biến hình ảnh, và đôi khi là một module không dây. Các camera khác nhau có thể sử dụng cùng một SoC, cảm biến, và module Wi-Fi, do đó yêu cầu firmware được xây dựng tương tự, nhưng vẫn có bản đồ GPIO khác nhau và cấu hình phụ trợ. Để tránh lặp lại các cài đặt trong cấu hình, chúng tôi đã tách cấu hình cụ thể cho camera ra khỏi cấu hình phần cứng cơ bản (chúng tôi gọi chúng là module). Chúng tôi chỉ nói với cấu hình camera được lưu trữ trong `config/cameras/` module phần cứng nào được lưu trữ trong `config/modules/` để sử dụng:


```
# MODULE: t31x_gc2053_rtl8189ftv
```
Sau đó, trong tệp cấu hình module, chúng tôi đã cấu hình tất cả mọi thứ cho Triade: SoC, cảm biến và module Wi-Fi, nếu có.

Nhưng những cấu hình phần cứng này có rất nhiều thông tin chung, lặp đi lặp lại liên quan đến kiến trúc bộ xử lý và firmware nói chung. Chúng tôi sử dụng các đoạn cấu hình, được lưu trữ trong các tệp `config/fragments/*.fragment`, để tránh lặp lại các cài đặt này. Bạn có thể thấy cách những đoạn này được bao gồm trong cấu hình module:


```
# FRAG: soc toolchain ccache brand rootfs kernel system target
```

Khi `make` được chạy, cấu hình cuối cùng cho một camera được lắp ráp từ các phần và được lưu dưới dạng tệp `~/output/<camera_config_name>/.config`. Sau đó, nó chạy `make olddefconfig`, phân tích tệp, giải quyết bất kỳ xung đột và dư thừa nào, và tạo ra một tệp `.config` mới hoàn toàn, lưu phiên bản trước đó dưới dạng `.config.old`, được ghi đè bằng bất kỳ thay đổi mới nào, vì vậy chúng tôi cũng lưu phiên bản ban đầu của tệp `.config` dưới dạng `.config_original` để dễ dàng gỡ lỗi hơn.

Để tạo lại tệp `.config` từ tệp cấu hình camera gốc và các tệp bao gồm của nó, chạy `make defconfig`.

## local.fragment và local.mk

Chúng tôi cung cấp một tệp cho các thay đổi cục bộ đối với cấu hình chia sẻ. Tệp `config/fragments/local.fragment` có thể chứa các cài đặt nên được bao gồm trong cấu hình chung trên máy của nhà phát triển, nhưng không đi vào kho lưu trữ upstream. Bạn có thể thêm các gói bổ sung vào đó hoặc ghi đè các cài đặt mặc định:

```
BR2_PACKAGE_NANO=y
BR2_PACKAGE_SCREEN=y
BR2_REPRODUCIBLE=n
```

Tệp `local.mk` được đặt ở gốc của thư mục firmware là một tính năng tiêu chuẩn của Buildroot cho phép bạn ghi đè nguồn gói, bao gồm cả từ chính Buildroot. Đây là một tính năng vô giá cho phát triển cục bộ. Đọc thêm về điều này trong chương 8.13.6 của <https://buildroot.org/downloads/manual/manual.html>.

```
LINUX_OVERRIDE_SRCDIR=$(HOME)/dev/thingino/linux
LINUX_HEADERS_OVERRIDE_SRCDIR=$(HOME)/dev/thingino/linux
INGENIC_SDK_OVERRIDE_SRCDIR=$(HOME)/dev/thingino/ingenic-sdk
PRUDYNT_T_OVERRIDE_SRCDIR=$(HOME)/dev/thingino/prudynt-t
```

[1]: https://buildroot.org/
[2]: https://github.com/buildroot/buildroot/compare/master...themactep:buildroot:master
# Cấu hình Camera

Để khởi động camera, bạn cần thiết lập ban đầu môi trường bootloader. Hầu hết các hình ảnh firmware của camera đã có các cài đặt môi trường trong đó, và bạn chỉ cần cung cấp thông tin xác thực mạng không dây của mình để kết nối camera với mạng. Tuy nhiên, nếu bạn đang xây dựng firmware cho một camera mới, hoặc nếu bạn đang sử dụng firmware module, bạn sẽ cần cung cấp tệp môi trường.

### Địa chỉ MAC của Mạng

Khi hệ thống được cài đặt, nó tạo và gán địa chỉ MAC cho các biến môi trường `ethaddr` và `wlanmac`. Các địa chỉ MAC này dựa trên số serial của SoC (System on Chip). Chúng là duy nhất cho thiết bị của bạn. Nếu số serial không khả dụng, địa chỉ MAC ngẫu nhiên sẽ được tạo ra.

Bạn có thể thay đổi hoặc xóa các biến này nếu cần. Điều quan trọng cần lưu ý là một số module WiFi có thể không cung cấp địa chỉ MAC nhất quán mà không có các giá trị được tạo ra này.

### Cấu hình thông qua điểm truy cập của camera

Nếu camera của bạn chưa có thông tin xác thực mạng không dây, nó sẽ khởi động một điểm truy cập với một cổng thông tin được tích hợp cho phép bạn kết nối trực tiếp với camera và nhập thông tin xác thực để kết nối với mạng không dây của bạn. Cổng thông tin chỉ hoạt động trong 5 phút, sau đó nó sẽ tắt vì lý do bảo mật và bạn sẽ cần khởi động lại camera để khởi động lại nó.

Để truy cập cổng thông tin, bật camera và quét các mạng không dây có sẵn để tìm một SSID có tên THINGINO-XXXX, nơi XXXX là một phần duy nhất của địa chỉ MAC của camera. Kết nối với mạng này (nó mở, vì vậy bạn không cần thông tin xác thực) và điều hướng đến _http://thingino.local/_ hoặc _http://172.16.0.1/_ trên trình duyệt web của bạn. Trên trang, nhập SSID và mật khẩu mạng không dây của bạn để truy cập mạng và nhấp vào nút _Save Credentials_. Camera sẽ khởi động lại và cố gắng kết nối với mạng không dây của bạn bằng thông tin xác thực đã cung cấp.

### Cấu hình với thẻ SD

Tìm mô hình camera của bạn trong thư mục [/environment/][envdir], sao chép tệp cấu hình của nó và lưu lại dưới dạng `uEnv.txt`.
Thay thế giá trị `wlanssid` và `wlanpass` bằng thông tin xác thực mạng không dây của bạn.
Sao chép tệp vào thẻ SD, chèn thẻ vào camera của bạn và khởi động lại.

### Giải thích môi trường bootloader

#### Cài đặt phần cứng

- `gpio_default` - Danh sách các trạng thái GPIO mặc định khi khởi động. Mỗi vị trí bao gồm số GPIO theo sau là trạng thái mong muốn:
  - `O` - Output, High
  - `o` - Output, Low
  - `i` hoặc `I` - Input
- `gpio_button` - Chân GPIO cho nút reset
- `gpio_led_r` - Chân GPIO cho đèn LED màu đỏ
- `gpio_led_g` - Chân GPIO cho đèn LED màu xanh lá
- `gpio_led_b` - Chân GPIO cho đèn LED màu xanh dương
- `gpio_led_y` - Chân GPIO cho đèn LED màu vàng
- `gpio_mmc_cd` - Chân GPIO để phát hiện thẻ MMC
- `gpio_mmc_power` - Chân GPIO để điều khiển nguồn cho MMC
- `gpio_usb_en` - Chân GPIO để điều khiển nguồn cho USB
- `gpio_speaker` - Chân GPIO để điều khiển nguồn cho loa

#### Chế độ ban đêm

- `day_night_min` - Giá trị gain để chuyển sang chế độ ban ngày
- `day_night_max` - Giá trị gain để chuyển sang chế độ ban đêm
- `gpio_ircut` - Chân GPIO cho trình điều khiển IRCUT, có thể là một hoặc hai chân, tùy thuộc vào loại ổ đĩa
- `gpio_ir850` - Chân GPIO cho đèn LED hồng ngoại 850nm
- `gpio_ir940` - Chân GPIO cho đèn LED hồng ngoại 940nm
- `gpio_white` - Chân GPIO cho đèn LED ánh sáng trắng
- `pwm_ch_ir850` - Kênh PWM của đèn LED hồng ngoại 850nm
- `pwm_ch_ir940` - Kênh PWM của đèn LED hồng ngoại 940nm
- `pwm_ch_white` - Kênh PWM của đèn LED ánh sáng trắng

#### Động cơ xoay và nghiêng

- `gpio_motor_en` - Chân GPIO để kích hoạt bộ điều khiển động cơ
- `gpio_motor_h` - Chân GPIO cho động cơ xoay ngang (pan)
- `gpio_motor_v` - Chân GPIO cho động cơ di chuyển dọc (tilt)
- `motor_maxstep_h` - Số lượng microsteps tối đa cho động cơ xoay
- `motor_maxstep_v` - Số lượng microsteps tối đa cho động cơ nghiêng
- `disable_homing` - Đặt thành `true` để vô hiệu hóa việc đưa động cơ về vị trí ban đầu khi khởi động

#### Mạng không dây

- `gpio_wlan` - Chân GPIO để điều khiển nguồn cho thẻ không dây
- `wlanbus` - Loại bus thẻ không dây, có thể là `usb` hoặc `sdio`
- `wlandev` - Trình điều khiển thẻ không dây
- `wlandevopts` - Đối số để truyền cho trình điều khiển không dây
- `wlanssid` - Tên mạng không dây
- `wlanpass` - Mật khẩu mạng không dây

#### Mạng Ethernet

- `ethaddr` - Địa chỉ MAC cho giao diện Ethernet
- `disable_eth` - Vô hiệu hóa mạng Ethernet để khởi động nhanh hơn trên các camera chỉ dùng Wi-Fi

#### Linh tinh

- `disable_streamer` - Vô hiệu hóa trình phát video
- `disable_watchdog` - Vô hiệu hóa hệ thống watchdog
- `enable_updates` - Kích hoạt các phân vùng ảo được sử dụng cho nâng cấp firmware
- `hostname` - Tên máy chủ để sử dụng khi kết nối với mạng
- `timezone` - Múi giờ, được thiết lập từ giao diện người dùng web nên bạn không cần chỉnh sửa trực tiếp
- `sshkey_ed25519` - Sao lưu của khóa ssh
- `devip` - Địa chỉ IP của máy trạm của nhà phát triển
- `debug` - Chế độ debug

## ĐÃ LỖI THỜI

### Cấu hình thông qua mạng không dây

Nếu camera của bạn không có khe cắm thẻ SD và Wi-Fi là cách duy nhất để truy cập vào nó, bạn có thể sử dụng thông tin xác thực mặc định đi kèm với firmware của chúng tôi. Tạo một mạng không dây với tên _thingino_ và mật khẩu _thingino_. Đảm bảo rằng nó có một máy chủ DHCP để gán địa chỉ IP cho các camera. Khởi động camera với firmware mới. Kiểm tra danh sách các máy khách DHCP trên máy chủ. Tìm máy khách có tên máy chủ _thingino-<soc>_ nơi _<soc>_ là mô hình SoC của camera. Kiểm tra địa chỉ IP đã gán và sử dụng nó để kết nối với camera qua ssh. Một khi đã vào shell, đặt thông tin xác thực mạng không dây thực sự của bạn bằng cách sử dụng các lệnh sau:
```
fw_setenv wlanssid <ssid>
fw_setenv wlanpass <password>
reboot
```


[envdir]: https://github.com/themactep/thingino-firmware/tree/master/environment

# Cấu hình truy cập Wi-Fi

## Cổng thông tin chặn (Captive Portal)

Sau khi flash một hình ảnh firmware Thingino mới trên một camera hỗ trợ có mô-đun không dây, camera sẽ không có bất kỳ thông tin nào về mạng không dây của bạn và sẽ không thể tự động kết nối với nó.

> [!LƯU Ý]
> Các thiết bị giao diện kép (những cái có cả ethernet __và__ Wi-Fi) sẽ không phát sóng một điểm truy cập. Thay vào đó, kết nối với IP hoặc tên máy chủ để bắt đầu thiết lập.

Bạn có thể cung cấp [thông tin xác thực mạng không dây trên một thẻ SD](https://github.com/themactep/thingino-firmware/wiki/Configuring-Wi%E2%80%90Fi-Access#wireless-credentials-on-an-sd-card) hoặc sử dụng cổng thông tin đa năng được tích hợp của chúng tôi.

Sau khi bạn bật camera mà không có thông tin xác thực mạng, nó sẽ thiết lập một điểm truy cập tạm thời và tạo một mạng công cộng có tên là THINGINO-XXXX, nơi XXXX là bốn ký tự cuối cùng của địa chỉ MAC của camera.

Kết nối với mạng này, sử dụng một thiết bị di động (điện thoại thông minh hoặc máy tính bảng) hoặc từ một PC, và điều hướng trình duyệt của bạn đến http://thingino.local/. Bạn nên thấy biểu mẫu để nhập các cài đặt ban đầu cho camera:

![portal1](https://github.com/user-attachments/assets/d0bcd753-c2e5-4694-8db8-bc086dfdc672)

Điền vào biểu mẫu với thông tin hiện tại và nhấp vào nút "Lưu thông tin xác thực" ở dưới cùng.

![portal2](https://github.com/user-attachments/assets/8ac87448-702e-4eb1-9ecc-08d62179bfa4)

Trên trang tiếp theo, xem lại thông tin và sửa nếu bạn tìm thấy lỗi. Nếu không, nhấp vào nút "Tiếp tục với việc khởi động lại".

![portal3](https://github.com/user-attachments/assets/15d0b12a-679d-45d2-a7d3-c71db9a159ab)

Camera sẽ khởi động lại và đăng ký với mạng không dây của bạn bằng thông tin đã cung cấp.

![portal4](https://github.com/user-attachments/assets/70dbeca8-f2e3-4c55-af06-d82148c61adf)

Kiểm tra các thuê DHCP trên router của bạn để tìm địa chỉ IP được gán cho camera.

### Thông tin xác thực không dây trên một thẻ SD

Tạo một tệp `uenv.txt` trên một thẻ SD được định dạng FAT trống với nội dung sau

```
wlanssid=nameofyournetwork
wlanpass=yourwirelessnetworkpass
```

Khởi động lại camera với thẻ đã được chèn vào. Thông tin được cung cấp sẽ được thêm vào môi trường và sử dụng lại để đăng nhập vào mạng không dây.

# Xác định Phần cứng

Để cài đặt bản dựng firmware phù hợp, bạn cần xác định các thành phần phần cứng được sử dụng trong camera của bạn.
Dưới đây là một bo mạch camera IP điển hình. Cụ thể này là Wyze Cam V3.

![image](https://github.com/themactep/thingino-firmware/assets/37488/ccf35cd3-4b4d-45a7-8e2c-ac386fc88b0e)

### SoC

![image](https://github.com/themactep/thingino-firmware/assets/37488/c90d3fe1-f5bd-4d6e-9f7d-c09ef565f4a5)

SoC Ingenic thường là chip lớn nhất trên bo mạch, hình vuông và màu đen.

Các chip Ingenic thường có nhãn rất rõ ràng xác định duy nhất mô hình SoC.

Gia đình SoC được viết bằng kiểu chữ lớn hơn ngay dưới logo Ingenic: T10, T20, T21, T23, T30, T31, v.v.

Dòng dưới chủ yếu là số, nhưng cũng bao gồm mã chữ cho mô hình: L, LC, N, X, ZX, A, v.v.

### Bộ nhớ Flash

![image](https://github.com/themactep/thingino-firmware/assets/37488/d67a37c2-949a-450c-8201-1ab34798bcd8)

Bộ nhớ flash được sử dụng trên camera có thể là loại NOR, được hỗ trợ tốt bởi thingino,
hoặc loại NAND, với hỗ trợ sơ bộ rất thử nghiệm.

Các chip NOR thường hoàn toàn vuông vắn, với tám chân rõ ràng, bốn ở mỗi bên đối diện.

Chân số một được biểu thị bằng một ổ khắc hoặc khắc.

Các chip NOR được sử dụng trong camera IP là loại EEPROM 25 và có `25` trong tên mô hình của chúng: `W25Q64`, `MX25L128`, v.v.

Số `64` và `128` chỉ kích thước của chip tính bằng megabit, được chuyển đổi thành megabyte bằng cách chia cho tám: 64/8 = 8 megabyte, 128/8 = 16 megabyte.

### UART

![image](https://github.com/themactep/thingino-firmware/assets/37488/05b6d4a3-7002-41bf-b421-420cf7a7c6e5)

[UART](https://vi.wikipedia.org/wiki/Universal_asynchronous_receiver/transmitter) là một kết nối nối tiếp trực tiếp đến trái tim của camera - SoC của nó.

Việc tìm các liên hệ UART và thiết lập một kết nối nối tiếp đến camera là quan trọng cho bất kỳ công việc nghiêm túc nào với phần cứng, và đặc biệt là cho phát triển firmware.

Thường thì UART có ba liên hệ được gắn nhãn G (GND), T (TX), R (RX). Đôi khi có một liên hệ khác được đánh dấu V (VCC), nhưng chúng tôi không sử dụng nó trong các hoạt động của mình. Camera nên được cung cấp điện thông qua giao diện thông thường của nó, cung cấp bảo vệ chống quá áp.

### Mô-đun Wi-Fi

![image](https://github.com/themactep/thingino-firmware/assets/37488/33f838d8-b4f1-4a5d-9bef-c02ffa2f2853)

... sẽ tiếp tục