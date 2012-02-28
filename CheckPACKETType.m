%% Input: packet start position and end position
%% Output: PACKET Type: BEACON, ACK, PACKET or ERROR
%% Note:  we only care about our application-special packets, e.g., BEACON, ACK, MY_PACKET. Other packets are treated as ERROR.
function result = CheckPACKETType(start, finish)
    ERROR = 9;
    PACKET = 10;
    ACK = 11;
    BEACON = 12;
    
    gap = finish - start;
    if gap < 900 && gap > 800
        result = ACK;       % typical value: 800~900 (880)
    elseif gap < 3800 && gap > 3700
        result = BEACON;    % typical value: 3700~3800 (3760) 
    elseif gap < 41500 && gap > 41400
        result = PACKET;    % typical value: 41400~41500 (41440)
    else
        result = ERROR;
    end
end