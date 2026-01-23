function [Data] = loadDrifter(data_filename)
%LOADDRIFTER load drifter buoyancy engine data from saved file.
%function [Data] = loadDrifter(data_filename)
%inputs:
%   data_filename = string containing filename of data
%outputs:
%   Data = structure containing all BC Data.
%
%Eric Berkenpas
%09/20/2022
%
%See also DOWNLOAD_DATA PLOT_DRIFTCAM_DATA

data_matrix = load(data_filename);

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
%21. Scale Oil Volume
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


Data.Timestamp = data_matrix(:,1);
Data.z_setpoint = data_matrix(:,2);
Data.z_actual = data_matrix(:,3);
Data.z_p = data_matrix(:,4);
Data.z_i = data_matrix(:,5);
Data.z_d = data_matrix(:,6);
Data.w_command = data_matrix(:,7);
Data.w_actual = data_matrix(:,8);
Data.w_i = data_matrix(:,9);
Data.Nabla_command = data_matrix(:,10);
Data.Nabla_actual = data_matrix(:,11);
Data.Nabla_p = data_matrix(:,12);
Data.Nabla_i = data_matrix(:,13);
Data.Nabla_d = data_matrix(:,14);
Data.Qv_command = data_matrix(:,15);
Data.sps_command = data_matrix(:,16);
Data.Nabla_air = data_matrix(:,17);
Data.Pitch = data_matrix(:,18);
Data.Roll = data_matrix(:,19);
Data.Yaw = data_matrix(:,20);
Data.Nabla_Scale = data_matrix(:,21);
Data.Depth = data_matrix(:,22);
Data.Temperature = data_matrix(:,23);
Data.Battery = data_matrix(:,24);

Data.VOS = data_matrix(:,25);
Data.RangeTime = data_matrix(:,26);

Data.RangeDist = data_matrix(:,27);
Data.USBLAzimuth = data_matrix(:,28);
Data.USBLElevation = data_matrix(:,29);
Data.USBLFitError = data_matrix(:,30);
Data.PositionEasting = data_matrix(:,31);
Data.PositionNorthing = data_matrix(:,32);
Data.PositionDepth = data_matrix(:,33);

Data.AUX0 = data_matrix(:,34);
Data.AUX1 = data_matrix(:,35);
Data.AUX2 = data_matrix(:,36);
Data.AUX3 = data_matrix(:,37);
Data.AUX4 = data_matrix(:,38);
Data.AUX5 = data_matrix(:,39);
Data.AUX6 = data_matrix(:,40);
Data.AUX7 = data_matrix(:,41);
Data.AUX8 = data_matrix(:,42);
Data.AUX9 = data_matrix(:,43);

Data.SrcID = data_matrix(:,44);

Data.Control_State = data_matrix(:,45);
Data.VALVE_INDEX = data_matrix(:,46);
Data.EN_PUMP = data_matrix(:,47);

%figure;
%plot_Driftcam_data(Data);