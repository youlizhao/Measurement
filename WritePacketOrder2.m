%% Input: rxdata, filename (no postfix)
%% Output: (1) packet statitcs - list (2) output [list] and [packet order] to files
%% List Format: STATE, start, end, length, TYPE, AVG_ENG
%%  - STATE: ST_IDLE, ST_PACKET
%%  - TYPE:  IFS_TYPE, PACKET_TYPE

% Using Double Sliding Window Approach to Detect Packet Boundary, including
% Beginning and Ending. Note the positive peak is the beginning, and the
% negative peak is the ending.


function [list] = WritePacketOrder2(rxdata, filename)

% Parameters
ST_IDLE = 0;
ST_PACKET = 1;
UP_THRESHOLD = 0.3;             % threshold for positive peak (log) = 1.9953
LOW_THRESHOLD = -0.5;           % threshold for negative peak (log) = 0.3162
WINDOW_SIZE = 100;              % for peak search
BLOCK_SIZE=50;                  % window size

% ---------------------------------- 1 ---------------------------------- %
% Calculate the double window ratio
value = zeros(length(rxdata),1);
for ii=BLOCK_SIZE+1:length(rxdata)-BLOCK_SIZE
    v1 = sum(abs(rxdata(ii-BLOCK_SIZE:ii-1)));
    v2 = sum(abs(rxdata(ii:ii+BLOCK_SIZE-1)));
    value(ii) = v2/v1;
end
%semilogy(value, 'b.-');
%plot(value, 'b.-')
value_diff = [0; diff(value)];

list = zeros(10000, 6); 
counter = 1;
sum_energy = 0;

ii = 1;
while ii <= length(rxdata)-1
    sum_energy = sum_energy + abs(rxdata(ii));
    if value_diff(ii) > 0 && value_diff(ii+1) < 0 && value(ii) > 10^UP_THRESHOLD    % Start of a packet
        % skip the case that last state is ST_PACKET, and the window energy
        % is not high enough (10^(UP_THRESHOLD+0.2))
        if value(ii) < 10^(UP_THRESHOLD+0.2) && counter>1 && list(counter-1, 1) == ST_PACKET
            ii = ii + 1;
            continue;
        end
            
        [~, index] = max(abs(value(ii:ii+WINDOW_SIZE))); 
        list(counter, 1) = ST_PACKET;
        list(counter, 2) = ii+index-1;
        if counter > 1
            list(counter-1, 3) = ii+index-2;
            list(counter-1, 4) = ceil((list(counter-1, 3)-list(counter-1, 2)));
            list(counter-1, 5) = CheckIFSType(list(counter-1, 2), list(counter-1, 3));
            list(counter-1, 6) = sum_energy/(list(counter-1, 3)-list(counter-1, 2));
        end
        sum_energy = 0;
        ii = ii + WINDOW_SIZE;
        counter = counter + 1;
    end
    
    if value_diff(ii) < 0 && value_diff(ii+1) > 0 && value(ii) < 10^LOW_THRESHOLD   % End of a packet
 %       [~, index] = min(abs(value(ii:ii+WINDOW_SIZE)));
        index = 0; % to avoid ACK lag problem, we skip the min search step
        list(counter, 1) = ST_IDLE;
        list(counter, 2) = ii+index-1;
        if counter > 1
            list(counter-1, 3) = ii+index-2;
            list(counter-1, 4) = ceil((list(counter-1, 3)-list(counter-1, 2)));
            list(counter-1, 5) = CheckPACKETType(list(counter-1, 2), list(counter-1, 3));
            list(counter-1, 6) = sum_energy/(list(counter-1, 3)-list(counter-1, 2));
        end
        sum_energy = 0;
        ii = ii + WINDOW_SIZE;
        counter = counter + 1;
    end
    
    ii = ii + 1;
end

list = list(1:counter, :);

% ---------------------------------- 2 ---------------------------------- %
% Write list to file
%list = list(1:counter-1, :);
%name = strcat(filename, '_list.txt');
%dlmwrite(name, list, 'delimiter', '\t', 'precision', 10);

% ---------------------------------- 3 ---------------------------------- %
% Write Packet Statitcs
DIFS_ERROR = 8;
ERROR = 9;
PACKET = 10;
ACK = 11;
BEACON = 12;
SIFS = 20;
DIFS = 22;

name = strcat(filename, '_order.txt');

fid = fopen(name, 'w');
for ii=1:length(list)
    s = '';
    t = 0;
    if list(ii, 5) == DIFS_ERROR
        if list(ii+1, 5) == BEACON
            s = 'DIFS';
        else
            s = 'DIFS_ERROR';
        end
    elseif list(ii,5) == ERROR
        s = 'ERROR';
    elseif list(ii,5) == PACKET
        s = 'PACKET';
    elseif list(ii,5) == ACK
        s = 'ACK';
    elseif list(ii,5) == BEACON
        s = 'BEACON';
    elseif list(ii,5) == SIFS
        s = 'SIFS';
    elseif list(ii, 5) >= DIFS
        t = list(ii, 5) - DIFS;
        s = 'DIFS';
    end
    
    if list(ii,1) == ST_IDLE
        if strcmp(s, 'DIFS')    %list(ii, 5) >= DIFS
            fprintf(fid, '\n');
        end
        if t ~= 0
            fprintf(fid, '%s + %d SLOTS + ', s, t);
        else
            fprintf(fid, '%s + ', s);
        end
    else
        fprintf(fid, '%s + ', s);
    end
end

fclose(fid);

end