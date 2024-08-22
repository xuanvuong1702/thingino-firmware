
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