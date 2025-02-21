function []=generate_figures(n_me,n,depth_me,depth_gt,mask,path,dataset_name)
%Produces the figures of the normal maps, depth maps and surfaces from 2
%different viewpoints in the case of the calibrated PS and our uncalibrated
%method.
% Inputs 
%   n_me              :  The estimated normal map by our method
%   n                 :  The estimated normal map by calibrated photometric stereo
%   depth_me          :  The estimated depth map by our method
%   depth_gt          :  The estimated depth map by calibrated photometric stereo
%   mask              :  A binary mask to isolate the object
%   path              :  The path where the images are saved
%   dataset_name              :  The name of the dataset
%============
% Author: Thoma Papadhimitri
% http://www.cvg.unibe.ch/staff/thoma-papadhimitri
% November 2011
% All rights reserved
% Research use is allowed provided that the following work is cited:
% "A Closed-Form Solution to Uncalibrated Photometric Stereo via Diffuse
% Maxima" by Paolo Favaro and Thoma Papadhimitri, CVPR 2012.
%============
nrows=size(mask,1);  ncols=size(mask,2);

if strcmp(dataset_name,'owl')==1
%The owl dataset has a critical point at the 
%owl's eye; depth saturation is used for visualization purposes.
depth_me(find(abs(depth_me)>70))=70+3*randn(size(find(abs(depth_me)>70)));
depth_gt(find(abs(depth_gt)>88))=80+3*randn(size(find(abs(depth_gt)>88)));
end

n_me=reshape(n_me,nrows,ncols,3);
n=reshape(n,nrows,ncols,3);
maskx=find(sum(mask,2)>=1);
masky=find(sum(mask,1)>=1);

indxl=maskx(1);
indxh=maskx(end);
indyl=masky(1);
indyh=masky(end);

mask_new=mask(indxl:indxh,indyl:indyh);
mask=mask_new;

depth_me_new=depth_me(indxl:indxh,indyl:indyh);
depth_me=depth_me_new;
depth_gt=depth_gt(indxl:indxh,indyl:indyh);
n_me=n_me(indxl:indxh,indyl:indyh,:);
n_new=n(indxl:indxh,indyl:indyh,:);
n=n_new;
n_me=n_me.*repmat(mask,[1 1 3]);
n_gt=n.*repmat(mask,[1 1 3]);

mean_depth_me=mean(depth_me(mask==1));
mean_depth_gt=mean(depth_gt(mask==1));
depth_me=depth_me-mean_depth_me;
depth_gt=depth_gt-mean_depth_gt;
min_me=min(depth_me(mask==1));
min_gt=min(depth_gt(mask==1));
min_depth=min(min_me,min_gt);
depth_me=depth_me-(min_depth);
depth_gt=depth_gt-(min_depth);
max_depth=max(max(depth_me(mask==1)),max(depth_gt(mask==1)));




figure(1);
imagesc(depth_me);
axis equal;
axis off;
title('Depth of our UPS Method');
figure(2);
imagesc(depth_gt);
axis equal;
axis off;
title('Depth of PS Method');
filename = [path dataset_name '/depth_' dataset_name '_me.png'];
imwrite(depth_me,jet(256),filename,'jpg');
filename = [path dataset_name '/depth_' dataset_name '_gt.png'];
imwrite(depth_gt,jet(256),filename,'png');

%-------------------------   nx    -------------------------------
nx_me=n_me(:,:,1);
nx_gt=n_gt(:,:,1);
mean_nx_me=mean(nx_me(mask==1));
mean_nx_gt=mean(nx_gt(mask==1));
nx_me=mean_nx_me-nx_me;
nx_gt=mean_nx_gt-nx_gt;
min_me=min(nx_me(mask==1));
min_gt=min(nx_gt(mask==1));
min_nx=min(min_me,min_gt);
nx_me=nx_me-(min_nx);
nx_gt=nx_gt-(min_nx);
max_nx=max(max(nx_me(mask==1)),max(nx_gt(mask==1)));
nx_me=255*nx_me./max_nx;
nx_gt=255*nx_gt./max_nx;
nx_me=255-nx_me;
nx_gt=255-nx_gt;
nx_me(mask==0)=0;
nx_gt(mask==0)=0;
figure(3);
imagesc(nx_me);
axis equal;
axis off;
title('First normals component of our UPS Method');
figure(4);
imagesc(nx_gt);
axis equal;
axis off;
title('First normals component of PS Method');
filename = [path dataset_name '/nx_' dataset_name '_me.png'];
imwrite(nx_me,jet(256),filename,'png');
filename = [path dataset_name '/nx_' dataset_name '_gt.png'];
imwrite(nx_gt,jet(256),filename,'png');



%-------------------------   ny    -------------------------------
ny_me=n_me(:,:,2);
ny_gt=n_gt(:,:,2);
mean_ny_me=mean(ny_me(mask==1));
mean_ny_gt=mean(ny_gt(mask==1));
ny_me=mean_ny_me-ny_me;
ny_gt=mean_ny_gt-ny_gt;
min_me=min(ny_me(mask==1));
min_gt=min(ny_gt(mask==1));
min_ny=min(min_me,min_gt);
ny_me=ny_me-(min_ny);
ny_gt=ny_gt-(min_ny);
max_ny=max(max(ny_me(mask==1)),max(ny_gt(mask==1)));
ny_me=255*ny_me./max_ny;
ny_gt=255*ny_gt./max_ny;
ny_me=255-ny_me;
ny_gt=255-ny_gt;



figure(5);
imagesc(ny_me);
axis equal;
axis off;
title('Second normals component of our UPS Method');
figure(6);
imagesc(ny_gt);
axis equal;
axis off;
title('Second normals component of PS Method');
filename = [path dataset_name '/ny_' dataset_name '_me.png'];
imwrite(ny_me,jet(256),filename,'png');
filename = [path dataset_name '/ny_' dataset_name '_gt.png'];
imwrite(ny_gt,jet(256),filename,'png');

