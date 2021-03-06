function Sim_13(nSubj,SvNm,nRlz)
%
% Creates a 2D images of linearly increasing signal from L to R, and then applies the standardized effects Contour Inference method
% for each of the proposed options
%


%------------Starting Up initialization
if (nargin<1)
  nSubj  = 60;  % Number of subjects
end
if (nargin<2)
  SvNm  = 'Normsim';  % Save name
end
if (nargin<3)
  nRlz = 5000;
end  
if exist([SvNm '.mat'], 'file')
  error('Will not overwrite sim result')
end

%------------Define parameters
% SvNm = 'LinearSig';
% nSubj  = 120;
% nRlz = 300;

tau     = 1/sqrt(nSubj);
nBoot   = 5000;
dim     = [100 100]; 
mag     = 3;
smo     = 10;
rimFWHM = 15; 				 
stdblk  = prod(dim([1 2])/2);
thr     = 2;
rad     = 30;

%-----------Initialization of Some Variables
V           = prod(dim);   
wdim        = dim + 2*ceil(rimFWHM*smo*ones(1,2));  % Working image dimension
trunc_x     = {(ceil(rimFWHM*smo)+1):(ceil(rimFWHM*smo)+dim(1))};
trunc_y     = {(ceil(rimFWHM*smo)+1):(ceil(rimFWHM*smo)+dim(2))};
trnind      = cat(2, trunc_x, trunc_y);

observed_data  = zeros([dim nSubj]);
raw_noise      = zeros([wdim nSubj]);

% This stores the vector SupG for each run
% This vector stores the result for each realisation on whether AC^+ < AC < AC^ for each level of smoothing (1 if true, 0 if false) 
subset_success_vector_raw_80           = zeros(nRlz, 1); 
subset_success_vector_raw_90           = zeros(nRlz, 1);
subset_success_vector_raw_95           = zeros(nRlz, 1);

subset_success_vector_raw_80_ero       = zeros(nRlz, 1); 
subset_success_vector_raw_90_ero       = zeros(nRlz, 1);
subset_success_vector_raw_95_ero       = zeros(nRlz, 1);

subset_success_vector_raw_80_dil       = zeros(nRlz, 1); 
subset_success_vector_raw_90_dil       = zeros(nRlz, 1);
subset_success_vector_raw_95_dil       = zeros(nRlz, 1);

subset_success_vector_raw_80_ero_dil   = zeros(nRlz, 1); 
subset_success_vector_raw_90_ero_dil   = zeros(nRlz, 1);
subset_success_vector_raw_95_ero_dil   = zeros(nRlz, 1); 

subset_success_vector_raw_80_linear    = zeros(nRlz, 1); 
subset_success_vector_raw_90_linear    = zeros(nRlz, 1);
subset_success_vector_raw_95_linear    = zeros(nRlz, 1); 

%- This vector stores the threshold value 'c' for each run
threshold_raw_80_store                  = zeros(nRlz, 1);
threshold_raw_90_store                  = zeros(nRlz, 1);
threshold_raw_95_store                  = zeros(nRlz, 1);

threshold_raw_80_ero_store              = zeros(nRlz, 1);
threshold_raw_90_ero_store              = zeros(nRlz, 1);
threshold_raw_95_ero_store              = zeros(nRlz, 1);

threshold_raw_80_dil_store              = zeros(nRlz, 1);
threshold_raw_90_dil_store              = zeros(nRlz, 1);
threshold_raw_95_dil_store              = zeros(nRlz, 1);

threshold_raw_80_ero_dil_store          = zeros(nRlz, 1);
threshold_raw_90_ero_dil_store          = zeros(nRlz, 1);
threshold_raw_95_ero_dil_store          = zeros(nRlz, 1);

threshold_raw_80_linear_store           = zeros(nRlz, 1);
threshold_raw_90_linear_store           = zeros(nRlz, 1);
threshold_raw_95_linear_store           = zeros(nRlz, 1);

%- This vector stores the percentage volumes A^+_c/A_c, A^_c/A_c, A^-_c/A_c
lower_contour_raw_80_volume_prct_store          = zeros(nRlz, 1);
upper_contour_raw_80_volume_prct_store          = zeros(nRlz, 1);
lower_contour_raw_80_ero_volume_prct_store      = zeros(nRlz, 1);
upper_contour_raw_80_ero_volume_prct_store      = zeros(nRlz, 1);
lower_contour_raw_80_dil_volume_prct_store      = zeros(nRlz, 1);
upper_contour_raw_80_dil_volume_prct_store      = zeros(nRlz, 1);
lower_contour_raw_80_ero_dil_volume_prct_store  = zeros(nRlz, 1);
upper_contour_raw_80_ero_dil_volume_prct_store  = zeros(nRlz, 1);
lower_contour_raw_80_linear_volume_prct_store   = zeros(nRlz, 1);
upper_contour_raw_80_linear_volume_prct_store   = zeros(nRlz, 1);

lower_contour_raw_90_volume_prct_store          = zeros(nRlz, 1);
upper_contour_raw_90_volume_prct_store          = zeros(nRlz, 1);
lower_contour_raw_90_ero_volume_prct_store      = zeros(nRlz, 1);
upper_contour_raw_90_ero_volume_prct_store      = zeros(nRlz, 1);
lower_contour_raw_90_dil_volume_prct_store      = zeros(nRlz, 1);
upper_contour_raw_90_dil_volume_prct_store      = zeros(nRlz, 1);
lower_contour_raw_90_ero_dil_volume_prct_store  = zeros(nRlz, 1);
upper_contour_raw_90_ero_dil_volume_prct_store  = zeros(nRlz, 1);
lower_contour_raw_90_linear_volume_prct_store   = zeros(nRlz, 1);
upper_contour_raw_90_linear_volume_prct_store   = zeros(nRlz, 1);

lower_contour_raw_95_volume_prct_store          = zeros(nRlz, 1);
upper_contour_raw_95_volume_prct_store          = zeros(nRlz, 1);
lower_contour_raw_95_ero_volume_prct_store      = zeros(nRlz, 1);
upper_contour_raw_95_ero_volume_prct_store      = zeros(nRlz, 1);
lower_contour_raw_95_dil_volume_prct_store      = zeros(nRlz, 1);
upper_contour_raw_95_dil_volume_prct_store      = zeros(nRlz, 1);
lower_contour_raw_95_ero_dil_volume_prct_store  = zeros(nRlz, 1);
upper_contour_raw_95_ero_dil_volume_prct_store  = zeros(nRlz, 1);
lower_contour_raw_95_linear_volume_prct_store   = zeros(nRlz, 1);
upper_contour_raw_95_linear_volume_prct_store   = zeros(nRlz, 1);

% This stores the vector SupG for each run
supG_raw_store         = zeros(nBoot, nRlz);
supG_raw_ero_store     = zeros(nBoot, nRlz);
supG_raw_dil_store     = zeros(nBoot, nRlz);
supG_raw_ero_dil_store = zeros(nBoot, nRlz);
supG_raw_linear_store  = zeros(nBoot, nRlz);

