%% Input: packet start position and end position
%% Output: PACKET Type: BEACON, ACK or PACKET
function result = CheckPACKETType(start, finish)
    PACKET = 10;
    ACK = 11;
    BEACON = 12;
    gap = finish - start;
    if gap < 20*60
        result = ACK;
    elseif gap < 20*250
        result = BEACON;
    else
        result = PACKET;
    end
end