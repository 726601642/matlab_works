%FASTICA�㷨����������
clear
load('Speech4.mat');         %��������
s1=Speech4(1,:);                    %��һ������
s2=Speech4(3,:);                    %�ڶ�������
s1=s1/max(abs(s1));
s2=s2/max(abs(s2));
figure                              %��һ��ͼ��
subplot(121)                        %������ͼ
plot(s1)                            %��һ����������ͼ
xlabel('������')
ylabel('����')
subplot(122)                        %������ͼ
plot(s2)                            %�ڶ�����������ͼ
xlabel('������')
ylabel('����')
s=[s1;s2];                          %������Դ�źŷŵ�һ��������
aorig=rand(size(s,1));              %������Ͼ���
mixedsig=aorig*s;                   %��Ϲ۲��ź�
ms1=mixedsig(1,:);
ms2=mixedsig(2,:);
figure                             %�ڶ���ͼ��
subplot(121)
plot(ms1)                           %��һ����������źŲ���ͼ
xlabel('������')
ylabel('����')
subplot(122)
plot(ms2)                           %�ڶ�����������źŲ���ͼ
xlabel('������')
ylabel('����')
icasig=FASTICA(mixedsig)            %����FASTICA����
is1=icasig(1,:);
is2=icasig(2,:);
figure                             %������ͼ��
subplot(121)
plot(is1)                          %��һ�����������źŲ���ͼ
xlabel('������')
ylabel('����')
subplot(122)
plot(is2)                          %�ڶ������������źŲ���ͼ
xlabel('������')
ylabel('����')
