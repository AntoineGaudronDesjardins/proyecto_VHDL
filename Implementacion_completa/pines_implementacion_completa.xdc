#Clock signal 100Mhz. Pin W5
set_property PACKAGE_PIN W5                                           [get_ports CLK]							
	set_property IOSTANDARD LVCMOS33                                  [get_ports CLK]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports CLK]


#------------------------------------------------------------------              
#Buttons
#------------------------------------------------------------------              
            set_property PACKAGE_PIN U18       [get_ports {BUTTON_RESET}]            
              set_property IOSTANDARD LVCMOS33 [get_ports {BUTTON_RESET}]
            set_property PACKAGE_PIN W19       [get_ports BUTTON_1]            
              set_property IOSTANDARD LVCMOS33 [get_ports BUTTON_1]
            set_property PACKAGE_PIN T17       [get_ports BUTTON_2]            
              set_property IOSTANDARD LVCMOS33 [get_ports BUTTON_2]
                                
#------------------------------------------------------------------              
# LEDs
#------------------------------------------------------------------              
                                set_property PACKAGE_PIN U16 [get_ports {LED}]                    
                                    set_property IOSTANDARD LVCMOS33 [get_ports {LED}]
                                set_property PACKAGE_PIN E19 [get_ports {MOTOR_OUT[0]}]                    
                                    set_property IOSTANDARD LVCMOS33 [get_ports {MOTOR_OUT[0]}]
                                set_property PACKAGE_PIN U19 [get_ports {MOTOR_OUT[1]}]                    
                                    set_property IOSTANDARD LVCMOS33 [get_ports {MOTOR_OUT[1]}]
                                set_property PACKAGE_PIN V19 [get_ports {MOTOR_OUT[2]}]                    
                                    set_property IOSTANDARD LVCMOS33 [get_ports {MOTOR_OUT[2]}]
                                set_property PACKAGE_PIN W18 [get_ports {MOTOR_OUT[3]}]                    
                                    set_property IOSTANDARD LVCMOS33 [get_ports {MOTOR_OUT[3]}]
                                         