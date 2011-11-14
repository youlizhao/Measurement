%% Input: Statical of Packets
%% Output: File
function Result = WriteFinalReport(filename, list, beacon, valid, valid_list, invalid, invalid_list)  % packet_order,

%VALID = 0;
%INVALID = 1;

%valid = length(find(packet_order(:,3)==VALID));
%invalid = length(find(packet_order(:,3)==INVALID));

name = strcat(filename, '_report.txt');

fid = fopen(name, 'w');

fprintf(fid, 'Received BEACONS:     %d \n', beacon);
fprintf(fid, 'Received PACKETS:     %d \n', valid+invalid);

% ---------- Packets with ACK ---------- %
fprintf(fid, 'PACKETS with ACK:     %d \n', valid);
result_0 = length(find(valid_list(1:valid,4) == 0));
result_1 = length(find(valid_list(1:valid,4) == 1));
result_2 = length(find(valid_list(1:valid,4) == 2));

%WITHIN_CP = 0;
%OUT_OF_CP = 1;
%result_2_1 = length(find(valid_list(1:valid,5) == WITHIN_CP));
%result_2_2 = length(find(valid_list(1:valid,5) == OUT_OF_CP));
result_2_1 = length(find( (valid_list(1:valid,5) <= 16) & (valid_list(1:valid,5) >= -16) ));
result_2_2 = length(find( (valid_list(1:valid,5) > 16) | (valid_list(1:valid,5) < -16) & (valid_list(1:valid,5) ~= -1000) ));


fprintf(fid, '\t PACKETS with 0 Users: %d (%s) \n', result_0, strcat(num2str(result_0*100.0/valid), '%'));
fprintf(fid, '\t PACKETS with 1 Users: %d (%s) \n', result_1, strcat(num2str(result_1*100.0/valid), '%'));
fprintf(fid, '\t PACKETS with 2 Users: %d (%s) \n', result_2, strcat(num2str(result_2*100.0/valid), '%'));

fprintf(fid, '\t \t Within CP: %d (%s) \n', result_2_1, strcat(num2str(result_2_1*100.0/result_2), '%'));
fprintf(fid, '\t \t Out of CP: %d (%s) \n', result_2_2, strcat(num2str(result_2_2*100.0/result_2), '%'));

% ---------- Packets without ACK --------- %
fprintf(fid, 'PACKETS without ACK:  %d (%s) \n', invalid, strcat(num2str(invalid*100.0/(valid+invalid)), '%'));

%fprintf(fid, '\n');

result_0 = length(find(invalid_list(1:invalid,4) == 0));
result_1 = length(find(invalid_list(1:invalid,4) == 1));
result_2 = length(find(invalid_list(1:invalid,4) == 2));

%WITHIN_CP = 0;
%OUT_OF_CP = 1;
%result_2_1 = length(find(invalid_list(1:invalid,5) == WITHIN_CP));
%result_2_2 = length(find(invalid_list(1:invalid,5) == OUT_OF_CP));
result_2_1 = length(find( (invalid_list(1:invalid,5) <= 16) & (invalid_list(1:invalid,5) >=  -16) ));
result_2_2 = length(find( (invalid_list(1:invalid,5) > 16) | (invalid_list(1:invalid,5) < -16) & (invalid_list(1:invalid,5) ~= -1000) ));

fprintf(fid, '\t PACKETS with 0 Users: %d (%s) \n', result_0, strcat(num2str(result_0*100.0/invalid), '%'));
fprintf(fid, '\t PACKETS with 1 Users: %d (%s) \n', result_1, strcat(num2str(result_1*100.0/invalid), '%'));
fprintf(fid, '\t PACKETS with 2 Users: %d (%s) \n', result_2, strcat(num2str(result_2*100.0/invalid), '%'));

fprintf(fid, '\t \t Within CP: %d (%s) \n', result_2_1, strcat(num2str(result_2_1*100.0/result_2), '%'));
fprintf(fid, '\t \t Out of CP: %d (%s) \n', result_2_2, strcat(num2str(result_2_2*100.0/result_2), '%'));

backoff_index = find(list(:,5) >= 21);
backoff = list(backoff_index, 5) - 21;
statics = tabulate(backoff);
%%%% Backoff Verification
fprintf(fid, '\nBackoff Schemes:    \n');
dlmwrite(name, statics, 'delimiter', '\t', '-append');

fclose(fid);
Result = 0;
end