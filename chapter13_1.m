%���ȷֲ�����źŵ����ֻ����任
clear
t=0:0.05:100;                          %����ʱ���ź�
s1=sin(0.5*t);                          %��һ��Դ�ź�
s2=2*rand(size(s1))-1;                   %�ڶ���Դ�ź�
s=[s1;s2];                              %������Դ�źŷŵ�һ��������
aorig=rand(size(s,1));                     %������Ͼ���
mixedsig=aorig*s;                       %��Ϲ۲��ź�
ms1=mixedsig(1,:);
ms2=mixedsig(2,:);
whitesig=whitening(mixedsig);             %�׻�����
figure                                 %��һ��ͼ��
plot(s1,s2,'k.')                           %Դ�źŵı����ܶȷֲ�ͼ
axis([-1.5,1.5,-1.5,1.5])                   %����������
figure                                 %�ڶ���ͼ��
plot(ms1,ms2,'k.')                      %��Ϻ��źŵı����ܶȷֲ�ͼ
axis([-1.5,1.5,-1.5,1.5])
figure                                %������ͼ��
wis1= whitesig(1,:)
wis2= whitesig(2,:)
plot(wis1, wis2,'k.')                     %�׻����źŵı����ܶȷֲ�ͼ
axis([-3,3,-3,3])
% icasig=FASTICA(mixedsig)             %����FSATICA����
icasig=INFOMAXICA(mixedsig,0.025,0.0001,1000)
is1=icasig(1,:);
is2=icasig(2,:);
figure                                %���ĸ�ͼ��
plot(is1,is2,'k.')                        % ICA������źŵı����ܶȷֲ�ͼ
axis([-2,2,-2,2])
