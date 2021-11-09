# ----------------------------------------------------------------------------
#     _____
#    /     \
#   /____   \____
#  / \===\   \==/
# /___\===\___\/  AVNET Design Resource Center
#      \======/         www.em.avnet.com/drc
#       \====/
# ----------------------------------------------------------------------------
#
#  Created With Avnet UCF Generator V0.4.0
#     Date: Saturday, June 30, 2012
#     Time: 12:18:55 AM
#
#  This design is the property of Avnet.  Publication of this
#  design is not authorized without written consent from Avnet.
#
#  Please direct any questions to:
#     ZedBoard.org Community Forums
#     http://www.zedboard.org
#
#  Disclaimer:
#     Avnet, Inc. makes no warranty for the use of this code or design.
#     This code is provided  "As Is". Avnet, Inc assumes no responsibility for
#     any errors, which may appear in this code, nor does it make a commitment
#     to update the information contained herein. Avnet, Inc specifically
#     disclaims any implied warranties of fitness for a particular purpose.
#                      Copyright(c) 2012 Avnet, Inc.
#                              All rights reserved.
#
# ----------------------------------------------------------------------------
#
#  Notes:
#
#  10 August 2012
#     IO standards based upon Bank 34 and Bank 35 Vcco supply options of 1.8V,
#     2.5V, or 3.3V are possible based upon the Vadj jumper (J18) settings.
#     By default, Vadj is expected to be set to 1.8V but if a different
#     voltage is used for a particular design, then the corresponding IO
#     standard within this UCF should also be updated to reflect the actual
#     Vadj jumper selection.
#
#  09 September 2012
#     Net names are not allowed to contain hyphen characters '-' since this
#     is not a legal VHDL87 or Verilog character within an identifier.
#     HDL net names are adjusted to contain no hyphen characters '-' but
#     rather use underscore '_' characters.  Comment net name with the hyphen
#     characters will remain in place since these are intended to match the
#     schematic net names in order to better enable schematic search.
#
#  17 April 2014
#     Pin constraint for toggle switch SW7 was corrected to M15 location.
#
#  16 April 2015
#     Corrected the way that entire banks are assigned to a particular IO
#     standard so that it works with more recent versions of Vivado Design
#     Suite and moved the IO standard constraints to the end of the file
#     along with some better organization and notes like we do with our SOMs.
#
#   6 June 2016
#     Corrected error in signal name for package pin N19 (FMC Expansion Connector)
#	
#
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Clock Source - Bank 13
# ----------------------------------------------------------------------------
set_property PACKAGE_PIN Y9 [get_ports {GCLK}];  # "GCLK" @100 MHz

# ----------------------------------------------------------------------------
# HDMI Output - Bank 33
# ----------------------------------------------------------------------------
set_property PACKAGE_PIN W18  [get_ports {HDMI_CLK}];    # "HDMI-CLK"
set_property SLEW FAST [get_ports {HDMI_CLK}];

