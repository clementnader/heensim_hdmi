# ----------------------------------------------------------------------------
# Clock Source - Bank 13
# ----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN Y9} [get_ports GCLK];  # "GCLK" @100 MHz

# ----------------------------------------------------------------------------
# HDMI Output - Bank 33
# ----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN W18  SLEW FAST} [get_ports HDMI_CLK];        # "HD-CLK"

set_property -dict {PACKAGE_PIN Y13  SLEW FAST} [get_ports HDMI_D[0]];       # "HD-D0"
set_property -dict {PACKAGE_PIN AA13 SLEW FAST} [get_ports HDMI_D[1]];       # "HD-D1"
set_property -dict {PACKAGE_PIN AA14 SLEW FAST} [get_ports HDMI_D[2]];       # "HD-D2"
set_property -dict {PACKAGE_PIN Y14  SLEW FAST} [get_ports HDMI_D[3]];       # "HD-D3"
set_property -dict {PACKAGE_PIN AB15 SLEW FAST} [get_ports HDMI_D[4]];       # "HD-D4"
set_property -dict {PACKAGE_PIN AB16 SLEW FAST} [get_ports HDMI_D[5]];       # "HD-D5"
set_property -dict {PACKAGE_PIN AA16 SLEW FAST} [get_ports HDMI_D[6]];       # "HD-D6"
set_property -dict {PACKAGE_PIN AB17 SLEW FAST} [get_ports HDMI_D[7]];       # "HD-D7"
set_property -dict {PACKAGE_PIN AA17 SLEW FAST} [get_ports HDMI_D[8]];       # "HD-D8"
set_property -dict {PACKAGE_PIN Y15  SLEW FAST} [get_ports HDMI_D[9]];       # "HD-D9"
set_property -dict {PACKAGE_PIN W13  SLEW FAST} [get_ports HDMI_D[10]];      # "HD-D10"
set_property -dict {PACKAGE_PIN W15  SLEW FAST} [get_ports HDMI_D[11]];      # "HD-D11"
set_property -dict {PACKAGE_PIN V15  SLEW FAST} [get_ports HDMI_D[12]];      # "HD-D12"
set_property -dict {PACKAGE_PIN U17  SLEW FAST} [get_ports HDMI_D[13]];      # "HD-D13"
set_property -dict {PACKAGE_PIN V14  SLEW FAST} [get_ports HDMI_D[14]];      # "HD-D14"
set_property -dict {PACKAGE_PIN V13  SLEW FAST} [get_ports HDMI_D[15]];      # "HD-D15"

set_property -dict {PACKAGE_PIN U16  SLEW FAST} [get_ports HDMI_DE];         # "HD-DE"

set_property -dict {PACKAGE_PIN V17  SLEW FAST} [get_ports HDMI_HSYNC];      # "HD-HSYNC"
set_property -dict {PACKAGE_PIN W17  SLEW FAST} [get_ports HDMI_VSYNC];      # "HD-VSYNC"

set_property -dict {PACKAGE_PIN AA18 PULLTYPE PULLUP} [get_ports HDMI_SCL];  # "HD-SCL"
set_property -dict {PACKAGE_PIN Y16  PULLTYPE PULLUP} [get_ports HDMI_SDA];  # "HD-SDA"

# ----------------------------------------------------------------------------
# User Push Buttons - Bank 34
# ----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN N15  PULLTYPE PULLDOWN} [get_ports BTNL];  # "BTNL"
set_property -dict {PACKAGE_PIN P16  PULLTYPE PULLDOWN} [get_ports BTNC];  # "BTNC"
set_property -dict {PACKAGE_PIN R18  PULLTYPE PULLDOWN} [get_ports BTNR];  # "BTNR"

# ----------------------------------------------------------------------------
# User LEDs - Bank 33
# ----------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN T22} [get_ports LD[0]];  # "LD0"
set_property -dict {PACKAGE_PIN T21} [get_ports LD[1]];  # "LD1"
set_property -dict {PACKAGE_PIN U22} [get_ports LD[2]];  # "LD2"
set_property -dict {PACKAGE_PIN U21} [get_ports LD[3]];  # "LD3"

# ----------------------------------------------------------------------------
# IOSTANDARD Constraints
# ----------------------------------------------------------------------------

set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 13]];

set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 33]];
set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 34]];
set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 35]];
