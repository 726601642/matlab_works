function [Priors, Mu, Sigma] = EM_init_kmeans(Data, nbStates)
%
% This function initializes the parameters of a Gaussian Mixture Model
% (GMM) by using k-means clustering algorithm.
%
% Author:	Sylvain Calinon, 2009
%			http://programming-by-demonstration.org
%
% Inputs -----------------------------------------------------------------
%   o Data:     D x N array representing N datapoints of D dimensions.
%   o nbStates: Number K of GMM components.
% Outputs ----------------------------------------------------------------
%   o Priors:   1 x K array representing the prior probabilities of the
%               K GMM components.
%   o Mu:       D x K array representing the centers of the K GMM components.
%   o Sigma:    D x D x K array representing the covariance matrices of the
%               K GMM components.
% Comments ---------------------------------------------------------------
%   o This function uses the 'kmeans' function from the MATLAB Statistics
%     toolbox. If you are using a version of the 'netlab' toolbox that also
%     uses a function named 'kmeans', please rename the netlab function to
%     'kmeans_netlab.m' to avoid conflicts.

[nbVar,nbData]=size(Data);

%Use of the 'kmeans' function from the MATLAB Statistics toolbox
% [Data_id, Centers] = kmeans(Data', nbStates,'emptyaction','singleton');
Mu=Data(:,1:nbStates);
while(1),
    Mu_saved=Mu;
    counts=zeros(1,nbStates);
    dist=repmat(sum(Data'.^2,2),1,nbStates)-2*Data'*Mu+repmat(sum(Mu.^2,1),nbData,1);
    [c,I]=min(dist,[],2);
    Mu=zeros(nbVar,nbStates);
    for k=1:1:nbData,
        Mu(:,I(k))=Mu(:,I(k))+Data(:,k);
        counts(I(k))=counts(I(k))+1;
    end
    Mu=(Mu+Mu_saved)./(1+repmat(counts,nbVar,1));
    if(norm(Mu-Mu_saved)<1e-10),
        break;
    end
end
Priors=counts/nbData;
covs=zeros(nbVar,nbStates);
for k=1:1:nbData,
    covs(:,I(k))=covs(:,I(k))+Data(:,k).^2;
end
covs=covs./repmat(counts,nbVar,1);
covs=covs-Mu.^2;
for k=1:1:nbStates,
    Sigma(:,:,k)=diag(max(covs(:,k),1e-5));
end

% Mu = Centers';
% for i=1:nbStates
%     idtmp = find(Data_id==i);
%     Priors(i) = length(idtmp);
%     %Sigma(:,:,i) = cov([Data(:,idtmp) Data(:,idtmp)]');
%     covtmp=sum(Data(:,idtmp).^2,2)/length(idtmp)-Mu(:,i).^2;
%     Sigma(:,:,i)=diag(max(covtmp,1e-5));
%     %Add a tiny variance to avoid numerical instability
%     %Sigma(:,:,i) = Sigma(:,:,i) + 1E-5.*diag(ones(nbVar,1));
% end
% Priors = Priors ./ sum(Priors);
