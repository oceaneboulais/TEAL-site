function [data,ierr]  =  nmealineread(nline)
%NMEALINEREAD reads an NMEA sentence into a MATLAB structure array
%
%  DATA  =  NMEALINEREAD(NLINE)
%  [DATA,IERR]  =  NMEALINEREAD(NLINE)
%
%  NLINE is an NMEA sentence. DATA is a MATLAB structure array with a
%  varying format, detailed below.
%
%  NMEALINEREAD currently supports the following NMEA sentences:
%                   $GPGGA  Global positioning system fixed data
%                   $GPGLL  Geographic poition [latitude, longitude & time]
%                   $GPVTG  Course over ground and ground speed
%                   $GPZDA  UTC date / time and local time zone offset
%                   $SDDBS  Echo sounder data
%
%  $GPGGA gives a DATA structure with the following fields:
%       Time        Day fraction
%       latitude    Decimal latitude north
%       longitude   Decimal longitude east
%
%  $GPGLL gives a DATA structure with the following fields:
%       Time    Day fraction
%       latitude    Decimal latitude north
%       longitude   Decimal longitude east
%
%  $GPVTG gives a DATA structure with the following fields:
%       speed       Speed over ground in knots
%       truecourse  Course over ground in degrees true
%
%  $GPZDA gives a DATA structure with the following fields:
%       Time    Day number
%       offset      The offset (as a fraction of a day) needed to
%                   generate the local time from BODCTime
%
%  $SDDBS gives a DATA structure with the following field:
%       depth       Depth of water below surface (m)
%
%
%  IERR returns an error code:
%       -2  -  NMEA string recognised, but function not yet able to read
%              this string
%       -1  -  NMEA string not recognised
%       0   -  No errors

% Adam Leadbetter (alead@bodc.ac.uk) -      2006-Oct-24
% Lex Lombardi (llombardi@dspaceinc.com) -  2014-Feb-19
%                       partially updated to use textscan() for parsing
%                       added support for other fields in GPGGA
%                       added checksum calculator
% Carwyn Frost (c.frost@qub.ac.uk) - 2018-Aug-21
%                       Corrected GPVTG Case to look at correct field for
%                       kph.
%                       added functionality by changing NMEA options and
%                       fields to cell arrays.
%                       additional nmea options - case 9, $PSAT,HPR

ierr  =  0;

%
%%  Set up a list of valid NMEA strings
%
nmea_options  =  {  '$GPGGA'
                    '$GPGLL'
                    '$GPGSA'
                    '$GPGSV'
                    '$GPRMC'
                    '$GPVTG'
                    '$GPZDA'
                    '$SDDBS'
                    '$PSAT'};
%
%%  Find which string we're dealing with
if contains(nline,'#')
    fprintf(1,'\n\t Warning: NMEA sting contains invalid character # \n\n');
    fprintf(['\t' nline '\n']);
    data=NaN;
    ierr=-1;
    return
end
fields = textscan(nline,'%s','delimiter',',');
%pull the checksum out of the last field and make a new one for it
if length(fields{1}{end})<2
    fprintf(1,'\n\t Warning: No valid checksum character \n\n');
    fprintf(['\t' nline '\n']);
    data=NaN;
    ierr=-1;
    return   
end
fields{1}{end+1} = fields{1}{end}(end-1:end);
%cut off the old last field at the chksum delimiter
fields{1}(end-1) = strtok(fields{1}(end-1), '*');
case_t = find(strcmp(fields{1}(1), nmea_options),1);
fields=fields{1};

%%  If no valid NMEA string found - quit with an error

if isempty(case_t)
    fprintf(1,'\n\tWarning: Not a valid NMEA string  -  %s ...\n\n',nline);
    data  =  NaN;
    ierr  =  -1;
    return
end
%
%% read and check the checksum
% Initialise checksum 
checksum = uint8(0);      

%calc it - we drop the leading '$' and trim off the '*' and anything past it
for i_char = 2:(find(nline=='*',1,'last')-1)
    checksum = bitxor(checksum, uint8(nline(i_char))); 
end
checksum = dec2hex(checksum, 2);

%check it
if ((strcmp(fields{end,1},checksum))==0)
   %checksum is bad!
    fprintf(1,'\n\t Warning: Checksum Bad  - %s ~= %s \n',char(fields(end,1)),checksum);
    fprintf(['\t' nline '\n\n']);
    data  =  NaN;
    ierr  =  -1;
    return
end

%% TURN ON THE SWITCH!