set_property PACKAGE_PIN Y13  [get_ports {HDMI_D[0]}];   # "HDMI-D0"
set_property PACKAGE_PIN AA13 [get_ports {HDMI_D[1]}];   # "HDMI-D1"
set_property PACKAGE_PIN AA14 [get_ports {HDMI_D[2]}];   # "HDMI-D2"
set_property PACKAGE_PIN Y14  [get_ports {HDMI_D[3]}];   # "HDMI-D3"
set_property PACKAGE_PIN AB15 [get_ports {HDMI_D[4]}];   # "HDMI-D4"
set_property PACKAGE_PIN AB16 [get_ports {HDMI_D[5]}];   # "HDMI-D5"
set_property PACKAGE_PIN AA16 [get_ports {HDMI_D[6]}];   # "HDMI-D6"
set_property PACKAGE_PIN AB17 [get_ports {HDMI_D[7]}];   # "HDMI-D7"
set_property PACKAGE_PIN AA17 [get_ports {HDMI_D[8]}];   # "HDMI-D8"
set_property SLEW FAST [get_ports {HDMI_D[8]}];
set_property PACKAGE_PIN Y15  [get_ports {HDMI_D[9]}];   # "HDMI-D9"
set_property SLEW FAST [get_ports {HDMI_D[9]}];
set_property PACKAGE_PIN W13  [get_ports {HDMI_D[10]}];  # "HDMI-D10"
set_property SLEW FAST [get_ports {HDMI_D[10]}];
set_property PACKAGE_PIN W15  [get_ports {HDMI_D[11]}];  # "HDMI-D11"
set_property SLEW FAST [get_ports {HDMI_D[11]}];
set_property PACKAGE_PIN V15  [get_ports {HDMI_D[12]}];  # "HDMI-D12"
set_property SLEW FAST [get_ports {HDMI_D[12]}];
set_property PACKAGE_PIN U17  [get_ports {HDMI_D[13]}];  # "HDMI-D13"
set_property SLEW FAST [get_ports {HDMI_D[13]}];
set_property PACKAGE_PIN V14  [get_ports {HDMI_D[14]}];  # "HDMI-D14"
set_property SLEW FAST [get_ports {HDMI_D[14]}];
set_property PACKAGE_PIN V13  [get_ports {HDMI_D[15]}];  # "HDMI-D15"
set_property SLEW FAST [get_ports {HDMI_D[15]}];

set_property PACKAGE_PIN U16  [get_ports {HDMI_DE}];     # "HDMI-DE"

set_property PACKAGE_PIN V17  [get_ports {HDMI_HSYNC}];  # "HDMI-HSYNC"
set_property PACKAGE_PIN W17  [get_ports {HDMI_VSYNC}];  # "HDMI-VSYNC"

set_property PACKAGE_PIN AA18 [get_ports {HDMI_SCL}];    # "HDMI-SCL"
set_property PACKAGE_PIN Y16  [get_ports {HDMI_SDA}];    # "HDMI-SDA"

#set_property PACKAGE_PIN W16  [get_ports {HDMI_INT}];     # "HDMI-INT"
#set_property PACKAGE_PIN U15  [get_ports {HDMI_SPDIF}];   # "HDMI-SPDIF"
#set_property PACKAGE_PIN Y18  [get_ports {HDMI_SPDIFO}];  # "HDMI-SPDIFO"

# ----------------------------------------------------------------------------
# User Push Buttons - Bank 34
# ----------------------------------------------------------------------------
set_property PACKAGE_PIN P16 [get_ports {BTNC}];  # "BTNC"
set_property PULLDOWN true [get_ports {BTNC}]
set_property PACKAGE_PIN N15 [get_ports {BTNL}];  # "BTNL"
set_property PULLDOWN true [get_ports {BTNL}]
set_property PACKAGE_PIN R18 [get_ports {BTNR}];  # "BTNR"
set_property PULLDOWN true [get_ports {BTNR}]
#set_property PACKAGE_PIN R16 [get_ports {BTND}];  # "BTND"
#set_property PACKAGE_PIN T18 [get_ports {BTNU}];  # "BTNU"

# ----------------------------------------------------------------------------
# User LEDs - Bank 33
# ----------------------------------------------------------------------------
set_property PACKAGE_PIN T22 [get_ports {LD[0]}];  # "LD0"
set_property PACKAGE_PIN T21 [get_ports {LD[1]}];  # "LD1"
set_property PACKAGE_PIN U22 [get_ports {LD[2]}];  # "LD2"
set_property PACKAGE_PIN U21 [get_ports {LD[3]}];  # "LD3"
#set_property PACKAGE_PIN V22 [get_ports {LD[4]}];  # "LD4"
#set_property PACKAGE_PIN W22 [get_ports {LD[5]}];  # "LD5"
#set_property PACKAGE_PIN U19 [get_ports {LD[6]}];  # "LD6"
#set_property PACKAGE_PIN U14 [get_ports {LD[7]}];  # "LD7"

