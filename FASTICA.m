function [icasig,W]=FASTICA(mixedsig)
% ����mixedsig�ǻ���ź�
% ���icasig �ǻָ��źţ� W �ǽ�����
mixedmean=mean(mixedsig')';                       %����źŵľ�ֵ
[x, whiteningmatrix ]=whitening(mixedsig)             %�׻�����
[vectorsize,numsamples]=size(x);                     %����Ĵ�С
b=zeros(vectorsize);
numofic=vectorsize
for r=1:numofic
    i=1;
    maxnumiterations=5000;                         %����������
    w=[1;0];                        %���������ֵ
    w=w/norm(w);
    while i<=maxnumiterations+1
        w=(x*((x'*w).^3))/numsamples-3*w;
        w=w/norm(w);
        w=w-b*b'*w;
        w=w/norm(w);
        i=i+1;
    end
W(r,:)=w'*whiteningmatrix;                            %������
b(:,r)=w;
   end
icasig=W*mixedsig+(W*mixedmean)*ones(1,numsamples);  %�ָ�Դ�ź�
