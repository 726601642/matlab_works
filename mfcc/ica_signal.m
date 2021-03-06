function [out,V]=ica_signal(x,N,flag),
g=@(w,z) ((w'*z).*exp(-(w'*z).^2./2));
f=@(w,z) (1-(w'*z).^2).*exp(-(w'*z).^2./2);
r=@(w,z,L) ((w'*z).*g(w,z)*ones(L,1))./L;
G=@(W,z) (W'*z).^3;
F=@(W,z) 3*(W'*z).^2;
%G=@(W,z) (W'*z).*exp(-(W'*z).^2/2);
%F=@(W,z) (1-(W'*z).^2).*exp(-(W'*z).^2/2);
%%
[nic,L]=size(x);%#1:nch,#2:length
u=mean(x,2);
x=x-repmat(u,1,L);
s=sqrt(sum(x.^2,2)/L);
x=x./repmat(s,1,L);
cor=x*x'/L;
d=eye(nic);
pv=zeros(nic);
for m=1:1:nic,
    w=d(:,m);
    for k=1:1:64,
        w=cor*w;
        w=w-pv*(pv'*w);
        w=w/max(eps,norm(w));
    end
    pv(:,m)=w;
end
C=cor*pv;%A*v=v*D=[v1,v2]*[d1,0;0,d2]=[d1*v1,d2*v2]=[A*v1,A*v2]
eigen=sum(abs(C),1)./max(sum(abs(pv),1),eps);
[dummy,order]=sort(-eigen);
eigen=eigen(:,order);
pv=pv(:,order);
if(flag~=0),
    Iters=128;
    D=diag(eigen(:,1:N).^-0.5);
    Rw=D*pv(:,1:N)';
    z=Rw*x;%whitening
    [nic,L]=size(z);
    %Errs=zeros(Iters,nic);
    Errs=zeros(Iters,1);
    b=eye(nic);
    a=zeros(nic);
    W=zeros(nic);
    %     for n=1:1:nic,
    %         w=d(:,n);
    %         for k=1:1:Iters,
    %             c=(w'*z)*g(w,z)'/L;
    %             p=z*g(w,z)'/L;
    %             q=f(w,z)*ones(L,1)/L;
    %             w=w-0.01*(p-c*w)/(q-c);
    %             w=w-W*(W'*w);
    %             w=w/max(eps,norm(w));
    %             Errs(k,n)=norm(abs(w'*a(:,n))-1);
    %             a(:,n)=w;
    %         end
    %         W(:,n)=w;
    %     end
    %     W=W';

    for k=1:1:Iters,
        p=z*G(b,z)'/L;%E[z*g(w'*z)]-E[g'(w'*z)]*w,p=[w1,w2],E[z*(g(w'*z))]-E[g'(w'*z)]*w
        q=F(b,z)*ones(L,1)/L;%E[g'(w'*z)],g'(W'*z)*ones(L,1)/L=[a1,...,aN,b1,...,bN]*[1;...;1]
        c=sum((b'*z).*G(b,z),2)/L;
        b=b-0.01*(p-b*diag(c))*diag((q-c).^-1);
        %b=p-b*diag(q);%[v1,v2]*[d1,0;0,d2]=[d1*v1,d2*v2],D*[v1';v2']=[d1,0;0,d2]*[v1';v2']=[d1*v1';d2*v2']
        [v,dd]=eig(b'*b);
        rW=v*diag(diag(dd).^-0.5)*v';%(b'*b)^-1/2*(b'*b)*(b'*b)^-1/2=I
        b=b*rW;
        Errs(k,1)=norm(abs(b'*a)-eye(nic),'fro');
        a=b;
    end
    W=b';

    % b=zeros(nic);%(R=WV)A=PD,R=P*D*inv(A),inv(R)=A*D^-1*P=[h1,h2]*[1/d1,0;0,1/d2]*P=[h1/d1,h2/d2]*P,y=P*D*[s1;s2],inv(R)*(y=P*[d1*s1;d2*s2])=A*s
    % for m=1:1:nic,
    %     wold=zeros(nic,1);
    %     w=d(:,m);
    %     for k=1:1:32,
    %         p=z*g(w,z).'/L-r(w,z,L)*w;
    %         q=f(w,z)*ones(L,1)/L-r(w,z,L);
    %         %p=(w'*z).^3;
    %         %w=z*p'/L-3*w;
    %         %p=z*g(w,z).'/L;
    %         %q=f(w,z)*ones(L,1)/L;
    %         %w=p-q*w;
    %         w=w-p/max(eps,q);
    %         w=w-b*(b'*w);
    %         w=w/max(eps,norm(w));
    %     end
    %     b(:,m)=w;
    % end
    % W=b';
    V=W*Rw;%y=W*V*x,inv(W*V)*y=x
    P=pinv(V);
    norm_p=zeros(nic,1);
    for m=1:1:nic,
        norm_p(m,1)=norm(P(:,m));
    end
    [dummy,order]=sort(-norm_p);
    %P=P(:,order);
    norm_p=norm_p(order,:);
    %V=V(order,:);

    % for m=1:1:nic,
    %     %     wold=zeros(nic,1);
    %     %     w=d(:,m);
    %     %     w=w/norm(w);
    %     %     for k=1:1:64,
    %     %         PhatW=Phat*w;
    %     %         w=(z*((z'*w).^3))/L-2*w-conj(PhatW)*(w.'*PhatW);
    %     %         w=w-b*b'*w;
    %     %         w=w/norm(w);
    %     %         error=norm(w-wold);
    %     %         wold=w;
    %     %         dbg=[dbg;error];
    %     %     end
    %     %     b(:,m)=w;
    %     W=eye(2);
    %     for k=1:1:32,
    %         W=(z*(z'*W).^3)/L-3*W;
    %         [v,Q]=eig(W'*W);
    %         W=W*v*Q^-0.5*v';
    %         %         for n=1:1:16,
    %         %             W=W/norm(W,2);
    %         %             W=1.5*W-0.5*W*W'*W;
    %         %         end
    %     end
    % end
    %a=b'*z;
    a=W*z;
    %a=a(order,:);
    u=P*a;
    out=a(1:N,:);
else
    Rw=pv(:,1:N)';
    out=Rw*x;
end
end