## ----------------------------------------------------------------------------
## User DIP Switches - Bank 35
## ----------------------------------------------------------------------------
#set_property PACKAGE_PIN F22 [get_ports {SW[0]}];  # "SW0"
#set_property PACKAGE_PIN G22 [get_ports {SW[1]}];  # "SW1"
#set_property PACKAGE_PIN H22 [get_ports {SW[2]}];  # "SW2"
#set_property PACKAGE_PIN F21 [get_ports {SW[3]}];  # "SW3"
#set_property PACKAGE_PIN H19 [get_ports {SW[4]}];  # "SW4"
#set_property PACKAGE_PIN H18 [get_ports {SW[5]}];  # "SW5"
#set_property PACKAGE_PIN H17 [get_ports {SW[6]}];  # "SW6"
#set_property PACKAGE_PIN M15 [get_ports {SW[7]}];  # "SW7"

# ----------------------------------------------------------------------------
# Audio Codec - Bank 13
# ----------------------------------------------------------------------------
#set_property PACKAGE_PIN AB1 [get_ports {AC_ADR0}];  # "AC-ADR0"
#set_property PACKAGE_PIN Y5  [get_ports {AC_ADR1}];  # "AC-ADR1"
#set_property PACKAGE_PIN Y8  [get_ports {SDATA_O}];  # "AC-GPIO0"
#set_property PACKAGE_PIN AA7 [get_ports {SDATA_I}];  # "AC-GPIO1"
#set_property PACKAGE_PIN AA6 [get_ports {BCLK_O}];   # "AC-GPIO2"
#set_property PACKAGE_PIN Y6  [get_ports {LRCLK_O}];  # "AC-GPIO3"
#set_property PACKAGE_PIN AB2 [get_ports {MCLK_O}];   # "AC-MCLK"
#set_property PACKAGE_PIN AB4 [get_ports {iic_rtl_scl_io}];  # "AC-SCK"
#set_property PACKAGE_PIN AB5 [get_ports {iic_rtl_sda_io}];  # "AC-SDA"

# ----------------------------------------------------------------------------
# JA Pmod - Bank 13
# ----------------------------------------------------------------------------
#set_property PACKAGE_PIN Y11  [get_ports {JA1}];   # "JA1"
#set_property PACKAGE_PIN AA11 [get_ports {JA2}];   # "JA2"
#set_property PACKAGE_PIN Y10  [get_ports {JA3}];   # "JA3"
#set_property PACKAGE_PIN AA9  [get_ports {JA4}];   # "JA4"
#set_property PACKAGE_PIN AB11 [get_ports {JA7}];   # "JA7"
#set_property PACKAGE_PIN AB10 [get_ports {JA8}];   # "JA8"
#set_property PACKAGE_PIN AB9  [get_ports {JA9}];   # "JA9"
#set_property PACKAGE_PIN AA8  [get_ports {JA10}];  # "JA10"

# ----------------------------------------------------------------------------
# JB Pmod - Bank 13
# ----------------------------------------------------------------------------
#set_property PACKAGE_PIN W12 [get_ports {JB1}];  # "JB1"
#set_property PACKAGE_PIN W11 [get_ports {JB2}];  # "JB2"
#set_property PACKAGE_PIN V10 [get_ports {JB3}];  # "JB3"
#set_property PACKAGE_PIN W8  [get_ports {JB4}];  # "JB4"
#set_property PACKAGE_PIN V12 [get_ports {JB7}];  # "JB7"
#set_property PACKAGE_PIN W10 [get_ports {JB8}];  # "JB8"
#set_property PACKAGE_PIN V9  [get_ports {JB9}];  # "JB9"
#set_property PACKAGE_PIN V8  [get_ports {JB10}]; # "JB10"

# ----------------------------------------------------------------------------
# JC Pmod - Bank 13
# ----------------------------------------------------------------------------
#set_property PACKAGE_PIN AB6 [get_ports {JC1_N}];  # "JC1_N"
#set_property PACKAGE_PIN AB7 [get_ports {JC1_P}];  # "JC1_P"
#set_property PACKAGE_PIN AA4 [get_ports {JC2_N}];  # "JC2_N"
#set_property PACKAGE_PIN Y4  [get_ports {JC2_P}];  # "JC2_P"
#set_property PACKAGE_PIN T6  [get_ports {JC3_N}];  # "JC3_N"
#set_property PACKAGE_PIN R6  [get_ports {JC3_P}];  # "JC3_P"
#set_property PACKAGE_PIN U4  [get_ports {JC4_N}];  # "JC4_N"
#set_property PACKAGE_PIN T4  [get_ports {JC4_P}];  # "JC4_P"