%-------------------------   nz    -------------------------------
nz_me=n_me(:,:,3);
nz_gt=n_gt(:,:,3);
mean_nz_me=mean(nz_me((mask==1)));
mean_nz_gt=mean(nz_gt((mask==1)));
nz_me=mean_nz_me-nz_me;
nz_gt=mean_nz_gt-nz_gt;
min_me=min(nz_me((mask==1)));
min_gt=min(nz_gt((mask==1)));
min_nz=min(min_me,min_gt);
nz_me=nz_me-(min_nz);
nz_gt=nz_gt-(min_nz);
max_nz=max(max(nz_me((mask==1))),max(nz_gt((mask==1))));
nz_me=255*nz_me./max_nz;
nz_gt=255*nz_gt./max_nz;
nz_me=255-nz_me;
nz_gt=255-nz_gt;

figure(7);
imagesc(nz_me);
axis equal;
axis off;
title('Third normals component of our UPS Method');
figure(8);
imagesc(nz_gt);
axis equal;
axis off;
title('Third normals component of PS Method');
filename = [path dataset_name '/nz_' dataset_name '_me.png'];
imwrite(nz_me,jet(256),filename,'png');
filename = [path dataset_name '/nz_' dataset_name '_gt.png'];
imwrite(nz_gt,jet(256),filename,'png');



%------------------------------  surface frontal  me ------------------------------
figure(9)
h=surfl(fliplr(depth_me));
axis([1 size(depth_me,2) 1 size(depth_me,1) 1 max_depth ]) % 1 256])
shading interp;
colormap gray;
axis off
title('Frontal view  of our UPS Method');
view(180,90);
camlight;
camlight(40,-90);
camlight(-40,-40);
axis equal;
title('Frontal view  of PS Method');
filename = [path dataset_name '/frontal_surface_' dataset_name '_me.png'];
print('-dpng', filename)
surface1=imread(filename);
surface1=mean(surface1,3);


%------------------------------  surface lateral  me ------------------------------
figure(10)
h=surfl(fliplr(depth_me));
axis([1 size(depth_me,2) 1 size(depth_me,1) 1 max_depth ]) % 1 256])
zdir=[1 0 0];
rotate(h,zdir,90);
zdir=[0 1 0];
rotate(h,zdir,180);
zdir=[0 0 1];
rotate(h,zdir,15);
shading interp;
colormap gray;
camlight;
axis off
title('Lateral view  of our UPS Method');
axis equal;
view(0,0);
camlight(20,-90);
camlight(-60,-40);
filename = [path dataset_name '/lateral_surface_' dataset_name '_me.png'];
print('-dpng', filename)
surface2=imread(filename);
surface2=mean(surface2,3);


%------------------------------  surface frontal  gt ------------------------------
figure(11)
h=surfl(fliplr(depth_gt));
axis([1 size(depth_gt,2) 1 size(depth_gt,1) 1 max_depth ]) % 1 256])
shading interp;
colormap gray;
axis off
title('Frontal view  of PS Method');
view(180,90);
camlight;
camlight(40,-90);
camlight(-40,-40);
axis equal;
filename = [path dataset_name '/frontal_surface_' dataset_name '_gt.png'];
print('-dpng', filename)
gsurface1=imread(filename);
gsurface1=mean(gsurface1,3);


%------------------------------  surface lateral  gt ------------------------------
figure(12)
h=surfl(fliplr(depth_gt));
axis([1 size(depth_gt,2) 1 size(depth_gt,1) 1 max_depth ]) % 1 256])
zdir=[1 0 0];
rotate(h,zdir,90);
zdir=[0 1 0];
rotate(h,zdir,180);
zdir=[0 0 1];
rotate(h,zdir,15);
shading interp;
colormap gray;
camlight;
axis off
axis equal;
title('Lateral view  of PS Method');
view(0,0);
camlight(20,-90);
camlight(-60,-40);
filename = [path dataset_name '/lateral_surface_' dataset_name '_gt.png'];
print('-dpng', filename)
gsurface2=imread(filename);
gsurface2=mean(gsurface2,3);

mask_surf=(surface1+surface2+gsurface1+gsurface2);
surf_mask=mask_surf<max(mask_surf(:)-2);
maskx=find(sum(surf_mask,2)>=1);
masky=find(sum(surf_mask,1)>=1);
indxl=maskx(1);
indxh=maskx(end);
indyl=masky(1);
indyh=masky(end);


sup1=surface1(indxl:indxh,indyl:indyh);
sup2=surface2(indxl:indxh,indyl:indyh);


filename = [path dataset_name '/frontal_surface_' dataset_name '_me.png'];
imwrite(sup1,gray(256),filename,'png','ScreenSize','[size(depth_me,1) size(depth_me,2)]');
filename = [path dataset_name '/lateral_surface_' dataset_name '_me.png'];
imwrite(sup2,gray(256),filename,'png','ScreenSize','[size(depth_me,1) size(depth_me,2)]');

gsup1=gsurface1(indxl:indxh,indyl:indyh);
gsup2=gsurface2(indxl:indxh,indyl:indyh);

filename = [path dataset_name '/frontal_surface_' dataset_name '_gt.png'];
imwrite(gsup1,gray(256),filename,'png','ScreenSize','[size(depth_me,1) size(depth_me,2)]');
filename = [path dataset_name '/lateral_surface_' dataset_name '_gt.png'];
imwrite(gsup2,gray(256),filename,'png','ScreenSize','[size(depth_me,1) size(depth_me,2)]');

