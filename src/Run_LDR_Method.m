% An implementation of the uncalibrated photometric stereo technique described in 
% "A Closed-Form Solution to Uncalibrated Photometric Stereo via Diffuse Maxima" by Paolo Favaro and Thoma Papadhimitri.
% You can load one of the pre-preprocessed datasets ("cat.mat","buddha.mat", "horse.mat", "rock.mat", "owl.mat",
% "redfish.mat", "octopus.mat", "doll.mat"        othterwise see (1*) and (2*);
% In the paper,for the performance evaluation we also include the
% pre-processing time; 
%============
% Author: Thoma Papadhimitri
% http://www.cvg.unibe.ch/staff/thoma-papadhimitri
% November 2011
% All rights reserved
% Research use is allowed provided that the following work is cited:
% "A Closed-Form Solution to Uncalibrated Photometric Stereo via Diffuse
% Maxima" by Paolo Favaro and Thoma Papadhimitri, CVPR 2012.
%============
clear all;

pkg load image;
pkg load signal;

% Check if input argument exists
args = argv();
if numel(args) < 2
    error('Please provide the path to input mat and output mat as arguments');
end

matfile = args{1};
outputMatfile = args{2};
% Validate file existence and extension
if ~exist(matfile, 'file')
    error('File does not exist: %s', matfile);
end
[~, ~, ext] = fileparts(matfile);
if ~strcmpi(ext, '.mat')
    error('File must be a .mat file: %s', matfile);
end

% Load the specified .mat file
load(matfile);

% Validate the contents of the loaded .mat file
if ~exist('I', 'var') || ~exist('L', 'var') || ~exist('mask', 'var')
    error('The loaded .mat file must contain variables I, L, and mask.');
end

% Each dataset includes:
% I : NxM Image data; N is the number of pixels per image, M is the number of images.
% L : 3xM Light matrix; M is hte number of points light sources (images);
% mask: A binary mask to segment the object;

% ((1*) --------------- Original Images------------------------------
% You can download the original images from:
%  CAT, OWL, BUDDHA, ROCK, HORSE -   http://www.cs.washington.edu/education/courses/csep576/05wi
%/projects/project3/project3.htm
%  OCTOPUS, REDFISH -           http://neilalldrin.com/research
%------------------------------------------------------------------------

% ((2*) --------------- Pre-processing step------------------------------
% for the removal of specularities, shadows and other non-Lambertian
% effects; to download the code visit:
% http://perception.csl.uiuc.edu/matrix-rank/sample_code.html

%     k= ...  the choice of k depends on the input images. Typically k=1-2;
%     k=1.7 for >=12 images datasets (CAT, OWL, BUDDHA, ROCK AND HORSE);
%     k=3 for 5 images datasets (OOCTPUS AND REDFISH);
%     lambda=k/sqrt(number_rows*number_columns);
%     [I E_hat iter] = inexact_alm_rpca(I, lambda);

% where the size of the input images are [number_rows x number_columns]
%------------------------------------------------------------------------

nrows=size(mask,1);    ncols=size(mask,2);     num_images=size(I,2);
[N_psd L_psd]=uncalibrated_photometric_stereo(I,mask,[rand(1),rand(1),rand(1)]);  
% Uncalibrated Photometric Stereo algorithm: estimate the normals and
% lights up to the GBR ambiguity; Notice that our method returns the 
% same GBR estimate for any output of the above algorithm (notice the
% three random constants passed as argument).


% Finding the local-maxima candidates
I=reshape(I,nrows,ncols,num_images);
LDR=find_LDR_candidates(I,mask);

Si=[];
for k=1:num_images
    % Selection of pseudo-lights corresponding to the LDR maxima candidates in each image
    Si=[Si repmat(L_psd(:,k),[1,sum(sum(LDR(:,:,k)))])];
end
N_curr=repmat(N_psd,[num_images 1]);
Ni=N_curr(LDR==1,:)';             % The pseudo-n corresponding to the selected LDR maxima

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The GBR disambiguation algorithm 
% Takes as input pseudo-normals and pseudo-lights corresponding to LDR
% maxima candidates; the algorithm tolerates high levels of outliers and
% it returns GBR parameters so that the estimated normal field is the same
% for any initial valid pseudo-normals and pseudo-lights
[mu nu la]=loc_search(Ni,Si);     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% -----   Perform Calibrated PS in order to have the ground truth reference;
I=reshape(I,nrows*ncols,num_images);
[N,albedo_gt] = calibrated_photometric_stereo(I,L,mask);
n=N./repmat(sqrt(sum(N.^2,2)),[1 3]);
G=pinv(N_psd)*N;
G=G./G(1,1);    % Our "ground-truth" GBR matrix
%-------------------------------------------------------

% Convex/concave ambiguity: we return both solutions (one for each sign of
% 'la').
N_me1=N_psd*[1 0 0; 0 1 0; mu nu la];        % The first possible estimated normals-matrix with our method
N_me2=N_psd*[1 0 0; 0 1 0; mu nu -la];       % The second possible estimated normals-matrix with our method
L_me1=[1 0 0; 0 1 0; mu nu la]\L_psd;        % The first possible estimated lights-matrix with our method
L_me2=[1 0 0; 0 1 0; mu nu -la]\L_psd;       % The second possible estimated lights-matrix with our method
n_me1=N_me1./repmat(sqrt(sum(N_me1.^2,2)),[1 3]);
n_me2=N_me2./repmat(sqrt(sum(N_me2.^2,2)),[1 3]);
n=reshape(n,nrows*ncols,3);
inner1=sum(n.*n_me1,2);
inner2=sum(n.*n_me2,2);
angle1=acosd(abs(inner1));
angle2=acosd(abs(inner2));
mean_angle1=mean(angle1(mask==1));
mean_angle2=mean(angle2(mask==1));
[depth_me1] = plot_Bsurf(n_me1,size(mask),mask);   % The first possible depth map
[depth_me2] = plot_Bsurf(n_me2,size(mask),mask);   % The second possible depth map;
[depth_gt] = plot_Bsurf(n,size(mask),mask);        % The ground truth depth map;
mean_angle=min([mean_angle1 mean_angle2]);
fprintf('The mean angle is %f degrees \n',mean_angle)
imagesc([depth_me1 depth_me2]);
title('The convex and concave solutions');
[depth_me,n_me,L_me]=solve_convex_concave_ambiguity(depth_me1,depth_me2,n_me1,n_me2,L_me1,L_me2,mask);

% Create parent directories if they do not exist
outputDir = fileparts(outputMatfile);
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end
% Save n n_me1 n_me2 L_me1 L_me2 depth_me1 depth_me2 depth_gt to output.mat
save(outputMatfile, 'n', 'n_me1', 'n_me2', 'L_me1', 'L_me2', 'depth_me1', 'depth_me2', 'depth_gt');
% Log
fprintf('Saved output to %s\n', outputMatfile);

%%%%%%%      UNCOMMENT THE NEXT THREE LINES if you want to generate figures of normals, depth and surfaces from two
%%%%%%%      viewpoints obtained with our method and calibrated PS:

%  dataset_name='owl';                            % name of the dataset
%  path='./Figures/';                             % The path where you want the figures to be saved;
%  generate_figures(n_me,n,depth_me,depth_gt,mask,path,dataset_name);
%  close all;

