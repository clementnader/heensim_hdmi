# ----------------------------------------------------------------------------
# Constraints file
# 
# ZedBoard
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Clock Source
# ----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN Y9   IOSTANDARD LVCMOS33} [get_ports GCLK];  # GCLK
create_clock -period 10.000 -name GCLK [get_ports GCLK];  # GCLK @100 MHz

# ----------------------------------------------------------------------------
# HDMI Output
# ----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN W18  IOSTANDARD LVCMOS33} [get_ports HDMI_CLK];    # HD-CLK

set_property -dict {PACKAGE_PIN Y13  IOSTANDARD LVCMOS33} [get_ports HDMI_D[8]];   # HD-D0
set_property -dict {PACKAGE_PIN AA13 IOSTANDARD LVCMOS33} [get_ports HDMI_D[9]];   # HD-D1
set_property -dict {PACKAGE_PIN AA14 IOSTANDARD LVCMOS33} [get_ports HDMI_D[10]];  # HD-D2
set_property -dict {PACKAGE_PIN Y14  IOSTANDARD LVCMOS33} [get_ports HDMI_D[11]];  # HD-D3
set_property -dict {PACKAGE_PIN AB15 IOSTANDARD LVCMOS33} [get_ports HDMI_D[12]];  # HD-D4
set_property -dict {PACKAGE_PIN AB16 IOSTANDARD LVCMOS33} [get_ports HDMI_D[13]];  # HD-D5
set_property -dict {PACKAGE_PIN AA16 IOSTANDARD LVCMOS33} [get_ports HDMI_D[14]];  # HD-D6
set_property -dict {PACKAGE_PIN AB17 IOSTANDARD LVCMOS33} [get_ports HDMI_D[15]];  # HD-D7

set_property -dict {PACKAGE_PIN AA17 IOSTANDARD LVCMOS33} [get_ports HDMI_D[16]];  # HD-D8
set_property -dict {PACKAGE_PIN Y15  IOSTANDARD LVCMOS33} [get_ports HDMI_D[17]];  # HD-D9
set_property -dict {PACKAGE_PIN W13  IOSTANDARD LVCMOS33} [get_ports HDMI_D[18]];  # HD-D10
set_property -dict {PACKAGE_PIN W15  IOSTANDARD LVCMOS33} [get_ports HDMI_D[19]];  # HD-D11
set_property -dict {PACKAGE_PIN V15  IOSTANDARD LVCMOS33} [get_ports HDMI_D[20]];  # HD-D12
set_property -dict {PACKAGE_PIN U17  IOSTANDARD LVCMOS33} [get_ports HDMI_D[21]];  # HD-D13
set_property -dict {PACKAGE_PIN V14  IOSTANDARD LVCMOS33} [get_ports HDMI_D[22]];  # HD-D14
set_property -dict {PACKAGE_PIN V13  IOSTANDARD LVCMOS33} [get_ports HDMI_D[23]];  # HD-D15

set_property -dict {PACKAGE_PIN U16  IOSTANDARD LVCMOS33} [get_ports HDMI_DE];     # HD-DE

set_property -dict {PACKAGE_PIN V17  IOSTANDARD LVCMOS33} [get_ports HDMI_HSYNC];  # HD-HSYNC
set_property -dict {PACKAGE_PIN W17  IOSTANDARD LVCMOS33} [get_ports HDMI_VSYNC];  # HD-VSYNC

set_property -dict {PACKAGE_PIN AA18 IOSTANDARD LVCMOS33 PULLTYPE PULLUP} [get_ports HDMI_SCL];  # HD-SCL
set_property -dict {PACKAGE_PIN Y16  IOSTANDARD LVCMOS33 PULLTYPE PULLUP} [get_ports HDMI_SDA];  # HD-SDA

# ----------------------------------------------------------------------------
# User Push Buttons
# ----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN N15  IOSTANDARD LVCMOS25 PULLTYPE PULLDOWN} [get_ports BTNL];  # BTNL
set_property -dict {PACKAGE_PIN P16  IOSTANDARD LVCMOS25 PULLTYPE PULLDOWN} [get_ports BTNC];  # BTNC
#set_property -dict {PACKAGE_PIN R18  IOSTANDARD LVCMOS25 PULLTYPE PULLDOWN} [get_ports BTNR];  # BTNR
set_property -dict {PACKAGE_PIN R16  IOSTANDARD LVCMOS25 PULLTYPE PULLDOWN} [get_ports BTND];  # "BTND"
#set_property -dict {PACKAGE_PIN T18  IOSTANDARD LVCMOS25 PULLTYPE PULLDOWN} [get_ports BTNU];  # "BTNU"

# ----------------------------------------------------------------------------
# User LEDs
# ----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN T22  IOSTANDARD LVCMOS33} [get_ports LD[0]];  # LD0
set_property -dict {PACKAGE_PIN T21  IOSTANDARD LVCMOS33} [get_ports LD[1]];  # LD1
set_property -dict {PACKAGE_PIN U22  IOSTANDARD LVCMOS33} [get_ports LD[2]];  # LD2
set_property -dict {PACKAGE_PIN U21  IOSTANDARD LVCMOS33} [get_ports LD[3]];  # LD3

# ----------------------------------------------------------------------------
# Set errors from missing pins to warnings only
# ----------------------------------------------------------------------------
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
