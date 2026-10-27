% Figure 4 panels: noOVS | OVS side by side, one shared colorbar per panel.
% overlayview: /home/yonglihe/github/fMRI-processing/processing/overlayview.m
addpath('/home/yonglihe/github/fMRI-processing/processing');
load('var4fig4.mat');
png_saveroot = '../figures/';
fontSz = 8;        % pt
% manual layout (cm): two square montages side by side, shared colorbar on the right.
% tiledlayout left the montages unequal in size, so the axes are placed by hand.
nRow  = 3;     % montage rows: 12 slices -> 3 x 4
L.Sw  = 7.2;   % montage width
L.S   = L.Sw*3/4;   % montage height, 3 x 4 tiles of square slices
L.gap = 0.3;   % between montages
L.m   = 0.1;   % left/bottom margin
L.top = 0.8;   % room for the title
L.cbGap = 0.25; L.cbW = 0.35; L.cbRoom = 1.3;   % colorbar offset, width, room for its labels

%% overlayview
cbar_tscore = [3,7];
fig = panelFigure(L, nMethod);
clear axs
for k = 1:nMethod
    name = names{k};
    MATFILE = load([R.(name).output_dir 'ims_asl.mat']); %load perfusion image before smooth for underlay

    if isSENSE
        img = flip(MATFILE.im_sense,2);
    else
        img = flip(MATFILE.imsos,2);
    end
    undlay = abs(img(:,:,:,3)); % 2nd tag
    if k==1
        msk = undlay > prctile(undlay(:),60); 
        %figure;im(msk); title('mask')
    end 

    cbar_und = [min(abs(undlay(:))),max(abs(undlay(:)))];
    ov1 = overlayview;
    % no per-tile colorbars; one shared t-score bar is added after the loop
    ov1.addlayer(undlay,'caxis',cbar_und,'cloc',[]);
    ov1.addlayer(R.(name).tmap,'caxis',cbar_tscore,'cmap','hot','name','t-score','mask',msk,'cloc',[]);

    ax = montageAxes(fig, L, k); axs(k) = ax;
    ov1.show('viewargs',{'row',nRow,'notick'});
    title(ax,'');
    cornerLabel(ax, name);
end
% composite colormap: layer 1 (underlay) maps to [0 1], layer 2 (t-score) to [1 2]
cb = sharedColorbar(ax, L);
cb.Limits = [1 2];
cb.Ticks = linspace(1,2,3);
cb.TickLabels = linspace(cbar_tscore(1),cbar_tscore(2),3);
cb.Label.String = 't-score';
jointTitle(fig, axs, 'Activation Maps');
exportPanel(fig,[png_saveroot 'fig4_overlay.png'],fontSz);

%% mean of sub
fig = panelFigure(L, nMethod);
clear axs
for k = 1:nMethod
    name = names{k};
    ax = montageAxes(fig, L, k); axs(k) = ax;
    im('notick','row',nRow,mean(R.(name).sub/R.(name).ctrlmax, 4), 2e-2*[0 1]);
    colormap(ax,hot);
    title(ax,'');
    cornerLabel(ax, name);
end
cb = sharedColorbar(ax, L);
cb.Ticks = linspace(cb.Limits(1),cb.Limits(2),6);
jointTitle(fig, axs, 'Subtraction Mean (Fractional)');
exportPanel(fig,[png_saveroot 'fig4_subtraction_mean.png'],fontSz);

%%
function cornerLabel(ax, txt)
% white bold label in the top-left corner of an image axes
text(ax,0.015,0.985,txt,'Units','normalized','Color','w','FontWeight','bold', ...
    'HorizontalAlignment','left','VerticalAlignment','top','Interpreter','none');
end

function fig = panelFigure(L, n)
% figure sized (cm) to fit n montages, the colorbar and the title
fig = figure('Color','w','Units','centimeters');
fig.Position(3:4) = [2*L.m + n*L.Sw + (n-1)*L.gap + L.cbGap + L.cbW + L.cbRoom, L.m + L.S + L.top];
end

function ax = montageAxes(fig, L, k)
% axes for the k-th montage, L.Sw wide and L.S tall
ax = axes(fig,'Units','centimeters','Position',[L.m + (k-1)*(L.Sw+L.gap), L.m, L.Sw, L.S]);
end

function b = imageBox(ax)
% [x y w h] (cm) of the image actually drawn in ax: with equal data aspect the
% image fills the axes box in one direction only, centred in the other
p = ax.Position;  dar = diff(ax.XLim)/diff(ax.YLim);
if p(3)/p(4) > dar, h = p(4); w = h*dar; else, w = p(3); h = w/dar; end
b = [p(1) + (p(3)-w)/2, p(2) + (p(4)-h)/2, w, h];
end

function cb = sharedColorbar(ax, L)
% colorbar of ax, right of its montage and exactly as tall as the image
cb = colorbar(ax);
cb.Units = 'centimeters';
b = imageBox(ax);
cb.Position = [b(1) + b(3) + L.cbGap, b(2), L.cbW, b(4)];
end

function jointTitle(fig, axs, txt)
% bold title centred over the montages, just above the image tops
b1 = imageBox(axs(1));  b2 = imageBox(axs(end));
xc = (b1(1) + b2(1) + b2(3))/2;  top = max(b1(2)+b1(4), b2(2)+b2(4));
a = annotation(fig,'textbox','String',txt,'FontWeight','bold','EdgeColor','none', ...
    'Margin',0,'HorizontalAlignment','center','VerticalAlignment','bottom');
a.Units = 'centimeters';
a.Position = [xc-5, top+0.08, 10, 0.6];
end

function exportPanel(fig, fname, fontSz)
% export fig at its printed size with all text at fontSz (pt)
set(findall(fig,'-property','FontSize'),'FontSize',fontSz);
exportgraphics(fig, fname, 'Resolution', 600);
end
