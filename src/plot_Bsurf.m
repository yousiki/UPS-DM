% Integrates the normal field embedded in facet matrix B
% and plots the resulting surface
%
% ============
% Neil Alldrin
%
function [n_surf] = plot_Bsurf(B,Isize,mask)

if ~exist('fig') fig = gcf; end;

% Convert facet matrix B to gradients (p,q)
[nx,ny,nz,a] = B2normals(B,Isize);

p = -nx./(nz+(nz==0));
q = ny./(nz+(nz==0));
p(~mask(:)) = 0;
q(~mask(:)) = 0;

% Integrate the gradient field to obtain a height map
n_surf = integrate_poisson(p,q);
%n_surf = -n_surf;
%n_surf = n_surf + min(n_surf(:));

% Fill masked pixels with NaNs
n_surf(~mask(:)) = nan;
n_surf=reshape(n_surf,Isize);
% % Plot the surface
% figure(fig);
% h = surf(1:size(n_surf,2),1:size(n_surf,1),n_surf);
% %h = surf(size(n_surf,2):-1:1,1:size(n_surf,1),n_surf);
% %h = surf(1:size(n_surf,2),size(n_surf,1):-1:1,n_surf);
% colormap 'gray';
% axis equal;
% axis off;
% set(h,'EdgeColor','none');
% set(h,'AmbientStrength',0.8);
% set(h,'SpecularStrength',0.2);
% %set(fig,'Renderer','zbuffer');
% view(-10,65)