%-These matrices store all the sets of interest during the bootstrap
% method for all levels of smoothing
lower_contour_raw_80_store                       = zeros([nRlz dim]);
upper_contour_raw_80_store                       = zeros([nRlz dim]);
upper_subset_mid_raw_80_store                    = zeros([nRlz dim]);
mid_subset_lower_raw_80_store                    = zeros([nRlz dim]);
lower_contour_raw_80_ero_store                   = zeros([nRlz dim]);
upper_contour_raw_80_ero_store                   = zeros([nRlz dim]);
upper_subset_mid_raw_80_ero_store                = zeros([nRlz dim]);
mid_subset_lower_raw_80_ero_store                = zeros([nRlz dim]);
lower_contour_raw_80_dil_store                   = zeros([nRlz dim]);
upper_contour_raw_80_dil_store                   = zeros([nRlz dim]);
upper_subset_mid_raw_80_dil_store                = zeros([nRlz dim]);
mid_subset_lower_raw_80_dil_store                = zeros([nRlz dim]);
lower_contour_raw_80_ero_dil_store               = zeros([nRlz dim]);
upper_contour_raw_80_ero_dil_store               = zeros([nRlz dim]);
upper_subset_mid_raw_80_ero_dil_store            = zeros([nRlz dim]);
mid_subset_lower_raw_80_ero_dil_store            = zeros([nRlz dim]);
lower_contour_raw_80_linear_store                = zeros([nRlz dim]);
upper_contour_raw_80_linear_store                = zeros([nRlz dim]);
upper_subset_mid_raw_80_linear_store             = zeros([nRlz dim]);
mid_subset_lower_raw_80_linear_store             = zeros([nRlz dim]);

lower_contour_raw_90_store                       = zeros([nRlz dim]);
upper_contour_raw_90_store                       = zeros([nRlz dim]);
upper_subset_mid_raw_90_store                    = zeros([nRlz dim]);
mid_subset_lower_raw_90_store                    = zeros([nRlz dim]);
lower_contour_raw_90_ero_store                   = zeros([nRlz dim]);
upper_contour_raw_90_ero_store                   = zeros([nRlz dim]);
upper_subset_mid_raw_90_ero_store                = zeros([nRlz dim]);
mid_subset_lower_raw_90_ero_store                = zeros([nRlz dim]);
lower_contour_raw_90_dil_store                   = zeros([nRlz dim]);
upper_contour_raw_90_dil_store                   = zeros([nRlz dim]);
upper_subset_mid_raw_90_dil_store                = zeros([nRlz dim]);
mid_subset_lower_raw_90_dil_store                = zeros([nRlz dim]);
lower_contour_raw_90_ero_dil_store               = zeros([nRlz dim]);
upper_contour_raw_90_ero_dil_store               = zeros([nRlz dim]);
upper_subset_mid_raw_90_ero_dil_store            = zeros([nRlz dim]);
mid_subset_lower_raw_90_ero_dil_store            = zeros([nRlz dim]);
lower_contour_raw_90_linear_store                = zeros([nRlz dim]);
upper_contour_raw_90_linear_store                = zeros([nRlz dim]);
upper_subset_mid_raw_90_linear_store             = zeros([nRlz dim]);
mid_subset_lower_raw_90_linear_store             = zeros([nRlz dim]);

lower_contour_raw_95_store                       = zeros([nRlz dim]);
upper_contour_raw_95_store                       = zeros([nRlz dim]);
upper_subset_mid_raw_95_store                    = zeros([nRlz dim]);
mid_subset_lower_raw_95_store                    = zeros([nRlz dim]);
lower_contour_raw_95_ero_store                   = zeros([nRlz dim]);
upper_contour_raw_95_ero_store                   = zeros([nRlz dim]);
upper_subset_mid_raw_95_ero_store                = zeros([nRlz dim]);
mid_subset_lower_raw_95_ero_store                = zeros([nRlz dim]);
lower_contour_raw_95_dil_store                   = zeros([nRlz dim]);
upper_contour_raw_95_dil_store                   = zeros([nRlz dim]);
upper_subset_mid_raw_95_dil_store                = zeros([nRlz dim]);
mid_subset_lower_raw_95_dil_store                = zeros([nRlz dim]);
lower_contour_raw_95_ero_dil_store               = zeros([nRlz dim]);
upper_contour_raw_95_ero_dil_store               = zeros([nRlz dim]);
upper_subset_mid_raw_95_ero_dil_store            = zeros([nRlz dim]);
mid_subset_lower_raw_95_ero_dil_store            = zeros([nRlz dim]);
lower_contour_raw_95_linear_store                = zeros([nRlz dim]);
upper_contour_raw_95_linear_store                = zeros([nRlz dim]);
upper_subset_mid_raw_95_linear_store             = zeros([nRlz dim]);
mid_subset_lower_raw_95_linear_store             = zeros([nRlz dim]);

supG_raw              = zeros(nBoot,1);
supG_raw_ero          = zeros(nBoot,1);
supG_raw_dil          = zeros(nBoot,1);
supG_raw_ero_dil      = zeros(nBoot,1);
supG_raw_linear       = zeros(nBoot,1);

% Creating linearly increasing signal across columns
Sig = CircularSignal(wdim, rad, mag, 0);

% Smoothing the signal
[Sigs,ss]      = spm_conv(Sig,smo,smo);

% Truncate to avoid edge effects
tSigs          = Sigs(trnind{1}, trnind{2});
maxtSigs       = max(tSigs(:));
Sig            = (mag/maxtSigs)*tSigs;

% Uncomment to look at the Signal
%imagesc(Sig); axis image; colorbar
AC = Sig >= thr;

% Variables for computing the estimated boundary
[a,b] = ndgrid(-1:1);
se = strel('arbitrary',sqrt(a.^2 + b.^2) <=1);

% Obtaining the edges for the boundary Sig > 2 using the linear interpolation methods 
  % Making the interpolated boundary edges
  % Horizontal edges
  horz = AC(:,2:end) | AC(:,1:end-1);
  % Compute the left shifted horizontal edges
  lshift            = AC; % initialize
  lshift(:,1:end-1) = horz;
  lshift            = lshift & ~AC;
  %%% Compute the right shifted horizontal edges
  rshift          = AC; % initialize
  rshift(:,2:end) = horz;
  rshift          = rshift & ~AC;
  % Vertical edges
  vert = AC(1:end-1,:) | AC(2:end,:);
  %%% Compute the right shifted horizontal edges
  ushift = AC;
  ushift(1:end-1,:) = vert;
  ushift = ushift & ~AC;
  %%% Compute the down shifted vertical edges
  dshift = AC;
  %%% Values of random field on down shifted vertical edges
  dshift(2:end,:)   = vert;
  dshift = dshift & ~AC;

