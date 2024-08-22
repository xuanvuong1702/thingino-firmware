## Thingino. Firmware mã nguồn mở cho Camera IP SoC Ingenic.

![Giao diện web Thingino](https://thingino.com/a/webui-hawaii.jpg)

### Phần cứng được hỗ trợ

Truy cập [website dự án][0] để xem danh sách các camera được hỗ trợ.

### Xây dựng

```
git clone --recurse-submodules https://github.com/themactep/thingino-firmware
cd thingino-firmware
make
```
Đọc bài viết [Xây dựng từ nguồn](https://github.com/themactep/thingino-firmware/wiki/Building-from-sources) để biết thêm thông tin.

### Tài nguyên

- [Website dự án][0]
- [Wiki dự án][1]
- Hướng dẫn Buildroot [HTML][5] [PDF][6]
- [Kênh Discord][3]
- [Nhóm Telegram][4]

### Trạng thái CI GitHub

[![toolchain](https://github.com/themactep/thingino-firmware/actions/workflows/toolchain.yaml/badge.svg)](https://github.com/themactep/thingino-firmware/actions/workflows/toolchain.yaml)
[![firmware](https://github.com/themactep/thingino-firmware/actions/workflows/firmware.yaml/badge.svg)](https://github.com/themactep/thingino-firmware/actions/workflows/firmware.yaml)


[0]: https://thingino.com/
[1]: https://github.com/xuanvuong1702/thingino-firmware/blob/master/Wiki_vi.md
[3]: https://discord.gg/xDmqS944zr
[4]: https://t.me/thingino
[5]: https://buildroot.org/downloads/manual/manual.html
[6]: https://nightly.buildroot.org/manual.pdf