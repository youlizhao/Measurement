%% Input: Statical of Packets (list: idle or data, start, end, len, type, energy for data)
%% Output: File
function result = WritePacketOrder(filename, list, len)

ST_IDLE = 0;
ST_PACKET = 1;

DIFS_ERROR = 8;
ERROR = 9;
PACKET = 10;
ACK = 11;
BEACON = 12;
SIFS = 20;
DIFS = 21;

name = strcat(filename, '_order.txt');

fid = fopen(name, 'w');
for ii=1:len
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
%        fprintf(fid, 'IDLE %s + %d SLOTS\n', s, t);
    end
    
    if list(ii,1) == ST_IDLE
        if strcmp(s, 'DIFS')    %list(ii, 5) >= DIFS
            fprintf(fid, '\n');
        end
        if t ~= 0
%            fprintf(fid, 'IDLE %s + %d SLOTS\n', s, t);
            fprintf(fid, '%s + %d SLOTS + ', s, t);
        else
%            fprintf(fid, 'IDLE %s \n', s);
            fprintf(fid, '%s + ', s);
        end
    else
        fprintf(fid, '%s + ', s);
%        if list(ii,5) == ACK || list(ii,5) == BEACON
%        	fprintf(fid, '\n');
%        end
    end
end

fclose(fid);

result = 0;

end