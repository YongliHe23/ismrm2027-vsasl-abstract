% Figure 3 panels: noOVS | OVS side by side, one shared colorbar per panel.
% overlayview: /home/yonglihe/github/fMRI-processing/processing/overlayview.m
addpath('/home/yonglihe/github/fMRI-processing/processing');
load('var4fig3.mat');
png_saveroot = '../figures/';
fontSz = 8;        % pt
% manual layout (cm): two square montages side by side, shared colorbar on the right.
% tiledlayout left the montages unequal in size, so the axes are placed by hand.
L.S   = 7.0;   % montage side
L.gap = 0.3;   % between montages
L.m   = 0.1;   % left/bottom margin
L.top = 0.8;   % room for the title
L.cbGap = 0.25; L.cbW = 0.35; L.cbRoom = 1.3;   % colorbar offset, width, room for its labels

%% overlayview
cbar_tscore = [4,8];
fig = panelFigure(L, nMethod);
for k = 1:nMethod
    name = names{k};
    MATFILE = load([R.(name).output_dir 'ims_asl.mat']); %load perfusion image before smooth for underlay

    if isSENSE
        img = flip(MATFILE.im_sense,2);
    else
        img = flip(MATFILE.imsos,2);
    end
    undlay = abs(img(:,:,:,3)); % 2nd tag
    msk = undlay > prctile(undlay(:),99.9)*0.2;

    cbar_und = [min(abs(undlay(:))),max(abs(undlay(:)))];
    ov1 = overlayview;
    % no per-tile colorbars; one shared t-score bar is added after the loop
    ov1.addlayer(undlay,'caxis',cbar_und,'cloc',[]);
    ov1.addlayer(R.(name).tmap,'caxis',cbar_tscore,'cmap','hot','name','t-score','mask',msk,'cloc',[]);

    ax = montageAxes(fig, L, k);
    ov1.show('viewargs',{'row',4,'notick'});
    title(ax,'');
    cornerLabel(ax, name);
end
% composite colormap: layer 1 (underlay) maps to [0 1], layer 2 (t-score) to [1 2]
cb = sharedColorbar(ax, L, nMethod);
cb.Limits = [1 2];
cb.Ticks = linspace(1,2,3);
cb.TickLabels = linspace(cbar_tscore(1),cbar_tscore(2),3);
cb.Label.String = 't-score';
sgtitle(fig,'Activation Maps','FontWeight','bold');
exportPanel(fig,[png_saveroot 'fig3_overlay.png'],fontSz);

%% mean of sub
fig = panelFigure(L, nMethod);
for k = 1:nMethod
    name = names{k};
    ax = montageAxes(fig, L, k);
    im('notick',mean(R.(name).sub/R.(name).ctrlmax, 4), 2e-2*[0 1]);
    colormap(ax,hot);
    title(ax,'');
    cornerLabel(ax, name);
end
cb = sharedColorbar(ax, L, nMethod);
cb.Ticks = linspace(cb.Limits(1),cb.Limits(2),6);
sgtitle(fig,'Subtraction Mean (Fractional)','FontWeight','bold');
exportPanel(fig,[png_saveroot 'fig3_subtraction_mean.png'],fontSz);

%%
function cornerLabel(ax, txt)
% white bold label in the top-left corner of an image axes
text(ax,0.015,0.985,txt,'Units','normalized','Color','w','FontWeight','bold', ...
    'HorizontalAlignment','left','VerticalAlignment','top','Interpreter','none');
end

function fig = panelFigure(L, n)
% figure sized (cm) to fit n montages, the colorbar and the title
fig = figure('Color','w','Units','centimeters');
fig.Position(3:4) = [2*L.m + n*L.S + (n-1)*L.gap + L.cbGap + L.cbW + L.cbRoom, L.m + L.S + L.top];
end

function ax = montageAxes(fig, L, k)
% axes for the k-th montage, an L.S x L.S square
ax = axes(fig,'Units','centimeters','Position',[L.m + (k-1)*(L.S+L.gap), L.m, L.S, L.S]);
end

function cb = sharedColorbar(ax, L, n)
% colorbar of ax, placed right of the last montage and as tall as it
cb = colorbar(ax);
cb.Units = 'centimeters';
cb.Position = [L.m + n*L.S + (n-1)*L.gap + L.cbGap, L.m, L.cbW, L.S];
end

function exportPanel(fig, fname, fontSz)
% export fig at its printed size with all text at fontSz (pt)
set(findall(fig,'-property','FontSize'),'FontSize',fontSz);
exportgraphics(fig, fname, 'Resolution', 600);
end
