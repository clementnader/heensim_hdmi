----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/30/2021 02:14:56 PM
-- Package Name: hdmi_resolution_pkg
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.STD_LOGIC_UNSIGNED.ALL;


package hdmi_resolution_pkg is
    
    type T_HDMI_RES_NAME is (
        HDMI_RES_1280x720_60_P, 
        HDMI_RES_1920x1080_60_P, 
        HDMI_RES_1680x1050_60_P
    );
    
    -- Resolution Definition
--    constant C_RES_NAME : T_HDMI_RES_NAME := HDMI_RES_1280x720_60_P;   -- ( 75 MHz pixel clock needed)
    constant C_RES_NAME : T_HDMI_RES_NAME := HDMI_RES_1920x1080_60_P;  -- (150 MHz pixel clock needed)
--    constant C_RES_NAME : T_HDMI_RES_NAME := HDMI_RES_1680x1050_60_P;  -- (150 MHz pixel clock needed)
    
    -----------------------------------------------------------------------------------
    
    type T_HDMI_RES_VIDEO_TIMING is
        record
            ResolutionName : T_HDMI_RES_NAME;
            -- Horizontal Timing
            HActiveVideo   : INTEGER;    -- Horizontal Active Video Size
            HFrontPorch    : INTEGER;    -- Horizontal Front Porch Size
            HSyncWidth     : INTEGER;    -- Horizontal Sync Width
            HBackPorch     : INTEGER;    -- Horizontal Back Porch Size
            HSyncPolarity  : STD_LOGIC;  -- Horizontal Sync Polarity
            -- Vertical Timing
            VActiveVideo   : INTEGER;    -- Vertical Active Video Size
            VFrontPorch    : INTEGER;    -- Vertical Front Porch Size
            VSyncWidth     : INTEGER;    -- Vertical Sync Width
            VBackPorch     : INTEGER;    -- Vertical Back Porch Size
            VSyncPolarity  : STD_LOGIC;  -- Vertical Sync Polarity
        end record;
    
    type T_HDMI_RES_VIDEO_TIMING_VEC is ARRAY(NATURAL range <>) of T_HDMI_RES_VIDEO_TIMING;
    
    constant C_HDMI_RES_VTIMING_RESOLUTIONS : T_HDMI_RES_VIDEO_TIMING_VEC := (
        --    name,                     hav,  hfp,  hsw,  hbp,  hsp,  vav,  vfp,  vsw,  vbp,  vsp
        0 => (HDMI_RES_1280x720_60_P,  1280,  110,   40,  220,  '1',  720,    5,    5,   20,  '1'),
        1 => (HDMI_RES_1920x1080_60_P, 1920,   88,   44,  148,  '1', 1080,    4,    5,   36,  '1'),
        2 => (HDMI_RES_1680x1050_60_P, 1680,  104,  184,  288,  '0', 1050,    1,    3,   33,  '1')
    );
    
    -----------------------------------------------------------------------------------
    
    function hdmi_res_get_resolution(
        res_name : T_HDMI_RES_NAME
    ) return T_HDMI_RES_VIDEO_TIMING;
    
    constant C_VIDEO_TIMING : T_HDMI_RES_VIDEO_TIMING := hdmi_res_get_resolution(C_RES_NAME);
    
    -----------------------------------------------------------------------------------
    
    constant C_ZERO : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
    
    constant C_H_VISIBLE     : STD_LOGIC_VECTOR(11 downto 0) := C_ZERO         + C_VIDEO_TIMING.HActiveVideo - 1;
    constant C_H_START_SYNC  : STD_LOGIC_VECTOR(11 downto 0) := C_H_VISIBLE    + C_VIDEO_TIMING.HFrontPorch;
    constant C_H_END_SYNC    : STD_LOGIC_VECTOR(11 downto 0) := C_H_START_SYNC + C_VIDEO_TIMING.HSyncWidth;
    constant C_H_MAX         : STD_LOGIC_VECTOR(11 downto 0) := C_H_END_SYNC   + C_VIDEO_TIMING.HBackPorch;
    constant C_H_SYNC_ACTIVE : STD_LOGIC                     := C_VIDEO_TIMING.HSyncPolarity;
    
    constant C_V_VISIBLE     : STD_LOGIC_VECTOR(11 downto 0) := C_ZERO         + C_VIDEO_TIMING.VActiveVideo - 1;
    constant C_V_START_SYNC  : STD_LOGIC_VECTOR(11 downto 0) := C_V_VISIBLE    + C_VIDEO_TIMING.VFrontPorch;
    constant C_V_END_SYNC    : STD_LOGIC_VECTOR(11 downto 0) := C_V_START_SYNC + C_VIDEO_TIMING.VSyncWidth;
    constant C_V_MAX         : STD_LOGIC_VECTOR(11 downto 0) := C_V_END_SYNC   + C_VIDEO_TIMING.VBackPorch;
    constant C_V_SYNC_ACTIVE : STD_LOGIC                     := C_VIDEO_TIMING.VSyncPolarity;
    
end package;


package body hdmi_resolution_pkg is
    
    function hdmi_res_get_resolution (
        res_name : T_HDMI_RES_NAME
    ) return T_HDMI_RES_VIDEO_TIMING is
            
        begin
            
            for i in C_HDMI_RES_VTIMING_RESOLUTIONS'range loop
                next when (res_name /= C_HDMI_RES_VTIMING_RESOLUTIONS(i).ResolutionName);
                return C_HDMI_RES_VTIMING_RESOLUTIONS(i);
            end loop;
            
            return C_HDMI_RES_VTIMING_RESOLUTIONS(1);  -- default value HDMI_RES_1920x1080_60_P
            
    end function;
    
end package body;