for t=1:nRlz
    fprintf('.');
      for i=1:nSubj
	    %
	    % Generate random realizations of signal + noise
	    %
        raw_noise(:,:,i) = randn(wdim); %- Noise that will be added to the signal 

        %
        % smooth noise  
        %
        [Noises,tt] = spm_conv(raw_noise(:,:,i),smo,smo);
        Noises = Noises/sqrt(tt);      
      
        %
        % Truncate to avoid edge effects
        %
        tNoises = Noises(trnind{1},trnind{2});       
        tImgs = Sig + tNoises; % Creates the true image of smoothed signal + smoothed noise
        observed_data(:,:,i) = tImgs;
        
      end %========== Loop i (subjects)

      observed_mean = mean(observed_data,3);

      observed_std = reshape(...
         biasmystd(reshape(observed_data,[prod(dim) nSubj]),stdblk),...
           dim);
       
      % Making the three observed boundaries: dilated boundary, eroded
      % boundary, and dilated - eroded boundary.
      observed_AC = observed_mean >= thr;
      observed_AC_volume = sum(observed_AC(:)); 
      observed_AC_ero = imerode(observed_AC,se);
      observed_AC_dil = imdilate(observed_AC,se);
      observed_delta_AC_ero = observed_AC - observed_AC_ero;
      observed_delta_AC_ero = logical(observed_delta_AC_ero);
      observed_delta_AC_dil = observed_AC_dil - observed_AC;
      observed_delta_AC_dil = logical(observed_delta_AC_dil);
      observed_delta_AC_ero_dil = (observed_AC_dil - observed_AC)|(observed_AC - observed_AC_ero);
      observed_delta_AC_ero_dil = logical(observed_delta_AC_ero_dil);

      % Making the interpolated boundary edges
      % Horizontal edges
      observed_horz = observed_AC(:,2:end) | observed_AC(:,1:end-1);
      % Compute the left shifted horizontal edges
      observed_lshift            = observed_AC; % initialize
      observed_lshift(:,1:end-1) = observed_horz;
      observed_lshift            = observed_lshift & ~observed_AC;
      %%% Compute the right shifted horizontal edges
      observed_rshift          = observed_AC; % initialize
      observed_rshift(:,2:end) = observed_horz;
      observed_rshift          = observed_rshift & ~observed_AC;
      % Vertical edges
      vert = observed_AC(1:end-1,:) | observed_AC(2:end,:);
      %%% Compute the right shifted horizontal edges
      observed_ushift = observed_AC;
      observed_ushift(1:end-1,:) = vert;
      observed_ushift = observed_ushift & ~observed_AC;
      %%% Compute the down shifted vertical edges
      observed_dshift = observed_AC;
      %%% Values of random field on down shifted vertical edges
      observed_dshift(2:end,:)   = vert;
      observed_dshift = observed_dshift & ~observed_AC;
 
      % Residuals
      resid = bsxfun(@minus,observed_data,observed_mean);
      resid = spdiags(1./reshape(observed_std, [prod(dim) 1]), 0,prod(dim),prod(dim))*reshape(resid,[prod(dim) nSubj]); 
            
      % Implementing the Multiplier Boostrap to obtain confidence intervals
      for k=1:nBoot 
          % Applying the bootstrap using Rademacher variables (signflips)
          signflips                              = randi(2,[nSubj,1])*2-3;
          resid_bootstrap                        = resid*spdiags(signflips, 0, nSubj, nSubj);
          resid_bootstrap                        = reshape(resid_bootstrap, [dim nSubj]);
          resid_field                            = sum(resid_bootstrap, 3)/sqrt(nSubj); 

          % Calculating the maximum over the linear true boundary edges
          lshift_boundary_values = abs((resid_field(lshift) + resid_field(lshift(:,[dim(2) 1:dim(2)-1])))/2);
          rshift_boundary_values = abs((resid_field(rshift) + resid_field(rshift(:,[2:dim(2) 1])))/2);
          ushift_boundary_values = abs((resid_field(ushift) + resid_field(ushift([dim(1) 1:dim(1)-1],:)))/2);
          dshift_boundary_values = abs((resid_field(dshift) + resid_field(dshift([2:dim(1) 1],:)))/2);
          supG_raw(k)          = max([lshift_boundary_values; rshift_boundary_values; ushift_boundary_values; dshift_boundary_values]);
          
          % Other boundary methods
          supG_raw_ero(k)      = max(abs(resid_field(observed_delta_AC_ero)));
          supG_raw_dil(k)      = max(abs(resid_field(observed_delta_AC_dil)));
          supG_raw_ero_dil(k)  = max(abs(resid_field(observed_delta_AC_ero_dil)));
          
          % Calculating the maximum over the linear observed boundary edges
          observed_lshift_boundary_values = abs((resid_field(observed_lshift) + resid_field(observed_lshift(:,[dim(2) 1:dim(2)-1])))/2);
          observed_rshift_boundary_values = abs((resid_field(observed_rshift) + resid_field(observed_rshift(:,[2:dim(2) 1])))/2);
          observed_ushift_boundary_values = abs((resid_field(observed_ushift) + resid_field(observed_ushift([dim(1) 1:dim(1)-1],:)))/2);
          observed_dshift_boundary_values = abs((resid_field(observed_dshift) + resid_field(observed_dshift([2:dim(1) 1],:)))/2);
          supG_raw_linear(k)   = max([observed_lshift_boundary_values; observed_rshift_boundary_values; observed_ushift_boundary_values; observed_dshift_boundary_values]);
      end
      
    middle_contour                = AC;
    middle_contour_volume         = sum(middle_contour(:));
    
    % Gaussian random variable results for the true and estimated boundary
    % True boundary
    supGa_raw_80                     = prctile(supG_raw, 80);
    supGa_raw_90                     = prctile(supG_raw, 90);
    supGa_raw_95                     = prctile(supG_raw, 95);
       
    lower_contour_raw_80             = observed_mean >= thr - supGa_raw_80*tau*observed_std;
    upper_contour_raw_80             = observed_mean >= thr + supGa_raw_80*tau*observed_std;
    lower_contour_raw_80_volume_prct = sum(lower_contour_raw_80(:))/middle_contour_volume;
    upper_contour_raw_80_volume_prct = sum(upper_contour_raw_80(:))/middle_contour_volume;
    mid_on_upper_raw_80              = upper_contour_raw_80.*middle_contour;
    lower_on_mid_raw_80              = middle_contour.*lower_contour_raw_80;
    upper_subset_mid_raw_80          = upper_contour_raw_80 - mid_on_upper_raw_80;
    mid_subset_lower_raw_80          = middle_contour - lower_on_mid_raw_80;
    
    lower_contour_raw_90             = observed_mean >= thr - supGa_raw_90*tau*observed_std;
    upper_contour_raw_90             = observed_mean >= thr + supGa_raw_90*tau*observed_std;
    lower_contour_raw_90_volume_prct = sum(lower_contour_raw_90(:))/middle_contour_volume;
    upper_contour_raw_90_volume_prct = sum(upper_contour_raw_90(:))/middle_contour_volume;
    mid_on_upper_raw_90              = upper_contour_raw_90.*middle_contour;
    lower_on_mid_raw_90              = middle_contour.*lower_contour_raw_90;
    upper_subset_mid_raw_90          = upper_contour_raw_90 - mid_on_upper_raw_90;
    mid_subset_lower_raw_90          = middle_contour - lower_on_mid_raw_90;    
    
    lower_contour_raw_95             = observed_mean >= thr - supGa_raw_95*tau*observed_std;
    upper_contour_raw_95             = observed_mean >= thr + supGa_raw_95*tau*observed_std;
    lower_contour_raw_95_volume_prct = sum(lower_contour_raw_95(:))/middle_contour_volume;
    upper_contour_raw_95_volume_prct = sum(upper_contour_raw_95(:))/middle_contour_volume;
    mid_on_upper_raw_95              = upper_contour_raw_95.*middle_contour;
    lower_on_mid_raw_95              = middle_contour.*lower_contour_raw_95;
    upper_subset_mid_raw_95          = upper_contour_raw_95 - mid_on_upper_raw_95;
    mid_subset_lower_raw_95          = middle_contour - lower_on_mid_raw_95;

    % Eroded Boundary
    supGa_raw_80_ero                     = prctile(supG_raw_ero, 80);
    supGa_raw_90_ero                     = prctile(supG_raw_ero, 90);
    supGa_raw_95_ero                     = prctile(supG_raw_ero, 95);
       
    lower_contour_raw_80_ero             = observed_mean >= thr - supGa_raw_80_ero*tau*observed_std;
    upper_contour_raw_80_ero             = observed_mean >= thr + supGa_raw_80_ero*tau*observed_std;
    lower_contour_raw_80_ero_volume_prct = sum(lower_contour_raw_80_ero(:))/middle_contour_volume;
    upper_contour_raw_80_ero_volume_prct = sum(upper_contour_raw_80_ero(:))/middle_contour_volume;
    mid_on_upper_raw_80_ero              = upper_contour_raw_80_ero.*middle_contour;
    lower_on_mid_raw_80_ero              = middle_contour.*lower_contour_raw_80_ero;
    upper_subset_mid_raw_80_ero          = upper_contour_raw_80_ero - mid_on_upper_raw_80_ero;
    mid_subset_lower_raw_80_ero          = middle_contour - lower_on_mid_raw_80_ero;
    
    lower_contour_raw_90_ero             = observed_mean >= thr - supGa_raw_90_ero*tau*observed_std;
    upper_contour_raw_90_ero             = observed_mean >= thr + supGa_raw_90_ero*tau*observed_std;
    lower_contour_raw_90_ero_volume_prct = sum(lower_contour_raw_90_ero(:))/middle_contour_volume;
    upper_contour_raw_90_ero_volume_prct = sum(upper_contour_raw_90_ero(:))/middle_contour_volume;
    mid_on_upper_raw_90_ero              = upper_contour_raw_90_ero.*middle_contour;
    lower_on_mid_raw_90_ero              = middle_contour.*lower_contour_raw_90_ero;
    upper_subset_mid_raw_90_ero          = upper_contour_raw_90_ero - mid_on_upper_raw_90_ero;
    mid_subset_lower_raw_90_ero          = middle_contour - lower_on_mid_raw_90_ero;    
    
    lower_contour_raw_95_ero             = observed_mean >= thr - supGa_raw_95_ero*tau*observed_std;
    upper_contour_raw_95_ero             = observed_mean >= thr + supGa_raw_95_ero*tau*observed_std;
    lower_contour_raw_95_ero_volume_prct = sum(lower_contour_raw_95_ero(:))/middle_contour_volume;
    upper_contour_raw_95_ero_volume_prct = sum(upper_contour_raw_95_ero(:))/middle_contour_volume;
    mid_on_upper_raw_95_ero              = upper_contour_raw_95_ero.*middle_contour;
    lower_on_mid_raw_95_ero              = middle_contour.*lower_contour_raw_95_ero;
    upper_subset_mid_raw_95_ero          = upper_contour_raw_95_ero - mid_on_upper_raw_95_ero;
    mid_subset_lower_raw_95_ero          = middle_contour - lower_on_mid_raw_95_ero;

    % Dilated Boundary
    supGa_raw_80_dil                     = prctile(supG_raw_dil, 80);
    supGa_raw_90_dil                     = prctile(supG_raw_dil, 90);
    supGa_raw_95_dil                     = prctile(supG_raw_dil, 95);
       
    lower_contour_raw_80_dil             = observed_mean >= thr - supGa_raw_80_dil*tau*observed_std;
    upper_contour_raw_80_dil             = observed_mean >= thr + supGa_raw_80_dil*tau*observed_std;
    lower_contour_raw_80_dil_volume_prct = sum(lower_contour_raw_80_dil(:))/middle_contour_volume;
    upper_contour_raw_80_dil_volume_prct = sum(upper_contour_raw_80_dil(:))/middle_contour_volume;
    mid_on_upper_raw_80_dil              = upper_contour_raw_80_dil.*middle_contour;
    lower_on_mid_raw_80_dil              = middle_contour.*lower_contour_raw_80_dil;
    upper_subset_mid_raw_80_dil          = upper_contour_raw_80_dil - mid_on_upper_raw_80_dil;
    mid_subset_lower_raw_80_dil          = middle_contour - lower_on_mid_raw_80_dil;
    
    lower_contour_raw_90_dil             = observed_mean >= thr - supGa_raw_90_dil*tau*observed_std;
    upper_contour_raw_90_dil             = observed_mean >= thr + supGa_raw_90_dil*tau*observed_std;
    lower_contour_raw_90_dil_volume_prct = sum(lower_contour_raw_90_dil(:))/middle_contour_volume;
    upper_contour_raw_90_dil_volume_prct = sum(upper_contour_raw_90_dil(:))/middle_contour_volume;
    mid_on_upper_raw_90_dil              = upper_contour_raw_90_dil.*middle_contour;
    lower_on_mid_raw_90_dil              = middle_contour.*lower_contour_raw_90_dil;
    upper_subset_mid_raw_90_dil          = upper_contour_raw_90_dil - mid_on_upper_raw_90_dil;
    mid_subset_lower_raw_90_dil          = middle_contour - lower_on_mid_raw_90_dil;    
    
    lower_contour_raw_95_dil             = observed_mean >= thr - supGa_raw_95_dil*tau*observed_std;
    upper_contour_raw_95_dil             = observed_mean >= thr + supGa_raw_95_dil*tau*observed_std;
    lower_contour_raw_95_dil_volume_prct = sum(lower_contour_raw_95_dil(:))/middle_contour_volume;
    upper_contour_raw_95_dil_volume_prct = sum(upper_contour_raw_95_dil(:))/middle_contour_volume;
    mid_on_upper_raw_95_dil              = upper_contour_raw_95_dil.*middle_contour;
    lower_on_mid_raw_95_dil              = middle_contour.*lower_contour_raw_95_dil;
    upper_subset_mid_raw_95_dil          = upper_contour_raw_95_dil - mid_on_upper_raw_95_dil;
    mid_subset_lower_raw_95_dil          = middle_contour - lower_on_mid_raw_95_dil;

    % Eroded + Dilated Boundary
    supGa_raw_80_ero_dil                     = prctile(supG_raw_ero_dil, 80);
    supGa_raw_90_ero_dil                     = prctile(supG_raw_ero_dil, 90);
    supGa_raw_95_ero_dil                     = prctile(supG_raw_ero_dil, 95);
       
    lower_contour_raw_80_ero_dil             = observed_mean >= thr - supGa_raw_80_ero_dil*tau*observed_std;
    upper_contour_raw_80_ero_dil             = observed_mean >= thr + supGa_raw_80_ero_dil*tau*observed_std;
    lower_contour_raw_80_ero_dil_volume_prct = sum(lower_contour_raw_80_ero_dil(:))/middle_contour_volume;
    upper_contour_raw_80_ero_dil_volume_prct = sum(upper_contour_raw_80_ero_dil(:))/middle_contour_volume;
    mid_on_upper_raw_80_ero_dil              = upper_contour_raw_80_ero_dil.*middle_contour;
    lower_on_mid_raw_80_ero_dil              = middle_contour.*lower_contour_raw_80_ero_dil;
    upper_subset_mid_raw_80_ero_dil          = upper_contour_raw_80_ero_dil - mid_on_upper_raw_80_ero_dil;
    mid_subset_lower_raw_80_ero_dil          = middle_contour - lower_on_mid_raw_80_ero_dil;
    
    lower_contour_raw_90_ero_dil             = observed_mean >= thr - supGa_raw_90_ero_dil*tau*observed_std;
    upper_contour_raw_90_ero_dil             = observed_mean >= thr + supGa_raw_90_ero_dil*tau*observed_std;
    lower_contour_raw_90_ero_dil_volume_prct = sum(lower_contour_raw_90_ero_dil(:))/middle_contour_volume;
    upper_contour_raw_90_ero_dil_volume_prct = sum(upper_contour_raw_90_ero_dil(:))/middle_contour_volume;
    mid_on_upper_raw_90_ero_dil              = upper_contour_raw_90_ero_dil.*middle_contour;
    lower_on_mid_raw_90_ero_dil              = middle_contour.*lower_contour_raw_90_ero_dil;
    upper_subset_mid_raw_90_ero_dil          = upper_contour_raw_90_ero_dil - mid_on_upper_raw_90_ero_dil;
    mid_subset_lower_raw_90_ero_dil          = middle_contour - lower_on_mid_raw_90_ero_dil;    
    
    lower_contour_raw_95_ero_dil             = observed_mean >= thr - supGa_raw_95_ero_dil*tau*observed_std;
    upper_contour_raw_95_ero_dil             = observed_mean >= thr + supGa_raw_95_ero_dil*tau*observed_std;
    lower_contour_raw_95_ero_dil_volume_prct = sum(lower_contour_raw_95_ero_dil(:))/middle_contour_volume;
    upper_contour_raw_95_ero_dil_volume_prct = sum(upper_contour_raw_95_ero_dil(:))/middle_contour_volume;
    mid_on_upper_raw_95_ero_dil              = upper_contour_raw_95_ero_dil.*middle_contour;
    lower_on_mid_raw_95_ero_dil              = middle_contour.*lower_contour_raw_95_ero_dil;
    upper_subset_mid_raw_95_ero_dil          = upper_contour_raw_95_ero_dil - mid_on_upper_raw_95_ero_dil;
    mid_subset_lower_raw_95_ero_dil          = middle_contour - lower_on_mid_raw_95_ero_dil;

    % Linear Boundary
    supGa_raw_80_linear                     = prctile(supG_raw_linear, 80);
    supGa_raw_90_linear                     = prctile(supG_raw_linear, 90);
    supGa_raw_95_linear                     = prctile(supG_raw_linear, 95);
       
    lower_contour_raw_80_linear             = observed_mean >= thr - supGa_raw_80_linear*tau*observed_std;
    upper_contour_raw_80_linear             = observed_mean >= thr + supGa_raw_80_linear*tau*observed_std;
    lower_contour_raw_80_linear_volume_prct = sum(lower_contour_raw_80_linear(:))/middle_contour_volume;
    upper_contour_raw_80_linear_volume_prct = sum(upper_contour_raw_80_linear(:))/middle_contour_volume;
    mid_on_upper_raw_80_linear              = upper_contour_raw_80_linear.*middle_contour;
    lower_on_mid_raw_80_linear              = middle_contour.*lower_contour_raw_80_linear;
    upper_subset_mid_raw_80_linear          = upper_contour_raw_80_linear - mid_on_upper_raw_80_linear;
    mid_subset_lower_raw_80_linear          = middle_contour - lower_on_mid_raw_80_linear;
    
    lower_contour_raw_90_linear             = observed_mean >= thr - supGa_raw_90_linear*tau*observed_std;
    upper_contour_raw_90_linear             = observed_mean >= thr + supGa_raw_90_linear*tau*observed_std;
    lower_contour_raw_90_linear_volume_prct = sum(lower_contour_raw_90_linear(:))/middle_contour_volume;
    upper_contour_raw_90_linear_volume_prct = sum(upper_contour_raw_90_linear(:))/middle_contour_volume;
    mid_on_upper_raw_90_linear              = upper_contour_raw_90_linear.*middle_contour;
    lower_on_mid_raw_90_linear              = middle_contour.*lower_contour_raw_90_linear;
    upper_subset_mid_raw_90_linear          = upper_contour_raw_90_linear - mid_on_upper_raw_90_linear;
    mid_subset_lower_raw_90_linear          = middle_contour - lower_on_mid_raw_90_linear;    
    
    lower_contour_raw_95_linear             = observed_mean >= thr - supGa_raw_95_linear*tau*observed_std;
    upper_contour_raw_95_linear             = observed_mean >= thr + supGa_raw_95_linear*tau*observed_std;
    lower_contour_raw_95_linear_volume_prct = sum(lower_contour_raw_95_linear(:))/middle_contour_volume;
    upper_contour_raw_95_linear_volume_prct = sum(upper_contour_raw_95_linear(:))/middle_contour_volume;
    mid_on_upper_raw_95_linear              = upper_contour_raw_95_linear.*middle_contour;
    lower_on_mid_raw_95_linear              = middle_contour.*lower_contour_raw_95_linear;
    upper_subset_mid_raw_95_linear          = upper_contour_raw_95_linear - mid_on_upper_raw_95_linear;
    mid_subset_lower_raw_95_linear          = middle_contour - lower_on_mid_raw_95_linear;

    %
    % Storing all variables of interest
    %
    supG_raw_store(:,t)                                    = supG_raw;
    threshold_raw_80_store(t)                              = supGa_raw_80;
    lower_contour_raw_80_store(t,:,:)                      = lower_contour_raw_80;
    upper_contour_raw_80_store(t,:,:)                      = upper_contour_raw_80;
    upper_subset_mid_raw_80_store(t,:,:)                   = upper_subset_mid_raw_80;
    mid_subset_lower_raw_80_store(t,:,:)                   = mid_subset_lower_raw_80;
    lower_contour_raw_80_volume_prct_store(t)              = lower_contour_raw_80_volume_prct;
    upper_contour_raw_80_volume_prct_store(t)              = upper_contour_raw_80_volume_prct;
 
    threshold_raw_90_store(t)                              = supGa_raw_90;
    lower_contour_raw_90_store(t,:,:)                      = lower_contour_raw_90;
    upper_contour_raw_90_store(t,:,:)                      = upper_contour_raw_90;
    upper_subset_mid_raw_90_store(t,:,:)                   = upper_subset_mid_raw_90;
    mid_subset_lower_raw_90_store(t,:,:)                   = mid_subset_lower_raw_90;
    lower_contour_raw_90_volume_prct_store(t)              = lower_contour_raw_90_volume_prct;
    upper_contour_raw_90_volume_prct_store(t)              = upper_contour_raw_90_volume_prct;

    threshold_raw_95_store(t)                              = supGa_raw_95;
    lower_contour_raw_95_store(t,:,:)                      = lower_contour_raw_95;
    upper_contour_raw_95_store(t,:,:)                      = upper_contour_raw_95;
    upper_subset_mid_raw_95_store(t,:,:)                   = upper_subset_mid_raw_95;
    mid_subset_lower_raw_95_store(t,:,:)                   = mid_subset_lower_raw_95;
    lower_contour_raw_95_volume_prct_store(t)              = lower_contour_raw_95_volume_prct;
    upper_contour_raw_95_volume_prct_store(t)              = upper_contour_raw_95_volume_prct;

    supG_raw_ero_store(:,t)                                    = supG_raw_ero;
    threshold_raw_80_ero_store(t)                              = supGa_raw_80_ero;
    lower_contour_raw_80_ero_store(t,:,:)                      = lower_contour_raw_80_ero;
    upper_contour_raw_80_ero_store(t,:,:)                      = upper_contour_raw_80_ero;
    upper_subset_mid_raw_80_ero_store(t,:,:)                   = upper_subset_mid_raw_80_ero;
    mid_subset_lower_raw_80_ero_store(t,:,:)                   = mid_subset_lower_raw_80_ero;
    lower_contour_raw_80_ero_volume_prct_store(t)              = lower_contour_raw_80_ero_volume_prct;
    upper_contour_raw_80_ero_volume_prct_store(t)              = upper_contour_raw_80_ero_volume_prct;
 
    threshold_raw_90_ero_store(t)                              = supGa_raw_90_ero;
    lower_contour_raw_90_ero_store(t,:,:)                      = lower_contour_raw_90_ero;
    upper_contour_raw_90_ero_store(t,:,:)                      = upper_contour_raw_90_ero;
    upper_subset_mid_raw_90_ero_store(t,:,:)                   = upper_subset_mid_raw_90_ero;
    mid_subset_lower_raw_90_ero_store(t,:,:)                   = mid_subset_lower_raw_90_ero;
    lower_contour_raw_90_ero_volume_prct_store(t)              = lower_contour_raw_90_ero_volume_prct;
    upper_contour_raw_90_ero_volume_prct_store(t)              = upper_contour_raw_90_ero_volume_prct;

    threshold_raw_95_ero_store(t)                              = supGa_raw_95_ero;
    lower_contour_raw_95_ero_store(t,:,:)                      = lower_contour_raw_95_ero;
    upper_contour_raw_95_ero_store(t,:,:)                      = upper_contour_raw_95_ero;
    upper_subset_mid_raw_95_ero_store(t,:,:)                   = upper_subset_mid_raw_95_ero;
    mid_subset_lower_raw_95_ero_store(t,:,:)                   = mid_subset_lower_raw_95_ero;
    lower_contour_raw_95_ero_volume_prct_store(t)              = lower_contour_raw_95_ero_volume_prct;
    upper_contour_raw_95_ero_volume_prct_store(t)              = upper_contour_raw_95_ero_volume_prct;

    supG_raw_dil_store(:,t)                                    = supG_raw_dil;
    threshold_raw_80_dil_store(t)                              = supGa_raw_80_dil;
    lower_contour_raw_80_dil_store(t,:,:)                      = lower_contour_raw_80_dil;
    upper_contour_raw_80_dil_store(t,:,:)                      = upper_contour_raw_80_dil;
    upper_subset_mid_raw_80_dil_store(t,:,:)                   = upper_subset_mid_raw_80_dil;
    mid_subset_lower_raw_80_dil_store(t,:,:)                   = mid_subset_lower_raw_80_dil;
    lower_contour_raw_80_dil_volume_prct_store(t)              = lower_contour_raw_80_dil_volume_prct;
    upper_contour_raw_80_dil_volume_prct_store(t)              = upper_contour_raw_80_dil_volume_prct;
 
    threshold_raw_90_dil_store(t)                              = supGa_raw_90_dil;
    lower_contour_raw_90_dil_store(t,:,:)                      = lower_contour_raw_90_dil;
    upper_contour_raw_90_dil_store(t,:,:)                      = upper_contour_raw_90_dil;
    upper_subset_mid_raw_90_dil_store(t,:,:)                   = upper_subset_mid_raw_90_dil;
    mid_subset_lower_raw_90_dil_store(t,:,:)                   = mid_subset_lower_raw_90_dil;
    lower_contour_raw_90_dil_volume_prct_store(t)              = lower_contour_raw_90_dil_volume_prct;
    upper_contour_raw_90_dil_volume_prct_store(t)              = upper_contour_raw_90_dil_volume_prct;

    threshold_raw_95_dil_store(t)                              = supGa_raw_95_dil;
    lower_contour_raw_95_dil_store(t,:,:)                      = lower_contour_raw_95_dil;
    upper_contour_raw_95_dil_store(t,:,:)                      = upper_contour_raw_95_dil;
    upper_subset_mid_raw_95_dil_store(t,:,:)                   = upper_subset_mid_raw_95_dil;
    mid_subset_lower_raw_95_dil_store(t,:,:)                   = mid_subset_lower_raw_95_dil;
    lower_contour_raw_95_dil_volume_prct_store(t)              = lower_contour_raw_95_dil_volume_prct;
    upper_contour_raw_95_dil_volume_prct_store(t)              = upper_contour_raw_95_dil_volume_prct;

    supG_raw_ero_dil_store(:,t)                                    = supG_raw_ero_dil;
    threshold_raw_80_ero_dil_store(t)                              = supGa_raw_80_ero_dil;
    lower_contour_raw_80_ero_dil_store(t,:,:)                      = lower_contour_raw_80_ero_dil;
    upper_contour_raw_80_ero_dil_store(t,:,:)                      = upper_contour_raw_80_ero_dil;
    upper_subset_mid_raw_80_ero_dil_store(t,:,:)                   = upper_subset_mid_raw_80_ero_dil;
    mid_subset_lower_raw_80_ero_dil_store(t,:,:)                   = mid_subset_lower_raw_80_ero_dil;
    lower_contour_raw_80_ero_dil_volume_prct_store(t)              = lower_contour_raw_80_ero_dil_volume_prct;
    upper_contour_raw_80_ero_dil_volume_prct_store(t)              = upper_contour_raw_80_ero_dil_volume_prct;
 
    threshold_raw_90_ero_dil_store(t)                              = supGa_raw_90_ero_dil;
    lower_contour_raw_90_ero_dil_store(t,:,:)                      = lower_contour_raw_90_ero_dil;
    upper_contour_raw_90_ero_dil_store(t,:,:)                      = upper_contour_raw_90_ero_dil;
    upper_subset_mid_raw_90_ero_dil_store(t,:,:)                   = upper_subset_mid_raw_90_ero_dil;
    mid_subset_lower_raw_90_ero_dil_store(t,:,:)                   = mid_subset_lower_raw_90_ero_dil;
    lower_contour_raw_90_ero_dil_volume_prct_store(t)              = lower_contour_raw_90_ero_dil_volume_prct;
    upper_contour_raw_90_ero_dil_volume_prct_store(t)              = upper_contour_raw_90_ero_dil_volume_prct;

    threshold_raw_95_ero_dil_store(t)                              = supGa_raw_95_ero_dil;
    lower_contour_raw_95_ero_dil_store(t,:,:)                      = lower_contour_raw_95_ero_dil;
    upper_contour_raw_95_ero_dil_store(t,:,:)                      = upper_contour_raw_95_ero_dil;
    upper_subset_mid_raw_95_ero_dil_store(t,:,:)                   = upper_subset_mid_raw_95_ero_dil;
    mid_subset_lower_raw_95_ero_dil_store(t,:,:)                   = mid_subset_lower_raw_95_ero_dil;
    lower_contour_raw_95_ero_dil_volume_prct_store(t)              = lower_contour_raw_95_ero_dil_volume_prct;
    upper_contour_raw_95_ero_dil_volume_prct_store(t)              = upper_contour_raw_95_ero_dil_volume_prct;

    supG_raw_linear_store(:,t)                                    = supG_raw_linear;
    threshold_raw_80_linear_store(t)                              = supGa_raw_80_linear;
    lower_contour_raw_80_linear_store(t,:,:)                      = lower_contour_raw_80_linear;
    upper_contour_raw_80_linear_store(t,:,:)                      = upper_contour_raw_80_linear;
    upper_subset_mid_raw_80_linear_store(t,:,:)                   = upper_subset_mid_raw_80_linear;
    mid_subset_lower_raw_80_linear_store(t,:,:)                   = mid_subset_lower_raw_80_linear;
    lower_contour_raw_80_linear_volume_prct_store(t)              = lower_contour_raw_80_linear_volume_prct;
    upper_contour_raw_80_linear_volume_prct_store(t)              = upper_contour_raw_80_linear_volume_prct;
 
    threshold_raw_90_linear_store(t)                              = supGa_raw_90_linear;
    lower_contour_raw_90_linear_store(t,:,:)                      = lower_contour_raw_90_linear;
    upper_contour_raw_90_linear_store(t,:,:)                      = upper_contour_raw_90_linear;
    upper_subset_mid_raw_90_linear_store(t,:,:)                   = upper_subset_mid_raw_90_linear;
    mid_subset_lower_raw_90_linear_store(t,:,:)                   = mid_subset_lower_raw_90_linear;
    lower_contour_raw_90_linear_volume_prct_store(t)              = lower_contour_raw_90_linear_volume_prct;
    upper_contour_raw_90_linear_volume_prct_store(t)              = upper_contour_raw_90_linear_volume_prct;

    threshold_raw_95_linear_store(t)                              = supGa_raw_95_linear;
    lower_contour_raw_95_linear_store(t,:,:)                      = lower_contour_raw_95_linear;
    upper_contour_raw_95_linear_store(t,:,:)                      = upper_contour_raw_95_linear;
    upper_subset_mid_raw_95_linear_store(t,:,:)                   = upper_subset_mid_raw_95_linear;
    mid_subset_lower_raw_95_linear_store(t,:,:)                   = mid_subset_lower_raw_95_linear;
    lower_contour_raw_95_linear_volume_prct_store(t)              = lower_contour_raw_95_linear_volume_prct;
    upper_contour_raw_95_linear_volume_prct_store(t)              = upper_contour_raw_95_linear_volume_prct;
    
    
    if sum(upper_subset_mid_raw_80(:))+sum(mid_subset_lower_raw_80(:))==0
      subset_success_vector_raw_80(t) = 1; 
      fprintf('raw nominal 90 true boundary success! \n');
    else 
      subset_success_vector_raw_80(t) = 0; 
      fprintf('raw nominal 90 true boundary failure! \n');
    end 

    if sum(upper_subset_mid_raw_90(:))+sum(mid_subset_lower_raw_90(:))==0
      subset_success_vector_raw_90(t) = 1; 
      fprintf('raw nominal 90 true boundary success! \n');
    else 
      subset_success_vector_raw_90(t) = 0; 
      fprintf('raw nominal 90 true boundary failure! \n');
    end 

    if sum(upper_subset_mid_raw_95(:))+sum(mid_subset_lower_raw_95(:))==0
      subset_success_vector_raw_95(t) = 1; 
      fprintf('raw nominal 95 true boundary success! \n');
    else 
      subset_success_vector_raw_95(t) = 0; 
      fprintf('raw nominal 95 true boundary failure! \n');
    end 

    if sum(upper_subset_mid_raw_80_ero(:))+sum(mid_subset_lower_raw_80_ero(:))==0
      subset_success_vector_raw_80_ero(t) = 1; 
      fprintf('raw nominal 90 ero boundary success! \n');
    else 
      subset_success_vector_raw_80_ero(t) = 0; 
      fprintf('raw nominal 90 ero boundary failure! \n');
    end 

    if sum(upper_subset_mid_raw_90_ero(:))+sum(mid_subset_lower_raw_90_ero(:))==0
      subset_success_vector_raw_90_ero(t) = 1; 
      fprintf('raw nominal 90 ero boundary success! \n');
    else 
      subset_success_vector_raw_90_ero(t) = 0; 
      fprintf('raw nominal 90 ero boundary failure! \n');
    end 

    if sum(upper_subset_mid_raw_95_ero(:))+sum(mid_subset_lower_raw_95_ero(:))==0
      subset_success_vector_raw_95_ero(t) = 1; 
      fprintf('raw nominal 95 ero boundary success! \n');
    else 
      subset_success_vector_raw_95_ero(t) = 0; 
      fprintf('raw nominal 95 ero boundary failure! \n');
    end 

    if sum(upper_subset_mid_raw_80_dil(:))+sum(mid_subset_lower_raw_80_dil(:))==0
      subset_success_vector_raw_80_dil(t) = 1; 
      fprintf('raw nominal 90 dil boundary success! \n');
    else 
      subset_success_vector_raw_80_dil(t) = 0; 
      fprintf('raw nominal 90 dil boundary failure! \n');
    end 

    if sum(upper_subset_mid_raw_90_dil(:))+sum(mid_subset_lower_raw_90_dil(:))==0
      subset_success_vector_raw_90_dil(t) = 1; 
      fprintf('raw nominal 90 dil boundary success! \n');
    else 
      subset_success_vector_raw_90_dil(t) = 0; 
      fprintf('raw nominal 90 dil boundary failure! \n');
    end 

    if sum(upper_subset_mid_raw_95_dil(:))+sum(mid_subset_lower_raw_95_dil(:))==0
      subset_success_vector_raw_95_dil(t) = 1; 
      fprintf('raw nominal 95 dil boundary success! \n');
    else 
      subset_success_vector_raw_95_dil(t) = 0; 
      fprintf('raw nominal 95 dil boundary failure! \n');
    end 

    if sum(upper_subset_mid_raw_80_ero_dil(:))+sum(mid_subset_lower_raw_80_ero_dil(:))==0
      subset_success_vector_raw_80_ero_dil(t) = 1; 
      fprintf('raw nominal 90 ero_dil boundary success! \n');
    else 
      subset_success_vector_raw_80_ero_dil(t) = 0; 
      fprintf('raw nominal 90 ero_dil boundary failure! \n');
    end 

    if sum(upper_subset_mid_raw_90_ero_dil(:))+sum(mid_subset_lower_raw_90_ero_dil(:))==0
      subset_success_vector_raw_90_ero_dil(t) = 1; 
      fprintf('raw nominal 90 ero_dil boundary success! \n');
    else 
      subset_success_vector_raw_90_ero_dil(t) = 0; 
      fprintf('raw nominal 90 ero_dil boundary failure! \n');
    end 

    if sum(upper_subset_mid_raw_95_ero_dil(:))+sum(mid_subset_lower_raw_95_ero_dil(:))==0
      subset_success_vector_raw_95_ero_dil(t) = 1; 
      fprintf('raw nominal 95 ero_dil boundary success! \n');
    else 
      subset_success_vector_raw_95_ero_dil(t) = 0; 
      fprintf('raw nominal 95 ero_dil boundary failure! \n');
    end 

    if sum(upper_subset_mid_raw_80_linear(:))+sum(mid_subset_lower_raw_80_linear(:))==0
      subset_success_vector_raw_80_linear(t) = 1; 
      fprintf('raw nominal 90 linear boundary success! \n');
    else 
      subset_success_vector_raw_80_linear(t) = 0; 
      fprintf('raw nominal 90 linear boundary failure! \n');
    end 

    if sum(upper_subset_mid_raw_90_linear(:))+sum(mid_subset_lower_raw_90_linear(:))==0
      subset_success_vector_raw_90_linear(t) = 1; 
      fprintf('raw nominal 90 linear boundary success! \n');
    else 
      subset_success_vector_raw_90_linear(t) = 0; 
      fprintf('raw nominal 90 linear boundary failure! \n');
    end 

    if sum(upper_subset_mid_raw_95_linear(:))+sum(mid_subset_lower_raw_95_linear(:))==0
      subset_success_vector_raw_95_linear(t) = 1; 
      fprintf('raw nominal 95 linear boundary success! \n');
    else 
      subset_success_vector_raw_95_linear(t) = 0; 
      fprintf('raw nominal 95 linear boundary failure! \n');
    end     

