-------------------------------------------------------------------------------
-- Title      : FPGA reset for Arria 
-- Project    : all Arria platforms
-------------------------------------------------------------------------------
-- File       : altera_reset.vhd
-- Author     : Stefan Rauch
-- Company    : GSI
-- Created    : 2013-12-12
-- Last update: 2013-12-16
-- Platform   : Altera
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: resets FPGA with internal logic using alt remote update 
-- 
-- Bit 0 => reload FPGA configuration (active high)
-- Bit 1 => reset_out(0)
-- Bit 2 => reset_out(1)
-- Bit 3 => reset_out(2)
-- Bit 4 => reset_out(3)
-- Bit 5 => reset_out(4)
-- Bit 6 => reset_out(5)
-- Bit 7 => reset_out(6)
-------------------------------------------------------------------------------
--
-- Copyright (c) 2013 GSI / Stefan Rauch
--
-- This source file is free software; you can redistribute it   
-- and/or modify it under the terms of the GNU Lesser General   
-- Public License as published by the Free Software Foundation; 
-- either version 2.1 of the License, or (at your option) any   
-- later version.                                               
--
-- This source is distributed in the hope that it will be       
-- useful, but WITHOUT ANY WARRANTY; without even the implied   
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
-- PURPOSE.  See the GNU Lesser General Public License for more 
-- details.                                                     
--
-- You should have received a copy of the GNU Lesser General    
-- Public License along with this source; if not, download it   
-- from http://www.gnu.org/licenses/lgpl-2.1.html
-- 
--
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author      Description
-- 2013-09-13  1.0      stefanrauch first version
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.wishbone_pkg.all;
use work.wb_arria_reset_pkg.all;

entity wb_arria_reset is
  generic (
            arria_family: string := "Arria II";
            rst_channels: integer range 1 to 7 := 2
          );
  port (
          clk:        in std_logic;
          nrst:       in std_logic;
          
          slave_o:    out t_wishbone_slave_out;
          slave_i:    in t_wishbone_slave_in;
           
          reset_out:  out std_logic_vector(rst_channels-1 downto 0)
      );
end entity;


architecture wb_arria_reset_arch of wb_arria_reset is
  signal reset_reg: std_logic_vector(7 downto 0);
begin
  
  ruc_gen_a2 : if arria_family = "Arria II" generate
    arria_reset_inst : arria_reset PORT MAP (
      clock	      => clk,
      param	      => "000",
      read_param	=> '0',
      reconfig	  => reset_reg(0),
      reset	      => not nrst,
      reset_timer	=> '0',
      busy	      => open,
      data_out	  => open
    );
  end generate;
  
  ruc_gen_a5 : if arria_family = "Arria V" generate
    arria5_reset_inst : arria5_reset PORT MAP (
      clock	      => clk,
      param	      => "000",
      read_param	=> '0',
      reconfig	  => reset_reg(0),
      reset	      => not nrst,
      reset_timer	=> '0',
      busy	      => open,
      data_out	  => open
    );
  end generate;
  
  rst_out_gen: for i in 0 to rst_channels-1 generate
    reset_out(i) <= reset_reg(i+1);
  end generate;
  
  
  wb_reg: process(clk)
  begin
    if rising_edge(clk) then
      slave_o.ack <= slave_i.cyc and slave_i.stb;
      slave_o.dat <= (others => '0');
  
      if nrst = '0' then
        reset_reg <= (others => '0');
      else
        -- Detect a write to the register byte
        if slave_i.cyc = '1' and slave_i.stb = '1' and slave_i.we = '1' and slave_i.sel(0) = '1' then
          case to_integer(unsigned(slave_i.adr(3 downto 2))) is
            when 0 => reset_reg <= slave_i.dat(reset_reg'range);
            when others => null;
          end case;
        end if;
      end if;
    end if;
  end process;
end architecture;