# ----------------------------------------------------------------------------
# JD Pmod - Bank 13
# ----------------------------------------------------------------------------
#set_property PACKAGE_PIN W7 [get_ports {JD1_N}];  # "JD1_N"
#set_property PACKAGE_PIN V7 [get_ports {JD1_P}];  # "JD1_P"
#set_property PACKAGE_PIN V4 [get_ports {JD2_N}];  # "JD2_N"
#set_property PACKAGE_PIN V5 [get_ports {JD2_P}];  # "JD2_P"
#set_property PACKAGE_PIN W5 [get_ports {JD3_N}];  # "JD3_N"
#set_property PACKAGE_PIN W6 [get_ports {JD3_P}];  # "JD3_P"
#set_property PACKAGE_PIN U5 [get_ports {JD4_N}];  # "JD4_N"
#set_property PACKAGE_PIN U6 [get_ports {JD4_P}];  # "JD4_P"

# ----------------------------------------------------------------------------
# OLED Display - Bank 13
# ----------------------------------------------------------------------------
#set_property PACKAGE_PIN U10  [get_ports {OLED_DC}];    # "OLED-DC"
#set_property PACKAGE_PIN U9   [get_ports {OLED_RES}];   # "OLED-RES"
#set_property PACKAGE_PIN AB12 [get_ports {OLED_SCLK}];  # "OLED-SCLK"
#set_property PACKAGE_PIN AA12 [get_ports {OLED_SDIN}];  # "OLED-SDIN"
#set_property PACKAGE_PIN U11  [get_ports {OLED_VBAT}];  # "OLED-VBAT"
#set_property PACKAGE_PIN U12  [get_ports {OLED_VDD}];   # "OLED-VDD"

# ----------------------------------------------------------------------------
# VGA Output - Bank 33
# ----------------------------------------------------------------------------
#set_property PACKAGE_PIN V20  [get_ports {VGA_R[0]}];  # "VGA-R1"
#set_property PACKAGE_PIN U20  [get_ports {VGA_R[1]}];  # "VGA-R2"
#set_property PACKAGE_PIN V19  [get_ports {VGA_R[2]}];  # "VGA-R3"
#set_property PACKAGE_PIN V18  [get_ports {VGA_R[3]}];  # "VGA-R4"
#set_property PACKAGE_PIN AB22 [get_ports {VGA_G[0]}];  # "VGA-G1"
#set_property PACKAGE_PIN AA22 [get_ports {VGA_G[1]}];  # "VGA-G2"
#set_property PACKAGE_PIN AB21 [get_ports {VGA_G[2]}];  # "VGA-G3"
#set_property PACKAGE_PIN AA21 [get_ports {VGA_G[3]}];  # "VGA-G4"
#set_property PACKAGE_PIN Y21  [get_ports {VGA_B[0]}];  # "VGA-B1"
#set_property PACKAGE_PIN Y20  [get_ports {VGA_B[1]}];  # "VGA-B2"
#set_property PACKAGE_PIN AB20 [get_ports {VGA_B[2]}];  # "VGA-B3"
#set_property PACKAGE_PIN AB19 [get_ports {VGA_B[3]}];  # "VGA-B4"
#set_property PACKAGE_PIN AA19 [get_ports {VGA_HS}];    # "VGA-HS"
#set_property PACKAGE_PIN Y19  [get_ports {VGA_VS}];    # "VGA-VS"

# ----------------------------------------------------------------------------
# USB OTG Reset - Bank 34
# ----------------------------------------------------------------------------
#set_property PACKAGE_PIN L16 [get_ports {OTG_VBUSOC}];  # "OTG-VBUSOC"