end

percentage_success_vector_raw_80                         = mean(subset_success_vector_raw_80, 1);
percentage_success_vector_raw_90                         = mean(subset_success_vector_raw_90, 1);
percentage_success_vector_raw_95                         = mean(subset_success_vector_raw_95, 1);

percentage_success_vector_raw_80_ero                     = mean(subset_success_vector_raw_80_ero, 1);
percentage_success_vector_raw_90_ero                     = mean(subset_success_vector_raw_90_ero, 1);
percentage_success_vector_raw_95_ero                     = mean(subset_success_vector_raw_95_ero, 1);

percentage_success_vector_raw_80_dil                     = mean(subset_success_vector_raw_80_dil, 1);
percentage_success_vector_raw_90_dil                     = mean(subset_success_vector_raw_90_dil, 1);
percentage_success_vector_raw_95_dil                     = mean(subset_success_vector_raw_95_dil, 1);

percentage_success_vector_raw_80_ero_dil                 = mean(subset_success_vector_raw_80_ero_dil, 1);
percentage_success_vector_raw_90_ero_dil                 = mean(subset_success_vector_raw_90_ero_dil, 1);
percentage_success_vector_raw_95_ero_dil                 = mean(subset_success_vector_raw_95_ero_dil, 1);

percentage_success_vector_raw_80_linear                  = mean(subset_success_vector_raw_80_linear, 1);
percentage_success_vector_raw_90_linear                  = mean(subset_success_vector_raw_90_linear, 1);
percentage_success_vector_raw_95_linear                  = mean(subset_success_vector_raw_95_linear, 1);


