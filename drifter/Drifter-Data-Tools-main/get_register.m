function Reg_Val = get_register(serial_structure, reg_number)
%GET_REGISTER Pass the contents of a Driftcam Serial Register.
%function Reg_Val = get_register(serial_structure, reg_number)
%inputs:
%   serial_structure = Register Number
%   reg_number = number of the register to collect
%
%outputs:
%   Reg_Val = Number in Register
%
%Dependencies serialport

%Send sample request string
command_str = convertCharsToStrings(['r', num2str(reg_number)]);
writeline(serial_structure, command_str);

readline(serial_structure); %First readback command echo

serial_data = readline(serial_structure);

Reg_Val = sscanf(serial_data(1),'%f');