# ----------------------------------------------------------------------------
# XADC GIO - Bank 34
# ----------------------------------------------------------------------------
#set_property PACKAGE_PIN H15 [get_ports {XADC_GIO0}];  # "XADC-GIO0"
#set_property PACKAGE_PIN R15 [get_ports {XADC_GIO1}];  # "XADC-GIO1"
#set_property PACKAGE_PIN K15 [get_ports {XADC_GIO2}];  # "XADC-GIO2"
#set_property PACKAGE_PIN J15 [get_ports {XADC_GIO3}];  # "XADC-GIO3"

# ----------------------------------------------------------------------------
# Miscellaneous - Bank 34
# ----------------------------------------------------------------------------
#set_property PACKAGE_PIN K16 [get_ports {PUDC_B}];  # "PUDC_B"

## ----------------------------------------------------------------------------
## USB OTG Reset - Bank 35
## ----------------------------------------------------------------------------
#set_property PACKAGE_PIN G17 [get_ports {OTG_RESETN}];  # "OTG-RESETN"

## ----------------------------------------------------------------------------
## XADC AD Channels - Bank 35
## ----------------------------------------------------------------------------
#set_property PACKAGE_PIN E16 [get_ports {AD0N_R}];  # "XADC-AD0N-R"
#set_property PACKAGE_PIN F16 [get_ports {AD0P_R}];  # "XADC-AD0P-R"
#set_property PACKAGE_PIN D17 [get_ports {AD8N_N}];  # "XADC-AD8N-R"
#set_property PACKAGE_PIN D16 [get_ports {AD8P_R}];  # "XADC-AD8P-R"

## ----------------------------------------------------------------------------
## FMC Expansion Connector - Bank 13
## ----------------------------------------------------------------------------
#set_property PACKAGE_PIN R7 [get_ports {FMC_SCL}];  # "FMC-SCL"
#set_property PACKAGE_PIN U7 [get_ports {FMC_SDA}];  # "FMC-SDA"

## ----------------------------------------------------------------------------
## FMC Expansion Connector - Bank 33
## ----------------------------------------------------------------------------
#set_property PACKAGE_PIN AB14 [get_ports {FMC_PRSNT}];  # "FMC-PRSNT"

