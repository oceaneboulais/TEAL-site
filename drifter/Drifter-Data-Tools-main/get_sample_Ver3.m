function Sample = get_sample_Ver3(serial_structure, sample_number)
%GET_SAMPLE Download a data sample.
%function Sample = get_sample(serial_structure, sample_number)
%inputs:
%   serial_structure = Serial Port Object
%   sample_number = number of the sample to collect
%
%outputs:
%   Sample = Data Structure containing Driftcam control data.
%
%Dependencies serialport

%1. Ticks
%2. z_setpoint
%3. z_actual (estimated)
%4. z_p
%5. z_i
%6. z_d
%7. w_command
%8. w_actual (estimated)
%9. w_i
%10. Nabla_command
%11. Nabla_actual
%12. Nabla_p
%13. Nabla_i
%14. Nabla_d
%15. Qv_command
%16. sps_command
%17. Nabla_air
%18. Pitch
%19. Roll
%20. Yaw
%21. Scale Derived Oil Volume
%22. Depth (raw)
%23. Temperature
%24. Battery
%25. OP2?
%26. VALVE_INDEX

%Number of measurements per sample
sample_off = 405;

%Send sample request string
command_str = convertCharsToStrings(['r', num2str(sample_off+sample_number)]);
writeline(serial_structure, command_str);

%tic;
%while(toc<1)
%end

n_measurements = 26;
serial_data = strings(n_measurements,1);
measurement_index = 0;
readline(serial_structure); %read the first line to clear it (contains the command echo)
while (measurement_index<n_measurements)
    measurement_index = measurement_index + 1;
    serial_data(measurement_index) = readline(serial_structure);
end

Sample.Timestamp = sscanf(serial_data(1),'%f'); %1. Ticks
%DEPTH CONTROL VARIABLES (z)
Sample.z_setpoint = sscanf(serial_data(2),'%f'); %2. z_setpoint
Sample.z_actual = sscanf(serial_data(3),'%f'); %3. z_actual (estimated)
Sample.z_p = sscanf(serial_data(4),'%f'); %4. z_p
Sample.z_i = sscanf(serial_data(5),'%f'); %5. z_i
Sample.z_d = sscanf(serial_data(6),'%f'); %6. z_d
Sample.w_command = sscanf(serial_data(7),'%f'); %7. w_command
Sample.w_actual = sscanf(serial_data(8),'%f'); %8. w_actual (estimated)
Sample.w_i = sscanf(serial_data(9),'%f'); %9. w_i
Sample.Nabla_command = sscanf(serial_data(10),'%f'); %10. Nabla_command
Sample.Nabla_actual = sscanf(serial_data(11),'%f'); %11. Nabla_actual
Sample.Nabla_p = sscanf(serial_data(12),'%f'); %12. Nabla_p
Sample.Nabla_i = sscanf(serial_data(13),'%f'); %13. Nabla_i
Sample.Nabla_d = sscanf(serial_data(14),'%f'); %14. Nabla_d
Sample.Qv_command = sscanf(serial_data(15),'%f'); %15. Qv_command
Sample.sps_command = sscanf(serial_data(16),'%f'); %16. sps_command
Sample.Nabla_air = sscanf(serial_data(17),'%f'); %17. Nabla_air
Sample.Pitch = sscanf(serial_data(18),'%f'); %18. Pitch
Sample.Roll = sscanf(serial_data(19),'%f'); %19. Roll
Sample.Yaw = sscanf(serial_data(20),'%f'); %20. Yaw
Sample.Nabla_Scale = sscanf(serial_data(21),'%f'); %21. Scale Derived Oil Volume
Sample.Depth = sscanf(serial_data(22),'%f'); %12. Depth (raw)
Sample.Temperature = sscanf(serial_data(23),'%f'); %23. Temperature
Sample.Battery = sscanf(serial_data(24),'%f'); %24. Battery
Sample.OP = sscanf(serial_data(25),'%f'); %25. Operating Point
Sample.VALVE_INDEX = sscanf(serial_data(26), '%f'); %26. VALVE_INDEX