switch case_t
    case 1 %% GPGGA Read global positioning system fixed data
        if length(fields)<16
            fprintf(1,'\n\t Warning: GPGGA string does not contain enough fields \n');
            fprintf(['\t' nline '\n\n']);
            data=NaN;
            ierr=-1;
            return 
        end
        %first data field is the time
        t_time  =  fields{2,1};
        if(isempty(t_time))
            data.BODCTime  =  NaN;
        else
            data.BODCTime  =  datenum(t_time,'HHMMSS') - ...
                floor(datenum(t_time,'HHMMSS'));
        end
        clear t_time;
        
        %next data field is the lat
        t_lat  =  fields{3,1};
        if isempty(t_lat)
                data.latitude=NaN;
        else
            data.latitude  =  ...
                str2double(t_lat(1:2)) + (str2double(t_lat(3:end))/60);
            t_latDir = fields{4,1};
            if(t_latDir  ==  'S')
                data.latitude  =  data.latitude  *  -1;
            end
        end
        clear t_lat t_latDir;
        
        %then the lon
        t_lon  = fields{5,1};
        if isempty(t_lon)
            data.longitude=NaN;
        else
            data.longitude  =  ...
                str2double(t_lon(1:3)) + (str2double(t_lon(4:end))/60);
            t_lonDir = fields{6,1};
            if(t_lonDir  ==  'W')
                data.longitude  =  data.longitude  *  -1;
            end
        end
        clear t_lon t_longDir;
        
        %Get the fix quality where 0 = none, 1 = GPS fix, 2 = DGPS fix
        t_fix = fields{7,1};
        if isempty(t_fix)
            
        else
            data.fix  = str2double(t_fix);
        end
        clear t_fix;
        
        %read the number of satellites
        t_sat = fields{8,1};
        if isempty(t_sat)
        else
            data.satellites = str2double(t_sat);
        end
        clear t_sat;
        
        %read HDOP
        t_HDOP= fields{9,1};
        if isempty(t_HDOP)
            %do nothing
        else
            data.HDOP = str2double(t_HDOP);
        end
        clear t_HDOP;
        
        %Read Altitude
        t_alt = fields{10,1};
        if isempty(t_alt)
            %do nothing
        else
            data.altitude = str2double(t_alt);
        end
        clear t_alt;
        
        t_altUnit = fields{11,1};
        if isempty(t_altUnit)
        else
            if (t_altUnit(1)=='M')
                %do nothing
            else
                fprintf(1,'\tWarning: unknown Altitude Unit - %s\n\n', t_altUnit);
            end
        end
        clear t_altUnit;
        
        % Height of geoid.... meh
        t_altGeo = fields{12,1};
        clear t_altGeo;
        t_altGeoUnit = fields{13,1};
        if isempty(t_altGeoUnit)
        else
            if (t_altGeoUnit(1)=='M')
                %do nothing
            else
                fprintf(1,'\tWarning: unknown Height over WGS84 Unit - %s\n\n', t_altGeoUnit);
            end
        end
        clear t_altGeoUnit;
        
        %Time since DGPS update
        t_DGPSupdate = fields{14,1};
                
        %Checksum
        t_chkSum = fields{16,1};

        
        
        
        
        
    case 2 %% GPGLL Read geographic position [lat/lon] and time
        
        t_lat  = fields{2,1};
        data.latitude  =  str2double(t_lat(1:2)) + ...
            (str2double(t_lat(3:end)) / 60);
        t_latDir  =  fields{3,1};
        if(t_latDir  ==  'S')
            data.latitude  =  data.latitude * -1;
        end
        clear t_lat t_latDir
        
        t_lon  =  fields{4,1};
        data.longitude  =  str2double(t_lon(1:3)) + ...
            (str2double(t_lon(4:end)) / 60);
        t_lonDir = fields{5,1};
        if(t_lonDir  ==  'W')
            data.longitude  =  data.longitude  *  -1;
        end
        
        if(length(fields) == 7)
            t_time  =  fields{6,1};
            data.BODCTime  =  datenum(t_time,'HHMMSS') - ...
                floor(datenum(t_time,'HHMMSS'));
        else
            data.BODCTime  =  NaN;
        end
        
    case 3 %% GPGSA: Read Procision and fix quality information
        %fix and mode info in fields 2&3
        
        t_mode = fields{2,1};
        switch t_mode(1)
            case 'M'
                data.fixmode='Manual';
            case 'A'
                data.fixmode='Automatic';
            otherwise
                data.fixmode=NaN;
        end
        clear t_mode
        
        t_mode = fields{3,1};
        switch t_mode(1)
            case '1'
                data.fixtype=1; %no fix
                data.fix=0;
            case '2'
                data.fixtype=2; %2D fix
                data.fix=0;
            case '3'
                data.fixmode=3; %3D fix
                data.fix=0;
            otherwise
                data.fixmode=NaN;
        end
        clear t_mode
        
        %% satalite id's in fields 4-15
        t_satID=str2num(fields(4:15,1:end));
        if not(isempty(t_satID))
            data.satellites=t_satID;
        else
            data.satellites=NaN;
        end
              
        %% Dilution of precision's
        t_PDOP = fields(16,1:end);
        if not(isempty(t_PDOP))
            data.PDOP=str2double(t_PDOP);
        else
            data.PDOP=NaN;
        end
        
        t_HDOP = fields(17,1:end);
        if not(isempty(t_PDOP))
            data.HDOP=str2double(t_HDOP);
        else
            data.HDOP=NaN;
        end
        
        t_VDOP = fields(18,1:end);
        if not(isempty(t_VDOP))
            data.VDOP=str2double(t_VDOP);
        else
            data.VDOP=NaN;
        end
        clear t_PDOP t_HDOP t_VDOP
    
        
    case 6 %% GPVTG: Read course over ground and ground speed
        
        t_course  =  fields{2,1};
        if(isempty(t_course))
            data.truecourse  =  NaN;
        else
            data.truecourse  =  str2double(t_course);
        end
        
        t_course  =  fields{4,1};
        if(isempty(t_course))
            data.magneticcourse  =  NaN;
        else
            data.magneticcourse  =  str2double(t_course);
        end
        
        t_gspeed  =  fields{6,1};
        if(isempty(t_gspeed))
            data.groundspeed.knot  =  NaN;
        else
            data.groundspeed.knot  =  str2double(t_gspeed);
        end
        
        t_gspeed  =  fields{8,1};
        if(isempty(t_gspeed))
            data.groundspeed.kph  =  NaN;
        else
            data.groundspeed.kph  =  str2double(t_gspeed);
        end
        
        clear t_course t_gspeed;
        
    case 7 %%  Read UTC Date / Time and Local Time Zone Offset
        if length(fields)<5
            fprintf(1,'\n\t Warning: GPZDA string does not contain enough fields \n');
            fprintf(['\t' nline '\n\n']);
            data=NaN;
            ierr=-1;
            return 
        end

        for i=1:5
            if isempty(fields{i})
                fprintf(1,'\n\t Warning: GPZDA string has blank fields \n');
                fprintf(['\t' nline '\n\n']);
                data=NaN;
                ierr=-1;
                return 
            end
        end

        time = datetime([fields{5} '-' fields{4} '-' fields{3} ' ' fields{2}],'InputFormat','yyyy-MM-dd HHmmss.SS');
        time = datenum(time);
        data.BODCTime = time;

    case 8 %%  Read echo sounder data
        
        com_mask  =  strfind(nline,',');
        data.depth  =  str2double(...
            nline(com_mask(2) + 1: com_mask(3)-1));
        
    case 9 %%  PSAT,HPR Proprietary NMEA message that provides the heading, pitch, roll, and time in a single message
      
        %first field is the time UTC
         t_time  =  fields{3,1};
        if(isempty(t_time))
            data.BODCTime  =  NaN;
        else
            data.BODCTime  =  datenum(t_time,'HHMMSS') - ...
                floor(datenum(t_time,'HHMMSS'));
        end
        clear t_time;
        
        %next data field is the heading(degrees)
        t_heading = fields{4,1};
        if(isempty(t_heading))
            data.heading  =  NaN;
        else
            data.heading  =  str2double(t_heading);
        end
        clear t_heading;
        %next data field is the pitch(degrees)
        t_pitch = fields{5,1};
        if(isempty(t_pitch))
            data.pitch  =  NaN;
        else
            data.pitch  =  str2double(t_pitch);
        end
        clear t_pitch;
        
        %next data field is the roll(degrees)
        t_roll = fields{6,1};
         if(isempty(t_roll))
            data.roll  =  NaN;
        else
            data.roll  =  str2double(t_roll);
        end
        clear t_roll;
        
        %next data field is the type - N for GPS derived and G for gyro
        %heading
%          t_N_G = fields{7,1};
%          if(isempty(t_N_G))
%             data.N_G  =  NaN;
%         else
%             data.N_G  =  str2double(t_N_G);
%         end
%         clear t_N_G;
        
    otherwise
        data  =  NaN;
        ierr  =  -2;
        fprintf(1,...
            '\n\tWarning: NMEA reader not yet implemented for this string  -  %s  ...\n\n',...
            nline);
end

%%  Tidy up the output structure
data  =  orderfields(data);