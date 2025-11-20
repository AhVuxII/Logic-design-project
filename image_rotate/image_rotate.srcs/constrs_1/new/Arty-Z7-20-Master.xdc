# === Clock ===
# [cite_start]Clock 125MHz t? board [cite: 40-42]
set_property -dict { PACKAGE_PIN H16    IOSTANDARD LVCMOS33 } [get_ports { clk_125mhz }];
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { clk_125mhz }];

# === Nút B?m (Buttons) ===
# [cite_start]Nút Reset (BTN1 - D20) [cite: 44]
set_property -dict { PACKAGE_PIN D20    IOSTANDARD LVCMOS33 } [get_ports { BTN1 }];

# === Công t?c (Switches) ===
# [cite_start]SW0 (M20) và SW1 (M19) [cite: 54-55]
set_property -dict { PACKAGE_PIN M20    IOSTANDARD LVCMOS33 } [get_ports { SW[0] }];
set_property -dict { PACKAGE_PIN M19    IOSTANDARD LVCMOS33 } [get_ports { SW[1] }];

# === ?èn LED (LEDs) ===
# [cite_start]LED0 (R14) báo hi?u Done [cite: 61]
set_property -dict { PACKAGE_PIN R14    IOSTANDARD LVCMOS33 } [get_ports { LD0 }]; # LED0
set_property -dict { PACKAGE_PIN P14    IOSTANDARD LVCMOS33 } [get_ports { LD1 }]; # LED1
set_property -dict { PACKAGE_PIN N16    IOSTANDARD LVCMOS33 } [get_ports { LD2 }]; # LED2
set_property -dict { PACKAGE_PIN M14    IOSTANDARD LVCMOS33 } [get_ports { LD3 }]; # LED3

# === UART (C?U HÌNH QUAN TR?NG) ===
# Chúng ta s? dùng c?ng Pmod JA (Header JA) ?? k?t n?i UART
# B?n c?n c?m module USB-UART vào hàng chân JA này.

# [cite_start]Chân JA1 (Pin 1 - Y18) -> Gán cho UART RX (FPGA Nh?n) [cite: 132]
set_property -dict { PACKAGE_PIN Y18    IOSTANDARD LVCMOS33 } [get_ports { uart_rx }];

# [cite_start]Chân JA2 (Pin 2 - Y19) -> Gán cho UART TX (FPGA G?i) [cite: 133]
set_property -dict { PACKAGE_PIN Y19    IOSTANDARD LVCMOS33 } [get_ports { uart_tx }];