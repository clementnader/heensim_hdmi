# ----------------------------------------------------------------------------
# Constraints file
# 
# Zynq ZC706
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Clock Source
# ----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN H9   IOSTANDARD DIFF_HSTL_II_18} [get_ports GCLK_P];  # SYSCLK_P
set_property -dict {PACKAGE_PIN G9   IOSTANDARD DIFF_HSTL_II_18} [get_ports GCLK_N];  # SYSCLK_N
create_clock -period 5.000 -name GCLK_DIFF [get_ports GCLK_P];  # GCLK_DIFF @200 MHz

# ----------------------------------------------------------------------------
# HDMI Output
# ----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN P28  IOSTANDARD LVCMOS25} [get_ports HDMI_CLK];    # HDMI_CLK

set_property -dict {PACKAGE_PIN U24  IOSTANDARD LVCMOS25} [get_ports HDMI_D[4]];   # HDMI_D4
set_property -dict {PACKAGE_PIN T22  IOSTANDARD LVCMOS25} [get_ports HDMI_D[5]];   # HDMI_D5
set_property -dict {PACKAGE_PIN R23  IOSTANDARD LVCMOS25} [get_ports HDMI_D[6]];   # HDMI_D6
set_property -dict {PACKAGE_PIN AA25 IOSTANDARD LVCMOS25} [get_ports HDMI_D[7]];   # HDMI_D7
set_property -dict {PACKAGE_PIN AE28 IOSTANDARD LVCMOS25} [get_ports HDMI_D[8]];   # HDMI_D8
set_property -dict {PACKAGE_PIN T23  IOSTANDARD LVCMOS25} [get_ports HDMI_D[9]];   # HDMI_D9
set_property -dict {PACKAGE_PIN AB25 IOSTANDARD LVCMOS25} [get_ports HDMI_D[10]];  # HDMI_D10
set_property -dict {PACKAGE_PIN T27  IOSTANDARD LVCMOS25} [get_ports HDMI_D[11]];  # HDMI_D11

set_property -dict {PACKAGE_PIN AD26 IOSTANDARD LVCMOS25} [get_ports HDMI_D[16]];  # HDMI_D16
set_property -dict {PACKAGE_PIN AB26 IOSTANDARD LVCMOS25} [get_ports HDMI_D[17]];  # HDMI_D17
set_property -dict {PACKAGE_PIN AA28 IOSTANDARD LVCMOS25} [get_ports HDMI_D[18]];  # HDMI_D18
set_property -dict {PACKAGE_PIN AC26 IOSTANDARD LVCMOS25} [get_ports HDMI_D[19]];  # HDMI_D19
set_property -dict {PACKAGE_PIN AE30 IOSTANDARD LVCMOS25} [get_ports HDMI_D[20]];  # HDMI_D20
set_property -dict {PACKAGE_PIN Y25  IOSTANDARD LVCMOS25} [get_ports HDMI_D[21]];  # HDMI_D21
set_property -dict {PACKAGE_PIN AA29 IOSTANDARD LVCMOS25} [get_ports HDMI_D[22]];  # HDMI_D22
set_property -dict {PACKAGE_PIN AD30 IOSTANDARD LVCMOS25} [get_ports HDMI_D[23]];  # HDMI_D23

set_property -dict {PACKAGE_PIN Y28  IOSTANDARD LVCMOS25} [get_ports HDMI_D[28]];  # HDMI_D28
set_property -dict {PACKAGE_PIN AF28 IOSTANDARD LVCMOS25} [get_ports HDMI_D[29]];  # HDMI_D29
set_property -dict {PACKAGE_PIN V22  IOSTANDARD LVCMOS25} [get_ports HDMI_D[30]];  # HDMI_D30
set_property -dict {PACKAGE_PIN AA27 IOSTANDARD LVCMOS25} [get_ports HDMI_D[31]];  # HDMI_D31
set_property -dict {PACKAGE_PIN U22  IOSTANDARD LVCMOS25} [get_ports HDMI_D[32]];  # HDMI_D32
set_property -dict {PACKAGE_PIN N28  IOSTANDARD LVCMOS25} [get_ports HDMI_D[33]];  # HDMI_D33
set_property -dict {PACKAGE_PIN V21  IOSTANDARD LVCMOS25} [get_ports HDMI_D[34]];  # HDMI_D34
set_property -dict {PACKAGE_PIN AC22 IOSTANDARD LVCMOS25} [get_ports HDMI_D[35]];  # HDMI_D35