## ----------------------------------------------------------------------------
## FMC Expansion Connector - Bank 34
## ----------------------------------------------------------------------------
#set_property PACKAGE_PIN L19 [get_ports {FMC_CLK0_N}];     # "FMC-CLK0_N"
#set_property PACKAGE_PIN L18 [get_ports {FMC_CLK0_P}];     # "FMC-CLK0_P"
#set_property PACKAGE_PIN M20 [get_ports {FMC_LA00_CC_N}];  # "FMC-LA00_CC_N"
#set_property PACKAGE_PIN M19 [get_ports {FMC_LA00_CC_P}];  # "FMC-LA00_CC_P"
#set_property PACKAGE_PIN N20 [get_ports {FMC_LA01_CC_N}];  # "FMC-LA01_CC_N"
#set_property PACKAGE_PIN N19 [get_ports {FMC_LA01_CC_P}];  # "FMC-LA01_CC_P"
#set_property PACKAGE_PIN P18 [get_ports {FMC_LA02_N}];     # "FMC-LA02_N"
#set_property PACKAGE_PIN P17 [get_ports {FMC_LA02_P}];     # "FMC-LA02_P"
#set_property PACKAGE_PIN P22 [get_ports {FMC_LA03_N}];     # "FMC-LA03_N"
#set_property PACKAGE_PIN N22 [get_ports {FMC_LA03_P}];     # "FMC-LA03_P"
#set_property PACKAGE_PIN M22 [get_ports {FMC_LA04_N}];     # "FMC-LA04_N"
#set_property PACKAGE_PIN M21 [get_ports {FMC_LA04_P}];     # "FMC-LA04_P"
#set_property PACKAGE_PIN K18 [get_ports {FMC_LA05_N}];     # "FMC-LA05_N"
#set_property PACKAGE_PIN J18 [get_ports {FMC_LA05_P}];     # "FMC-LA05_P"
#set_property PACKAGE_PIN L22 [get_ports {FMC_LA06_N}];     # "FMC-LA06_N"
#set_property PACKAGE_PIN L21 [get_ports {FMC_LA06_P}];     # "FMC-LA06_P"
#set_property PACKAGE_PIN T17 [get_ports {FMC_LA07_N}];     # "FMC-LA07_N"
#set_property PACKAGE_PIN T16 [get_ports {FMC_LA07_P}];     # "FMC-LA07_P"
#set_property PACKAGE_PIN J22 [get_ports {FMC_LA08_N}];     # "FMC-LA08_N"
#set_property PACKAGE_PIN J21 [get_ports {FMC_LA08_P}];     # "FMC-LA08_P"
#set_property PACKAGE_PIN R21 [get_ports {FMC_LA09_N}];     # "FMC-LA09_N"
#set_property PACKAGE_PIN R20 [get_ports {FMC_LA09_P}];     # "FMC-LA09_P"
#set_property PACKAGE_PIN T19 [get_ports {FMC_LA10_N}];     # "FMC-LA10_N"
#set_property PACKAGE_PIN R19 [get_ports {FMC_LA10_P}];     # "FMC-LA10_P"
#set_property PACKAGE_PIN N18 [get_ports {FMC_LA11_N}];     # "FMC-LA11_N"
#set_property PACKAGE_PIN N17 [get_ports {FMC_LA11_P}];     # "FMC-LA11_P"
#set_property PACKAGE_PIN P21 [get_ports {FMC_LA12_N}];     # "FMC-LA12_N"
#set_property PACKAGE_PIN P20 [get_ports {FMC_LA12_P}];     # "FMC-LA12_P"
#set_property PACKAGE_PIN M17 [get_ports {FMC_LA13_N}];     # "FMC-LA13_N"
#set_property PACKAGE_PIN L17 [get_ports {FMC_LA13_P}];     # "FMC-LA13_P"
#set_property PACKAGE_PIN K20 [get_ports {FMC_LA14_N}];     # "FMC-LA14_N"
#set_property PACKAGE_PIN K19 [get_ports {FMC_LA14_P}];     # "FMC-LA14_P"
#set_property PACKAGE_PIN J17 [get_ports {FMC_LA15_N}];     # "FMC-LA15_N"
#set_property PACKAGE_PIN J16 [get_ports {FMC_LA15_P}];     # "FMC-LA15_P"
#set_property PACKAGE_PIN K21 [get_ports {FMC_LA16_N}];     # "FMC-LA16_N"
#set_property PACKAGE_PIN J20 [get_ports {FMC_LA16_P}];     # "FMC-LA16_P"

