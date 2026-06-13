# 1. Tắt hiển thị log dư thừa và tạo thư viện work (nếu chưa có)
transcript on
if {[file exists work]} {
	vdel -lib work -all
}
vlib work

# 2. Biên dịch TOÀN BỘ file Verilog có trong thư mục 
vlog -work work *.v

# 3. Load file Testbench 3DES để mô phỏng
vsim -voptargs="+acc" work.tb_Lab02_Bai1

# 4. Kéo toàn bộ tín hiệu của module bên trong Testbench vào Waveform
add wave -position insertpoint sim:/tb_Lab02_Bai1/dut/*

# 5. Chạy toàn bộ quá trình mô phỏng
run -all