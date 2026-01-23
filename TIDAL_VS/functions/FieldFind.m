function FieldValue = FieldFind(HeaderCellArray,Field)
%This Function Takes in a Field and returns the value of the field
%%
% File Format Rev is the new format.  The File Revision used to be Software
% Revision.  This section looks for both in the header
if Field=="File Format Rev"
    %Find Fields that Match Header
    for i=1:size(HeaderCellArray,1)
        FieldMatch(i)=HeaderCellArray{i,1}==Field || HeaderCellArray{i,1}=="Software Revision" || HeaderCellArray{i,1}=="File Revision" ;  %This parameter was labeled differently in different versions of code
    end
    % Identify Field Row
    Row=find(FieldMatch,1);
    if isempty(Row)
        FoundFlag=false;
        FieldValue="1";
        disp('Default Header Version Used.  Please update File Header');
    else
        FoundFlag=true;
        FieldValue=HeaderCellArray{Row,2};
    end
else
    
    %%
    %Find Fields that Match Header
    for i=1:size(HeaderCellArray,1)
        FieldMatch(i)=HeaderCellArray{i,1}==Field;
    end
    %%
    % Identify Field Row
    Row=find(FieldMatch,1);
    %%Assign Field Value to Output.  Use Empty if no fields found
    if isempty(Row)
        FoundFlag=false;
        FieldValue=[];
    else
        FoundFlag=true;
        FieldValue=HeaderCellArray{Row,2};
        
    end
end
end