set_property -dict {PACKAGE_PIN V24  IOSTANDARD LVCMOS25} [get_ports HDMI_DE];     # HDMI_DE

set_property -dict {PACKAGE_PIN R22  IOSTANDARD LVCMOS25} [get_ports HDMI_HSYNC];  # HDMI_HSYNC
set_property -dict {PACKAGE_PIN U21  IOSTANDARD LVCMOS25} [get_ports HDMI_VSYNC];  # HDMI_VSYNC

set_property -dict {PACKAGE_PIN AJ14 IOSTANDARD LVCMOS25 PULLTYPE PULLUP} [get_ports HDMI_SCL];  # IIC_SCL_HDMI
set_property -dict {PACKAGE_PIN AJ18 IOSTANDARD LVCMOS25 PULLTYPE PULLUP} [get_ports HDMI_SDA];  # IIC_SDA_HDMI

# ----------------------------------------------------------------------------
# User Push Buttons
# ----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN AK25 IOSTANDARD LVCMOS25 PULLTYPE PULLDOWN} [get_ports BTNL];  # GPIO_SW_LEFT
set_property -dict {PACKAGE_PIN K15  IOSTANDARD LVCMOS18 PULLTYPE PULLDOWN} [get_ports BTNC];  # GPIO_SW_CENTER
set_property -dict {PACKAGE_PIN R27  IOSTANDARD LVCMOS25 PULLTYPE PULLDOWN} [get_ports BTNR];  # GPIO_SW_RIGHT

# ----------------------------------------------------------------------------
# User LEDs
# ----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN Y21  IOSTANDARD LVCMOS25} [get_ports LD[0]];  # GPIO_LED_LEFT
set_property -dict {PACKAGE_PIN G2   IOSTANDARD LVCMOS18} [get_ports LD[1]];  # GPIO_LED_CENTER
set_property -dict {PACKAGE_PIN W21  IOSTANDARD LVCMOS25} [get_ports LD[2]];  # GPIO_LED_RIGHT
set_property -dict {PACKAGE_PIN A17  IOSTANDARD LVCMOS18} [get_ports LD[3]];  # GPIO_LED_0

# ----------------------------------------------------------------------------
# Set errors from missing pins to warnings only
# ----------------------------------------------------------------------------
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]

# ----------------------------------------------------------------------------
# MULTIBOARD - Aurora
# ----------------------------------------------------------------------------
####################### GT reference clock ###########################
set_property -dict {PACKAGE_PIN AC8  IOSTANDARD DIFF_HSTL_II_18} [get_ports GTXQ2_P];
set_property -dict {PACKAGE_PIN AC7  IOSTANDARD DIFF_HSTL_II_18} [get_ports GTXQ2_N];
create_clock -period 8.000 -name GT_REFCLK1 [get_ports GTXQ2_P];  # GT_REFCLK1 @125.0MHz

############################ GT LOC ##################################
set_property LOC GTXE2_CHANNEL_X0Y9 [get_cells HEENSTopPL/MULTIBOARD_OP.z_aer_top_i/aurora_module_i/U0/gt_wrapper_i/aurora_8b10b_0_multi_gt_i/gt0_aurora_8b10b_0_i/gtxe2_i];

########### CDC in RESET_LOGIC from INIT_CLK to USER_CLK #############
set_false_path -to [get_pins -hier *aurora_8b10b_0_cdc_to*/D];
