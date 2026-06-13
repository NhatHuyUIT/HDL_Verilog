# 1. Tắt hiển thị log dư thừa và tạo thư viện work (nếu chưa có)
transcript on
if {[file exists work]} {
	vdel -lib work -all
}
vlib work

# 2. Biên dịch TOÀN BỘ file Verilog có trong thư mục
vlog -work work *.v

# 3. Load file Testbench để mô phỏng
vsim -voptargs="+acc" work.tb_Lab02_Bai2

# 4. Kéo tín hiệu vào Waveform
add wave -position insertpoint sim:/tb_Lab02_Bai2/*

# Tín hiệu bên trong từng core (chọn core 0 làm đại diện)
add wave -position insertpoint {sim:/tb_Lab02_Bai2/block_gen[0]/dut/*}
add wave -position insertpoint {sim:/tb_Lab02_Bai2/block_gen[1]/dut/*}
add wave -position insertpoint {sim:/tb_Lab02_Bai2/block_gen[2]/dut/*}
add wave -position insertpoint {sim:/tb_Lab02_Bai2/block_gen[3]/dut/*}
add wave -position insertpoint {sim:/tb_Lab02_Bai2/block_gen[4]/dut/*}
add wave -position insertpoint {sim:/tb_Lab02_Bai2/block_gen[5]/dut/*}
add wave -position insertpoint {sim:/tb_Lab02_Bai2/block_gen[6]/dut/*}
add wave -position insertpoint {sim:/tb_Lab02_Bai2/block_gen[7]/dut/*}

# 5. Chạy toàn bộ quá trình mô phỏng
run -all
