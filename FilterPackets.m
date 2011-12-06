%% @author: youlizhao.nju@gmail.com
%% @date: Dec. 6, 2011.
%% Function: (1) Filter packets (normal or error); (2) Identify users for each packet
%% INPUT: (1) filename, without .dat; (2) index, for keeping .mat; (3) rxdata, real data.

function FilterPackets(filename, index, rxdata, list)

DIFS_ERROR = 8;
ERROR = 9;
PACKET = 10;
ACK = 11;
BEACON = 12;
SIFS = 20;
DIFS = 22;

%%{
valid_order = zeros(10000, 5);
invalid_order = zeros(10000, 5);
% (start, end, flag by seq., energy, flag by energy, flag by two peak)
packet_order = zeros(10000, 7); 

beacon_counter = 0;
valid_counter = 0;          % the number of valid packets
invalid_counter = 0;        % the number of invalid packets
total_counter = 0;          % the number of packets

VALID = 0;
INVALID = 1;
NOT_SURE = 2;

LOWER = 150;                % lower bound of position from packet beginning
UPPER = 400;                % upper bound of position from packet beginning

ii = 3;
while ii <= length(list)-3
    if list(ii, 5) == PACKET
        total_counter = total_counter + 1;
        packet_order(total_counter, 1) = list(ii,2);
        packet_order(total_counter, 2) = list(ii,3);
        packet_order(total_counter, 4) = list(ii,6);
        
        %------------- Current, it is useless -----------%
        if list(ii, 6) > 0.15   % threshold = 0.15
            packet_order(total_counter, 5) = INVALID;
        elseif list(ii, 6) > 0.12
            packet_order(total_counter, 5) = NOT_SURE;
        else
            packet_order(total_counter, 5) = VALID;
        end 
        %------------- Current, it is useless -----------%
        
        if (list(ii+1,5) == SIFS) && (list(ii+2,5) == ACK) && (list(ii+3,5) >= DIFS)
            %%% Find the begining is the challenge, requirement: 1) not
            %%% include last ACK; 2) not lost LTS
            [packet_order(total_counter, 6), packet_order(total_counter, 7)] = CheckUsers2(rxdata(list(ii-1,3)+LOWER:list(ii,2)+UPPER));   % a packet samples: 4e4
            valid_counter = valid_counter + 1;
            packet_order(total_counter, 3) = VALID;
            valid_order(valid_counter, 1) = list(ii,2);
            valid_order(valid_counter, 2) = list(ii,3);
            valid_order(valid_counter, 3) = list(ii,6);
            valid_order(valid_counter, 4) = packet_order(total_counter, 6);
            valid_order(valid_counter, 5) = packet_order(total_counter, 7);
            ii = ii + 3;
        else
            %%% Find the begining is the challenge, requirement: 1) not
            %%% include last ACK; 2) not lost LTS
            [packet_order(total_counter, 6), packet_order(total_counter, 7)] = CheckUsers2(rxdata(list(ii-1,3)+LOWER:list(ii,2)+UPPER));   % a packet samples: 4e4
            invalid_counter = invalid_counter + 1;
            packet_order(total_counter, 3) = INVALID;
            invalid_order(invalid_counter, 1) = list(ii,2);
            invalid_order(invalid_counter, 2) = list(ii,3);
            invalid_order(invalid_counter, 3) = list(ii,6);
            invalid_order(invalid_counter, 4) = packet_order(total_counter, 6);
            invalid_order(invalid_counter, 5) = packet_order(total_counter, 7);
        end
    end
    if list(ii,5) == BEACON
        beacon_counter = beacon_counter + 1;
    end
    ii = ii + 1;
end

packet_order = packet_order(1:total_counter, :);
valid_order = valid_order(1:valid_counter, :);
invalid_order = invalid_order(1:invalid_counter, :);
WriteFinalReport(filename, list, beacon_counter, packet_order, valid_counter, valid_order, invalid_counter, invalid_order);

save(char(index), 'filename', 'list', 'beacon_counter', 'packet_order', 'valid_order', 'invalid_order');

end

