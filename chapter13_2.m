%INFORMAX????????
clear
close all;
load('Speech4.mat')     %????
s1=Speech4(2,:);                %?????
s2=Speech4(4,:);                %?????
a1=s1/max(abs(s1));
a2=s2/max(abs(s2));
s1=[a1,a2,a1];
s2=[a2,a1,a2];
figure                          %?????
subplot(121)                    %????
plot(s1)                        %????????
xlabel('???')
ylabel('??')
subplot(122)                    %????
plot(s2)                        %????????
xlabel('???')
ylabel('??')
s=[s1;s2];                      %?????????????
aorig=rand(size(s,1));          %??????
mixedsig=aorig*s;               %??????
ms1=mixedsig(1,:);
ms2=mixedsig(2,:);
figure                           %?????
subplot(121)
plot(ms1)                         %????????????
xlabel('???')
ylabel('??')
subplot(122)
plot(ms2)                         %????????????
xlabel('???')
ylabel('??')
icasig=INFOMAXICA(mixedsig,0.05,0.0001,1000);
is1=icasig(1,:);
is2=icasig(2,:);
figure                             %?????
subplot(121)
plot(is1)                          %????????????
xlabel('???')
ylabel('??')
subplot(122)
plot(is2)                          %????????????
xlabel('???')
ylabel('??')