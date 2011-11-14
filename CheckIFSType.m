%% Input: IFS start position and end position
%% Output: IFS Type - SIFS/DIFS/DIFS+SLOTS/ERROR
function result = CheckIFSType(start, finish)
    DIFS_ERROR = 8;
    ERROR = 9;
    SIFS = 20;
    DIFS = 21;
    gap = finish - start;
    if gap < 320*0.5
        result = ERROR;
    elseif gap < 320*1.2
        result = SIFS;
    elseif gap < 680*0.8
        result = DIFS_ERROR;
    else
        result = DIFS + ceil((gap-680)/180);
    end
end