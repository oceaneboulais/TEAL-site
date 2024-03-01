function z_out=OCV_to_z_alg(OCV, z_Table, min_OCV, max_OCV, n_elements)
%z_out=OCV_to_z_alg(OCV, z_Table, min_OCV, max_OCV, n_elements)
%   Test function to test fast lookup table algorithm
%   Function uses a lookup table and interpolation to find SOC from OCV
%
%Inputs:
%   OCV = Open Circuit Voltage
%   z_Table = vector of capacity table
%   min_OCV = minimum Open Circuit Voltage
%   max_OCV = maximum Open Circuit Voltage
%   dV_per_Element = Voltage change per z_Table element
%
%Outputs
%   z_out = AD_Cts associated with Depth.
%
%Second Star Robotics
%March 23, 2020
%Eric Berkenpas

%Saturation Filter
if (OCV>max_OCV)
    OCV = max_OCV;
end
if (OCV<min_OCV)
    OCV = min_OCV;
end

%For regularly spaced Voltage Table calculate spacing
dV_per_Element = (max_OCV-min_OCV)/(n_elements-1);

%Calculate Voltage - offset
Voltage = OCV - min_OCV;

%Calculate z Table index
z_Table_index = floor(Voltage/dV_per_Element)+1; %May not need to add one in C port

%Calculate Fraction between z Table elements
Fraction = (Voltage - (z_Table_index-1)*dV_per_Element)/dV_per_Element;

%Get first z_Table point
Table_Point1 = z_Table(z_Table_index);

%Get Second z_Table point (with Saturation Filter)
if (z_Table_index<n_elements)
    Table_Point2 = z_Table(z_Table_index+1);
else
    Table_Point2 = Table_Point1;
end

%Interpolate Between Table Points by Fraction
Interpolated_z = (Table_Point2-Table_Point1)*Fraction;

%Add Interpolated Value to first Table Point
z_out = Table_Point1+Interpolated_z;
