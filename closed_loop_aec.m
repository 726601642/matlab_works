clc;
close all;
clear all;
addpath(genpath('aec_record'));
addpath(genpath('Common'));
%%
Fs=8000;
[s1,fs]=wavread('.\CHINESE(MANDARIN)\Ch_f1');
s1=resample(s1,Fs,fs);
s1=s1/max(abs(s1));
ISM_RIR_bank(my_ISM_setup,'ISM_RIRs.mat');
AuData_s1=ISM_AudioData('ISM_RIRs.mat',s1);
[s2,fs]=wavread('.\CHINESE(MANDARIN)\Ch_m1');
s2=resample(s2,Fs,fs);
s2=s2/max(abs(s2));
ISM_RIR_bank(my_ISM_setup_i,'ISM_RIRs_i.mat');
AuData_s2=ISM_AudioData('ISM_RIRs_i.mat',s2);
[r1,c1]=size(AuData_s1);
[r2,c2]=size(AuData_s2);
idx=min(r1,r2);
% nearEnds=[AuData_s2(1:idx);AuData_s1(1:idx);AuData_s1(1:idx)+AuData_s2(1:idx)]+0.01*randn(3*idx,1);
% farEnds=[s2(1:idx);zeros(idx,1);s2(1:idx)]+0.001*randn(3*idx,1);
% fid=fopen('mic_signal1.pcm','rb');
% nearEnds=fread(fid,'short');
% fclose(fid);
% fid=fopen('speaker_signal1.pcm','rb');
% farEnds=fread(fid,'short');
% fclose(fid);
% nearEnds=nearEnds/32768;
% farEnds=farEnds/32768;
nearEnds=sin(2*pi*1000*[0:1:32767]'/8000);
nearEnds=[nearEnds;nearEnds/8];
farEnds=zeros(length(nearEnds),1);

%%
K=64;
R=K/4;
Rs=60;
L1=8*K;
%L1=K;
L2=256;
buffern=zeros(L1,1);
bufferf=zeros(L1,1);
Iters=R*floor(length(nearEnds)/R);
wins=fir1(L1-1,1/K,'low',chebwin(L1,Rs))';
%wins=ones(L1,1)/L1;
tmpnW=zeros(1+K/2,1);
tmpfW=zeros(1+K/2,1);
bufferSB=zeros(K,L1/R);
out=zeros(R,1);
error=zeros(R,1);
OutPuts=zeros(Iters+R-1,1);
ZutPuts=zeros(Iters+R-1,1);
cntr=0;
W=zeros(L2,1);
phi=zeros(1+K/2,L2/R);
wght=zeros(1+K/2,L2/R);
bufferL=zeros(L2,1);
bufferF=zeros(1+K/2,L2/R);
u=0.025;
delta=L1;
tmprF=zeros(1+K/2,1);
bufferz=zeros(delta+R,1);
gain=ones(1+K/2,1);
Snn=zeros(1+K/2,1);
preSNR=ones(1+K/2,1);
GH1=ones(1+K/2,1);
q=ones(1+K/2,1);
lambdaD=zeros(1+K/2,1);
presnr=ones(1+K/2,1);
ymem=zeros(L1,1);
dbg=[];
%%
T=-5;
Sf=zeros(1+K/2,1);
alphaA=0.75;
alphaR=0.875;
gs=zeros(1+K/2,1);
ca=zeros(1+K/2,1);
cr=zeros(1+K/2,1);
HT=10;
%%
for m=1:R:Iters,%sum_{m}x[m]*w[n-m]*W(mk,N),xn[m]=x[n+m]*w[-m],sum_{r}(sum_{l}xn[lN+(r-n)]),sum_{l}xn[lN+r]=u[(r)N],u[(r-n)N]
    for k=0:1:R-1,
        bufferL=[farEnds(m+k);bufferL(1:L2-1)];
        error(1+k,1)=nearEnds(m+k)-W'*bufferL;
    end
    buffern=[buffern(1+R:L1);error];
    bufferf=[bufferf(1+R:L1);farEnds(m:m+R-1)];%w[n-m]*x[m]*W(mk,N),w[m]*x[n-m]*W((n-m)k,N),W(nk,N)(w[m]*W(-mk,N)*x[n-m])
    tmpn=flipud(buffern.*wins(L1:-1:1));%Xn[k]*W(-nk,N),Xn(e^j(wk=2*pi*k/N))*e^j(nwk)<->u[(r-n+n)N]
    tmpf=flipud(bufferf.*wins(L1:-1:1));%farEnds
    tmpnW(1,1)=sum(tmpn(1:K:end),1);%X(e^jw)=sum_{n}x[n]*e^jwn,sum_{r}(sum_{l}x[lN+r])*e^jwkr
    tmpfW(1,1)=sum(tmpf(1:K:end),1);%farEnds
    for k=1:1:K-1,%Xn(e^jwk)*exp(jwkn)<->u[(r-n+n)N]
        tmpnW(1+k,1)=sum(tmpn(1+K-k:K:end),1);
        tmpfW(1+k,1)=sum(tmpf(1+K-k:K:end),1);
    end
    %tmpnF=fft(circshift(tmpnW,cntr),K);
    %tmpnF=fft(circshift(tmpnW,K/2),K);
    tmpnF=fft(tmpnW,K);%error
    tmpfF=fft(tmpfW,K);%farEnds
    Vk=tmpnF(1:1+K/2);
    Sf=0*Sf+1*diag(Vk*Vk');
    %dbg=[dbg;Sf(2:K/2)];
    xsc=log2(max(Sf,eps));
    xdb=xsc;
    I=find(xsc<T);
    xsc(I)=T+(xsc(I)-T)*2;
    gc=xsc-xdb;
    dbg=[dbg;gc(2:K/2)];
    I=find(gc>gs);%attack
    ca(I)=ca(I)+1;
    cr(I)=0;%clear release counter
    p=find(ca(I)>HT);
    %ca(I(p))=0;
    %gs(I(p))=alphaA*gs(I(p))+(1-alphaA)*gc(I(p));
    I=find(gc<gs);%release
    cr(I)=cr(I)+1;
    ca(I)=0;
    p=find(cr(I)>HT);
    %cr(I(p))=0;
    %gs(I(p))=alphaR*gs(I(p))+(1-alphaR)*gc(I(p));
    gs=alphaR*gs+(1-alphaR)*gc;
    %dbg=[dbg;gs(2:K/2)];
    glin=2.^gs;
    %dbg=[dbg;glin(2:K/2)];
    Vk=Vk.*glin;
    bufferF=[tmpfF(1:1+K/2,1),bufferF(:,1:L2/R-1)];
    tmprF=diag(bufferF*wght.');%[new,...,old]*[h[0],h[1],...,h[L-1]]'

    tmp=diag(Vk*Vk');
    Snn=0.875*Snn+0.125*diag(tmprF*tmprF');
    %dbg=[dbg;tmp(2:K/2)];
    postSNR=min(tmp./max(Snn,1e-12),2^16);
    %dbg=[dbg;postSNR(2:K/2)];
    ksi=(1-1/64)*gain.^2.*preSNR+(1/64)*max(postSNR-1,0);
    preSNR=postSNR;
    gain=ksi./(16+ksi);
    Vk=Vk.*gain;

    if(mod(floor((m-1)/R),32)~=0),%block-NLMS
        power=max(diag(bufferF*bufferF'),1e-4);
        for k=0:1:K/2,
            phi(1+k,:)=phi(1+k,:)+u*conj(bufferF(1+k,:))*tmpnF(1+k,1)/power(1+k);
        end
    else
        wght=wght+phi;
        phi=zeros(1+K/2,L2/R);
        W=weight_transform(wght.',K,R,L2/R);
    end
    tmpnR=real(ifft([Vk(1:1:1+K/2);conj(Vk(K/2:-1:2))],K));%Vn[k]*f[n-m]*W(-k(n-m),N),sum_{m}vn[(n-m)N]*f[n-m]
    ymem=repmat(tmpnR,L1/K,1).*wins+ymem;
    %ymem=repmat(circshift(tmpnR,-K/2),L1/K,1).*wins+ymem;
    %out=K*R*ymem(1:R);
    ymem=[ymem(1+R:end);zeros(R,1)];
    bufferSB=[tmpnR,bufferSB(:,1:L1/R-1)];%Vn[k]=Xn[k],n=rR,0,(sum_{m}V(m=rR)[k]*f[n-m])*W(-nk,N),y[n]=sum_{m}(vm[n]*f[n-m])

    for k=0:1:R-1,
        %out(1+k,1)=K*R*bufferSB(1+mod(cntr+k,K),:)*wins(1+k:R:L1);
        acc=0;%sum_{m=[n:-1:n-L+1]}vm[(n-m)N]*f[n-m],n=rR,f[0]*vn[0]+f[R]*v(n-R)[(R)N],n=rR+p,v(n-p)[(p)N]f[p]+v(n-p-R)[p+R]f[p+R]
        gins=wins(1+k:R:end);
        for p=0:1:L1/R-1,
            acc=acc+K*R*bufferSB(1+mod(k+p*R,K),1+p)*gins(1+p,1);
        end
        out(1+k,1)=acc;
    end
    %     error=bufferz(1:R)-out;
    %     buffern=[buffern(1+R:L1);error];
    %     tmpn=flipud(buffern.*wins(L1:-1:1));%error
    %     tmpnW(1,1)=sum(tmpn(1:K:end),1);%error
    %     for k=1:1:K-1,%Xn(e^jwk)*exp(jwkn)<->u[(r-n+n)N]
    %         tmpnW(1+k,1)=sum(tmpn(1+K-k:K:end),1);
    %     end
    %     tmpnF=fft(tmpnW,K);%error
    %     for k=0:1:K/2,
    %         wght(1+k,:)=wght(1+k,:)+u*conj(bufferF(1+k,:))*tmpnF(1+k,1)/max(1e-4,bufferF(1+k,:)*bufferF(1+k,:)');
    %     end
    ZutPuts(m:m+R-1,1)=error;
    OutPuts(m:m+R-1,1)=out;
    cntr=mod(cntr+R,K);
end