## ----------------------------------------------------------------------------
## FMC Expansion Connector - Bank 35
## ----------------------------------------------------------------------------
#set_property PACKAGE_PIN C19 [get_ports {FMC_CLK1_N}];     # "FMC-CLK1_N"
#set_property PACKAGE_PIN D18 [get_ports {FMC_CLK1_P}];     # "FMC-CLK1_P"
#set_property PACKAGE_PIN B20 [get_ports {FMC_LA17_CC_N}];  # "FMC-LA17_CC_N"
#set_property PACKAGE_PIN B19 [get_ports {FMC_LA17_CC_P}];  # "FMC-LA17_CC_P"
#set_property PACKAGE_PIN C20 [get_ports {FMC_LA18_CC_N}];  # "FMC-LA18_CC_N"
#set_property PACKAGE_PIN D20 [get_ports {FMC_LA18_CC_P}];  # "FMC-LA18_CC_P"
#set_property PACKAGE_PIN G16 [get_ports {FMC_LA19_N}];     # "FMC-LA19_N"
#set_property PACKAGE_PIN G15 [get_ports {FMC_LA19_P}];     # "FMC-LA19_P"
#set_property PACKAGE_PIN G21 [get_ports {FMC_LA20_N}];     # "FMC-LA20_N"
#set_property PACKAGE_PIN G20 [get_ports {FMC_LA20_P}];     # "FMC-LA20_P"
#set_property PACKAGE_PIN E20 [get_ports {FMC_LA21_N}];     # "FMC-LA21_N"
#set_property PACKAGE_PIN E19 [get_ports {FMC_LA21_P}];     # "FMC-LA21_P"
#set_property PACKAGE_PIN F19 [get_ports {FMC_LA22_N}];     # "FMC-LA22_N"
#set_property PACKAGE_PIN G19 [get_ports {FMC_LA22_P}];     # "FMC-LA22_P"
#set_property PACKAGE_PIN D15 [get_ports {FMC_LA23_N}];     # "FMC-LA23_N"
#set_property PACKAGE_PIN E15 [get_ports {FMC_LA23_P}];     # "FMC-LA23_P"
#set_property PACKAGE_PIN A19 [get_ports {FMC_LA24_N}];     # "FMC-LA24_N"
#set_property PACKAGE_PIN A18 [get_ports {FMC_LA24_P}];     # "FMC-LA24_P"
#set_property PACKAGE_PIN C22 [get_ports {FMC_LA25_N}];     # "FMC-LA25_N"
#set_property PACKAGE_PIN D22 [get_ports {FMC_LA25_P}];     # "FMC-LA25_P"
#set_property PACKAGE_PIN E18 [get_ports {FMC_LA26_N}];     # "FMC-LA26_N"
#set_property PACKAGE_PIN F18 [get_ports {FMC_LA26_P}];     # "FMC-LA26_P"
#set_property PACKAGE_PIN D21 [get_ports {FMC_LA27_N}];     # "FMC-LA27_N"
#set_property PACKAGE_PIN E21 [get_ports {FMC_LA27_P}];     # "FMC-LA27_P"
#set_property PACKAGE_PIN A17 [get_ports {FMC_LA28_N}];     # "FMC-LA28_N"
#set_property PACKAGE_PIN A16 [get_ports {FMC_LA28_P}];     # "FMC-LA28_P"
#set_property PACKAGE_PIN C18 [get_ports {FMC_LA29_N}];     # "FMC-LA29_N"
#set_property PACKAGE_PIN C17 [get_ports {FMC_LA29_P}];     # "FMC-LA29_P"
#set_property PACKAGE_PIN B15 [get_ports {FMC_LA30_N}];     # "FMC-LA30_N"
#set_property PACKAGE_PIN C15 [get_ports {FMC_LA30_P}];     # "FMC-LA30_P"
#set_property PACKAGE_PIN B17 [get_ports {FMC_LA31_N}];     # "FMC-LA31_N"
#set_property PACKAGE_PIN B16 [get_ports {FMC_LA31_P}];     # "FMC-LA31_P"
#set_property PACKAGE_PIN A22 [get_ports {FMC_LA32_N}];     # "FMC-LA32_N"
#set_property PACKAGE_PIN A21 [get_ports {FMC_LA32_P}];     # "FMC-LA32_P"
#set_property PACKAGE_PIN B22 [get_ports {FMC_LA33_N}];     # "FMC-LA33_N"
#set_property PACKAGE_PIN B21 [get_ports {FMC_LA33_P}];     # "FMC-LA33_P"


# ----------------------------------------------------------------------------
# IOSTANDARD Constraints
#
# Note that these IOSTANDARD constraints are applied to all IOs currently
# assigned within an I/O bank.  If these IOSTANDARD constraints are
# evaluated prior to other PACKAGE_PIN constraints being applied, then
# the IOSTANDARD specified will likely not be applied properly to those
# pins.  Therefore, bank wide IOSTANDARD constraints should be placed
# within the XDC file in a location that is evaluated AFTER all
# PACKAGE_PIN constraints within the target bank have been evaluated.
#
# Un-comment one or more of the following IOSTANDARD constraints according to
# the bank pin assignments that are required within a design.
# ----------------------------------------------------------------------------

# Note that the bank voltage for IO Bank 33 is fixed to 3.3V on ZedBoard.
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 33]];

# Set the bank voltage for IO Bank 34 to 1.8V by default.
# set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 34]];
# set_property IOSTANDARD LVCMOS25 [get_ports -of_objects [get_iobanks 34]];
set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 34]];

# Set the bank voltage for IO Bank 35 to 1.8V by default.
# set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 35]];
# set_property IOSTANDARD LVCMOS25 [get_ports -of_objects [get_iobanks 35]];
set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 35]];

# Note that the bank voltage for IO Bank 13 is fixed to 3.3V on ZedBoard.
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 13]];
