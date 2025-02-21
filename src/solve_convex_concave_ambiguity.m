function [depth_me,n_me,L_me]=solve_convex_concave_ambiguity(depth_me1,depth_me2,n_me1,n_me2,L_me1,L_me2,mask)
%Select the solution that gives positive depth values and normals pointing
%towards the viewer.
% Inputs 
%   Np              :   The pseudo-normals matrix Nx3 (N is the number of pixels for each image).
%   Lk              :   The pseudo-lights matrix 3xM (M is the number of light sources);
% Outputs    
%   mu, nu, la      :   The 3 GBR paramters of the GBR matrix [1 0 0; 0 1 0; mu nu la]
%============
% Author: Thoma Papadhimitri
% http://www.cvg.unibe.ch/staff/thoma-papadhimitri
% November 2011
% All rights reserved
% Research use is allowed provided that the following work is cited:
% "A Closed-Form Solution to Uncalibrated Photometric Stereo via Diffuse
% Maxima" by Paolo Favaro and Thoma Papadhimitri, CVPR 2012.
%============

if mean(depth_me1(mask==1))>0
    depth_me=depth_me1;
    n_me=n_me1;
    L_me=L_me1;
else
    depth_me=depth_me2;
    n_me=n_me2;
    L_me=L_me2;
end

% To make sure the third normals component points towards the viewer:
if mean(n_me(mask==1,3))<0
    n_me=-n_me;
    L_me=-L_me;
end
