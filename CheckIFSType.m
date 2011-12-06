%% Input: IFS start position and end position
%% Output: IFS Type - SIFS/DIFS/DIFS+SLOTS/ERROR
function result = CheckIFSType(start, finish)
    ERROR = 9;
    SIFS = 20;
    gap = finish - start;
    if gap < 320*0.5
        result = ERROR;
    elseif gap < 320*1.2
        result = SIFS;
    else
        % NOTE: use round instead of ceil
        result = SIFS + round((gap-320)/180);
    end
end