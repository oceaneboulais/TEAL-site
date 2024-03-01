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
%18. Roll
%19. Pitch
%20. Yaw
%21. Scale Derived Oil Volume
%22. Depth (raw)
%23. Temperature
%24. Battery
%25. VOS
%26. RangeTime
%27. RangeDist
%28. USBLAzimuth
%29. USBLElevation
%30. USBLFitError
%31. PositionEasting
%32. PositionNorthing
%33. PositionDepth
%34. AUX0
%35. AUX1
%36. AUX2
%37. AUX3
%38. AUX4
%39. AUX5
%40. AUX6
%41. AUX7
%42. AUX8
%43. AUX9
%44. SrcID
%45. Control State
%46. VALVE_INDEX
%47. EN_PUMP

%Number of measurements per sample
sample_off = 405;

%Send sample request string
command_str = convertCharsToStrings(['r', num2str(sample_off+sample_number)]);
writeline(serial_structure, command_str);

%tic;
%while(toc<1)
%end

n_measurements = 47;
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
Sample.VOS = sscanf(serial_data(25),'%f'); %25. VOS
Sample.RangeTime = sscanf(serial_data(26),'%f'); %26. RangeTime

Sample.RangeDist = sscanf(serial_data(27),'%f'); %27. RangeDist
Sample.USBLAzimuth = sscanf(serial_data(28),'%f'); %28. USBLAzimuth
Sample.USBLElevation = sscanf(serial_data(29),'%f'); %29. USBLElevation
Sample.USBLFitError = sscanf(serial_data(30),'%f'); %30. USBLFitError
Sample.PositionEasting = sscanf(serial_data(31),'%f'); %31. PositionEasting
Sample.PositionNorthing = sscanf(serial_data(32),'%f'); %32. PositionNorthing
Sample.PositionDepth = sscanf(serial_data(33),'%f'); %33. PositionDepth

Sample.AUX0 = sscanf(serial_data(34),'%f'); %34. AUX0
Sample.AUX1 = sscanf(serial_data(35),'%f'); %35. AUX1
Sample.AUX2 = sscanf(serial_data(36),'%f'); %36. AUX2
Sample.AUX3 = sscanf(serial_data(37),'%f'); %37. AUX3
Sample.AUX4 = sscanf(serial_data(38),'%f'); %38. AUX4
Sample.AUX5 = sscanf(serial_data(39),'%f'); %39. AUX5
Sample.AUX6 = sscanf(serial_data(40),'%f'); %40. AUX6
Sample.AUX7 = sscanf(serial_data(41),'%f'); %41. AUX7
Sample.AUX8 = sscanf(serial_data(42),'%f'); %42. AUX8
Sample.AUX9 = sscanf(serial_data(43),'%f'); %43. AUX9

Sample.SrcID = sscanf(serial_data(44),'%f'); %44. SrcID
Sample.Control_State = sscanf(serial_data(45),'%f'); %45. Control State
Sample.VALVE_INDEX = sscanf(serial_data(46),'%f'); %46. VALVE_INDEX
Sample.EN_PUMP = sscanf(serial_data(47), '%f');  %47. EN_PUMP