eval(['save ' SvNm ' nSubj nRlz dim smo mag rimFWHM thr nBoot '... 
      'threshold_raw_80_store threshold_raw_90_store threshold_raw_95_store threshold_raw_80_ero_store threshold_raw_90_ero_store threshold_raw_95_ero_store threshold_raw_80_dil_store threshold_raw_90_dil_store threshold_raw_95_dil_store threshold_raw_80_ero_dil_store threshold_raw_90_ero_dil_store threshold_raw_95_ero_dil_store threshold_raw_80_linear_store threshold_raw_90_linear_store threshold_raw_95_linear_store '...
      'lower_contour_raw_80_store lower_contour_raw_90_store lower_contour_raw_95_store lower_contour_raw_80_ero_store lower_contour_raw_90_ero_store lower_contour_raw_95_ero_store lower_contour_raw_80_dil_store lower_contour_raw_90_dil_store lower_contour_raw_95_dil_store lower_contour_raw_80_ero_dil_store lower_contour_raw_90_ero_dil_store lower_contour_raw_95_ero_dil_store lower_contour_raw_80_linear_store lower_contour_raw_90_linear_store lower_contour_raw_95_linear_store '...
      'upper_contour_raw_80_store upper_contour_raw_90_store upper_contour_raw_95_store upper_contour_raw_80_ero_store upper_contour_raw_90_ero_store upper_contour_raw_95_ero_store upper_contour_raw_80_dil_store upper_contour_raw_90_dil_store upper_contour_raw_95_dil_store upper_contour_raw_80_ero_dil_store upper_contour_raw_90_ero_dil_store upper_contour_raw_95_ero_dil_store upper_contour_raw_80_linear_store upper_contour_raw_90_linear_store upper_contour_raw_95_linear_store '...
      'upper_subset_mid_raw_80_store upper_subset_mid_raw_90_store upper_subset_mid_raw_95_store upper_subset_mid_raw_80_ero_store upper_subset_mid_raw_90_ero_store upper_subset_mid_raw_95_ero_store upper_subset_mid_raw_80_dil_store upper_subset_mid_raw_90_dil_store upper_subset_mid_raw_95_dil_store upper_subset_mid_raw_80_ero_dil_store upper_subset_mid_raw_90_ero_dil_store upper_subset_mid_raw_95_ero_dil_store upper_subset_mid_raw_80_linear_store upper_subset_mid_raw_90_linear_store upper_subset_mid_raw_95_linear_store '...
      'mid_subset_lower_raw_80_store mid_subset_lower_raw_90_store mid_subset_lower_raw_95_store mid_subset_lower_raw_80_ero_store mid_subset_lower_raw_90_ero_store mid_subset_lower_raw_95_ero_store mid_subset_lower_raw_80_dil_store mid_subset_lower_raw_90_dil_store mid_subset_lower_raw_95_dil_store mid_subset_lower_raw_80_ero_dil_store mid_subset_lower_raw_90_ero_dil_store mid_subset_lower_raw_95_ero_dil_store mid_subset_lower_raw_80_linear_store mid_subset_lower_raw_90_linear_store mid_subset_lower_raw_95_linear_store '...
      'subset_success_vector_raw_80 subset_success_vector_raw_90 subset_success_vector_raw_95 subset_success_vector_raw_80_ero subset_success_vector_raw_90_ero subset_success_vector_raw_95_ero subset_success_vector_raw_80_dil subset_success_vector_raw_90_dil subset_success_vector_raw_95_dil subset_success_vector_raw_80_ero_dil subset_success_vector_raw_90_ero_dil subset_success_vector_raw_95_ero_dil subset_success_vector_raw_80_linear subset_success_vector_raw_90_linear subset_success_vector_raw_95_linear '...
      'percentage_success_vector_raw_80 percentage_success_vector_raw_90 percentage_success_vector_raw_95 percentage_success_vector_raw_80_ero percentage_success_vector_raw_90_ero percentage_success_vector_raw_95_ero percentage_success_vector_raw_80_dil percentage_success_vector_raw_90_dil percentage_success_vector_raw_95_dil percentage_success_vector_raw_80_ero_dil percentage_success_vector_raw_90_ero_dil percentage_success_vector_raw_95_ero_dil percentage_success_vector_raw_80_linear percentage_success_vector_raw_90_linear percentage_success_vector_raw_95_linear '...
      'supG_raw_store supG_raw_ero_store supG_raw_dil_store supG_raw_ero_dil_store supG_raw_linear_store '...
      'middle_contour_volume observed_AC_volume '...
      'lower_contour_raw_80_volume_prct_store lower_contour_raw_90_volume_prct_store lower_contour_raw_95_volume_prct_store lower_contour_raw_80_ero_volume_prct_store lower_contour_raw_90_ero_volume_prct_store lower_contour_raw_95_ero_volume_prct_store lower_contour_raw_80_dil_volume_prct_store lower_contour_raw_90_dil_volume_prct_store lower_contour_raw_95_dil_volume_prct_store lower_contour_raw_80_ero_dil_volume_prct_store lower_contour_raw_90_ero_dil_volume_prct_store lower_contour_raw_95_ero_dil_volume_prct_store lower_contour_raw_80_linear_volume_prct_store lower_contour_raw_90_linear_volume_prct_store lower_contour_raw_95_linear_volume_prct_store '...
      'upper_contour_raw_80_volume_prct_store upper_contour_raw_90_volume_prct_store upper_contour_raw_95_volume_prct_store upper_contour_raw_80_ero_volume_prct_store upper_contour_raw_90_ero_volume_prct_store upper_contour_raw_95_ero_volume_prct_store upper_contour_raw_80_dil_volume_prct_store upper_contour_raw_90_dil_volume_prct_store upper_contour_raw_95_dil_volume_prct_store upper_contour_raw_80_ero_dil_volume_prct_store upper_contour_raw_90_ero_dil_volume_prct_store upper_contour_raw_95_ero_dil_volume_prct_store upper_contour_raw_80_linear_volume_prct_store upper_contour_raw_90_linear_volume_prct_store upper_contour_raw_95_linear_volume_prct_store'])
