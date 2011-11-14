%% @author: youlizhao.nju@gmail.com
%% @date: Oct. 21, 2011.
%% Function: Filter packets (normal or error) from loaded data. 
%% TODO: Write an on-line program.
clear all;

%filename = 'D:\DATA\0531-2u-CW0\rx-0531';
filename = 'D:\DATA\20110805\rx_data10';

file = strcat(filename, '.dat');

rxdata = read_complex_binary(file);

%rxdata = rxdata(3.5e6:4e6);
%rxdata = rx(4e6:4.5e6);
%rxdata = rx(4.2e6:4.35e6);
%rxdata = rx(4.35e6:4.5e6);
%rxdata = rx;
rx_energy = abs(rxdata);
%plot(rx_energy, 'b.-')


ST_IDLE = 0;
ST_PACKET = 1;

DIFS_ERROR = 8;
ERROR = 9;
PACKET = 10;
ACK = 11;
BEACON = 12;
SIFS = 20;
DIFS = 21;


d_state = ST_IDLE;

list = zeros(10000, 6); % TYPE:start:end:range:IFS_TYPE:AVG_ENERGY
counter = 1;

%list_packet = zeros(10000, 3);
%list_ifs = zeros(10000, 3);
%counter_packet = 1;
%counter_ifs = 1;

BLOCK_IDLE = 50;
BLOCK_DATA = 50;
THRESHOLD = 0.01;
for ii=1:length(rx_energy)-BLOCK_DATA
    if d_state == ST_IDLE
        value = mean(rx_energy(ii:ii+BLOCK_IDLE));
    else
        value = mean(rx_energy(ii:ii+BLOCK_DATA));
    end
    if value > THRESHOLD
        if d_state == ST_IDLE
            d_state = ST_PACKET;
            list(counter, 3) = ii-1;
            list(counter, 4) = ceil((list(counter, 3) - list(counter, 2))/20);
            list(counter, 5) = CheckIFSType(list(counter, 2), list(counter, 3));
            counter = counter + 1;
            sum = 0;
            list(counter, 1) = ST_PACKET;
            list(counter, 2) = ii;
        end
        sum = sum + rx_energy(ii);
    else
        if d_state == ST_PACKET
            d_state = ST_IDLE;
            list(counter, 3) = ii-1;
            list(counter, 4) = ceil((list(counter, 3) - list(counter, 2))/20);
            list(counter, 5) = CheckPACKETType(list(counter, 2), list(counter, 3));
            list(counter, 6) = sum/(list(counter, 3)-list(counter, 2));
            counter = counter + 1;
            list(counter, 1) = ST_IDLE;
            list(counter, 2) = ii;
        end
    end
end

%save exp rx filename list counter;

%%{
%%% First part: Inteprate packet sequence
len_list = counter;
WritePacketOrder(filename, list, len_list);

%%% Second part: Statics of packets
%%{
valid_order = zeros(10000, 5);
invalid_order = zeros(10000, 5);
packet_order = zeros(10000, 7); % (start, end, flag by seq., energy, flag by energy, flag by two peak)

beacon_counter = 0;
valid_counter = 0;          % the number of valid packets
invalid_counter = 0;        % the number of invalid packets
total_counter = 0;          % the number of packets

VALID = 0;
INVALID = 1;
NOT_SURE = 2;

for ii=3:len_list-3
    if list(ii, 5) == PACKET
        total_counter = total_counter + 1;
        packet_order(total_counter, 1) = list(ii,2);
        packet_order(total_counter, 2) = list(ii,3);
        packet_order(total_counter, 4) = list(ii,6);
        if list(ii, 6) > 0.15   % threshold = 0.15
            packet_order(total_counter, 5) = INVALID;
        elseif list(ii, 6) > 0.12
            packet_order(total_counter, 5) = NOT_SURE;
        else
            packet_order(total_counter, 5) = VALID;
        end 

%        packet_order(total_counter, 6) = CheckUsers2(rx(list(ii,2):list(ii,3)-4e4));   % a packet samples: 4e4
        
        if (list(ii+1,5) == SIFS) && (list(ii+2,5) == ACK) && (list(ii+3,5) >= DIFS)
            %%% Find the begining is the challenge, requirement: 1) not
            %%% include last ACK; 2) not lost LTS
            [packet_order(total_counter, 6), packet_order(total_counter, 7)] = CheckUsers2(rxdata(list(ii-1,3)-50:list(ii,2)+500));   % a packet samples: 4e4
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
            [packet_order(total_counter, 6), packet_order(total_counter, 7)] = CheckUsers2(rxdata(list(ii-1,3)-50:list(ii,2)+500));   % a packet samples: 4e4
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
end

WriteFinalReport(filename, list, beacon_counter, valid_counter, valid_order, invalid_counter, invalid_order);
%WriteFinalReport(filename, beacon_counter, packet_order);
%%}

backoff_index = find(list(:,5) >= 21);
backoff = list(backoff_index, 5) - 21;
statics = tabulate(backoff);