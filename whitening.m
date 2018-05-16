function  [whitesig,whiteningmatrix]=whitening(mixedsig)
% ����mixedsig �ǻ���ź�
% ���whitsig�׻��źţ�whiteningmatrix�ǰ׻�����
omixedsig=zeros(size(mixedsig));             %������ֵ
mixedmean=mean(mixedsig')';                  %����źŵľ�ֵ
omixedsig=mixedsig-mixedmean*ones(1,length(mixedsig)); %ȥ��ֵ����
covariancematrix=cov(omixedsig',1);
[e,d]=eig(covariancematrix);
eigenvalues=flipud(sort(diag(d)));
whiteningmatrix=inv(sqrt(d)+0.01*eye(2))*e';             %��ð׻�����
dewhiteningmatrix=e*sqrt(d);
whitesig=whiteningmatrix*mixedsig;            %�׻�����
