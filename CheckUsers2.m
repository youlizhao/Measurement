%% INPUT: a sequence of rx data
%% OUTPUT: number of users
function [result, type] = CheckUsers2(rxdata)
%{    
  short = [
   0.0460 + 0.0460i;
  -0.1324 + 0.0023i;
  -0.0135 - 0.0785i;
   0.1428 - 0.0127i;
   0.0920          ;
   0.1428 - 0.0127i;
  -0.0135 - 0.0785i;
  -0.1324 + 0.0023i;
   0.0460 + 0.0460i;
   0.0023 - 0.1324i;
  -0.0785 - 0.0135i;
  -0.0127 + 0.1428i;
        0 + 0.0920i;
  -0.0127 + 0.1428i;
  -0.0785 - 0.0135i;
   0.0023 - 0.1324i
   ];
%}
  long = [
    0.1562         ;
  -0.0051 - 0.1203i;
   0.0397 - 0.1112i;
   0.0968 + 0.0828i;
   0.0211 + 0.0279i;
   0.0598 - 0.0877i;
  -0.1151 - 0.0552i;
  -0.0383 - 0.1062i;
   0.0975 - 0.0259i;
   0.0533 + 0.0041i;
   0.0010 - 0.1150i;
  -0.1368 - 0.0474i;
   0.0245 - 0.0585i;
   0.0587 - 0.0149i;
  -0.0225 + 0.1607i;
   0.1192 - 0.0041i;
   0.0625 - 0.0625i;
   0.0369 + 0.0983i;
  -0.0572 + 0.0393i;
  -0.1313 + 0.0652i;
   0.0822 + 0.0924i;
   0.0696 + 0.0141i;
  -0.0603 + 0.0813i;
  -0.0565 - 0.0218i;
  -0.0350 - 0.1509i;
  -0.1219 - 0.0166i;
  -0.1273 - 0.0205i;
   0.0751 - 0.0740i;
  -0.0028 + 0.0538i;
  -0.0919 + 0.1151i;
   0.0917 + 0.1059i;
   0.0123 + 0.0976i;
  -0.1562          ;
   0.0123 - 0.0976i;
   0.0917 - 0.1059i;
  -0.0919 - 0.1151i;
  -0.0028 - 0.0538i;
   0.0751 + 0.0740i;
  -0.1273 + 0.0205i;
  -0.1219 + 0.0166i;
  -0.0350 + 0.1509i;
  -0.0565 + 0.0218i;
  -0.0603 - 0.0813i;
   0.0696 - 0.0141i;
   0.0822 - 0.0924i;
  -0.1313 - 0.0652i;
  -0.0572 - 0.0393i;
   0.0369 - 0.0983i;
   0.0625 + 0.0625i;
   0.1192 + 0.0041i;
  -0.0225 - 0.1607i;
   0.0587 + 0.0149i;
   0.0245 + 0.0585i;
  -0.1368 + 0.0474i;
   0.0010 + 0.1150i;
   0.0533 - 0.0041i;
   0.0975 + 0.0259i;
  -0.0383 + 0.1062i;
  -0.1151 + 0.0552i;
   0.0598 + 0.0877i;
   0.0211 - 0.0279i;
   0.0968 - 0.0828i;
   0.0397 + 0.1112i;
  -0.0051 + 0.1203i
  ];
  
  conv_res = conv(rxdata, conj(long(end:-1:1)));
  conv_res = abs(conv_res);
%  figure;
%  plot(conv_res,'b.-');
  [value, ~] = max(conv_res);
  
  len_conv_res = length(conv_res);
  conv_res_derive = zeros(len_conv_res,1);
  for ii=2:len_conv_res
      conv_res_derive(ii) = conv_res(ii) - conv_res(ii-1);
  end
  counter = 0;
  notes = zeros(10, 2);
  for ii=1:len_conv_res-1
      if conv_res_derive(ii) > 0 && conv_res_derive(ii+1) < 0 && conv_res(ii)>=0.5*value  % 3dB
          counter = counter + 1;
          notes(counter, 1) = ii;
          notes(counter, 2) = value;
      end
  end
  
  result = 0;
  index = 0;
  record = zeros(3, 1);
  flag = zeros(counter, 1);
  for ii=1:counter
      for jj=ii+1:counter
          if flag(ii,1) == 0 && flag(jj,1) == 0 && notes(jj,1) - notes(ii,1) == 64
              % fix flag ii and jj
              flag(ii, 1) = 1;
              flag(jj, 1) = 1;
              index = index + 1;
              record(index) = notes(ii, 1);
              result = result + 1;
              
              next = find(notes(:,1) == (notes(jj,1) + 64) );
              if length(next) == 1
                  if flag(next) == 0
                    record(index) = notes(jj, 1);
                    flag(next) = 1;
                  end
              end
%              kk = jj+1;
%              while kk <= counter     % assume three peaks
%                  if flag(kk,1) == 0 && notes(kk,1) - notes(jj,1) == 64
%                      flag(kk, 1) = 1;
%                      record(index) = notes(jj, 1);
%                      break;
%                  end
%              end
              
          end
      end
  end
  
  type = -1000;
  WITHIN_CP = 0;
  OUT_OF_CP = 1;
  if result == 2
      delay = record(2,1) - record(1,1);
      type = delay;
%      if record(2,1) - record(1,1) <= 16
%          type = WITHIN_CP;
%      else
%          type = OUT_OF_CP;
%      end
  end
  
  if result == 20
%      figure;
%      plot(abs(rxdata),'b.-');
      figure;
      plot(conv_res,'b.-');
  end

end