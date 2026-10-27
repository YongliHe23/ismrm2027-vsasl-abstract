% Generate figures for ismrm2027 abstract on VSASL + OVS fMRI
png_saveroot = '../figures/';
% zoom-in panels are exported at their printed size, so fig1.tex places them unscaled
panelW = [4.5 3.22 3.86 3.86]; % cm, widths of panels (b)-(e), = \pw list in latex/fig1.tex
fontSz = 7;    % pt
ylabSz = 5;    % pt, y-axis labels
tickSz = 5;    % pt, tick labels
%% Sequence Diagram
seqFile = '/home/yonglihe/codes/matlab/VSASL/sosp/ASL/sequence/scanfiles/20261011/asl_brain_ovs_R1_VSI.seq';
seq = mr.Sequence();
seq.read(seqFile);

% FT-VSI
gam = 42.576e6; %Hz/T
iTag = 4;
iCtrl = iTag + numel(seq.blockEvents)/2;
bTag = seq.getBlock(iTag);
bCtrl = seq.getBlock(iCtrl);

t_rf = (bTag.rf.delay + bTag.rf.t)*1e3; %ms
B1 = bTag.rf.signal/gam*1e6; %uT
t_g = (bTag.gz.delay + bTag.gz.tt)*1e3; %ms
GzTag = bTag.gz.waveform/gam*1e3; %mT/m
GzCtrl = bCtrl.gz.waveform/gam*1e3; % mT/m



fig = figure('Position',[100 100 700 450]);
clear ax
tl = tiledlayout(3,1,'TileSpacing','tight','Padding','compact');
ax(1) = nexttile; plot(t_rf,abs(B1),'k','LineWidth',1.2);   ylabel({'|B_1|','(\muT)'}); title('FT-VSI')
ax(2) = nexttile; plot(t_rf,angle(B1),'Color',[.65 .65 .65],'LineWidth',0.6); ylabel({'\angle B_1','(rad)'});
ylim([-pi pi]); yticks([-pi 0 pi]); yticklabels({'-\pi','0','\pi'});
ax(3) = nexttile;
% control underneath in light gray, label on top
plot(t_g,GzCtrl,'Color',[.6 .6 .6],'LineWidth',1); hold on
plot(t_g,GzTag,'b','LineWidth',1.2);
ylabel({'G_z','(mT/m)'});
xlabel('Time (ms)');
% colored labels instead of a legend; headroom above the lobes for them
ylim([-20 45]); yticks([-20 0 20]);
text(0.99,1,'{\color{blue}Label} {\color[rgb]{.6 .6 .6}Control}','Units','normalized', ...
    'HorizontalAlignment','right','VerticalAlignment','top','Interpreter','tex');
set(ax(1:2),'XTickLabel',{});
set(ax,'Box','off');
linkaxes(ax,'x'); xlim([0 bTag.blockDuration*1e3]);
exportPanel(fig,[png_saveroot,'zoomin_label_pulse.png'],[panelW(1) 5],fontSz,ylabSz,tickSz);

%%
% Vascular crusher
iVasc = 13;
bVasc = seq.getBlock(iVasc);
t_rf = (bVasc.rf.delay + bVasc.rf.t)*1e3; %ms
B1Vasc = bVasc.rf.signal/gam*1e6; %uT
t_g = (bVasc.gz.delay + bVasc.gz.tt)*1e3; %ms
GzVasc = bVasc.gz.waveform/gam*1e3; %mT/m

fig = figure('Position',[100 100 700 450]);
clear ax
tl = tiledlayout(3,1,'TileSpacing','tight','Padding','compact');
ax(1) = nexttile; plot(t_rf,abs(B1Vasc),'k','LineWidth',1.2); title('BIR8-sat')
ax(2) = nexttile; plot(t_rf,angle(B1Vasc),'Color',[.65 .65 .65],'LineWidth',0.6);
ylim([-pi pi]); yticks([-pi 0 pi]); yticklabels({'-\pi','0','\pi'});
ax(3) = nexttile;
plot(t_g,GzVasc,'b','LineWidth',1.2);
xlabel('Time (ms)');
set(ax(1:2),'XTickLabel',{})
set(ax,'Box','off');
linkaxes(ax,'x'); xlim([0 bVasc.blockDuration*1e3]);
exportPanel(fig,[png_saveroot,'zoomin_vasc_pulse.png'],[panelW(2) 5],fontSz,ylabSz,tickSz);

%%
% OVSprep
iOVSprep = [15 16];
prep_wav = seq.waveforms_and_times(true,iOVSprep);
% each channel has its own time axis, starting at 0 at the first block of the range
t_ch = cellfun(@(w) w(1,:)*1e3, prep_wav(1:4), 'UniformOutput', false); %ms
B1Prep = prep_wav{4}(2,:)/gam*1e6; %uT
GPrep = cellfun(@(w) w(2,:)/gam*1e3, prep_wav(1:3), 'UniformOutput', false); %mT/m

fig = figure('Position',[100 100 700 600]);
tl = tiledlayout(5,1,'TileSpacing','tight','Padding','compact');
clear ax
ax(1) = nexttile; plot(t_ch{4},abs(B1Prep),'k','LineWidth',1.2);   ylabel({'|B_1|','(\muT)'}); title('OVSprep (\times 5)','Interpreter','tex')
ax(2) = nexttile; plot(t_ch{4},angle(B1Prep),'Color',[.65 .65 .65],'LineWidth',0.6); ylabel({'\angle B_1','(rad)'});
ylim([-pi pi]); yticks([-pi 0 pi]); yticklabels({'-\pi','0','\pi'});
glab = {'G_x','G_y','G_z'};
gcol = lines(3);
for k = 1:3
    ax(k+2) = nexttile; plot(t_ch{k},GPrep{k},'Color',gcol(k,:),'LineWidth',1.2); ylabel({glab{k},'(mT/m)'});
end
xlabel('Time (ms)');
set(ax(1:4),'XTickLabel',{});
set(ax,'Box','off');
linkaxes(ax,'x'); xlim([0 sum(seq.blockDurations(iOVSprep(1):iOVSprep(2)))*1e3]);
exportPanel(fig,[png_saveroot,'zoomin_ovsprep.png'],[panelW(3) 7],fontSz,ylabSz,tickSz);

%%
% readout: first of 16 shots, 8 blocks each
iShot = [25 32];
ro_wav = seq.waveforms_and_times(true,iShot);
t_ch = cellfun(@(w) w(1,:)*1e3, ro_wav(1:4), 'UniformOutput', false); %ms
B1RO = ro_wav{4}(2,:)/gam*1e6; %uT
GRO = cellfun(@(w) w(2,:)/gam*1e3, ro_wav(1:3), 'UniformOutput', false); %mT/m

fig = figure('Position',[100 100 700 600]);
tl = tiledlayout(5,1,'TileSpacing','tight','Padding','compact');
clear ax
ax(1) = nexttile; plot(t_ch{4},abs(B1RO),'k','LineWidth',1.2); title('Readout (\times N_z)','Interpreter','tex')
ax(2) = nexttile; plot(t_ch{4},angle(B1RO),'Color',[.65 .65 .65],'LineWidth',0.6);
ylim([-pi pi]); yticks([-pi 0 pi]); yticklabels({'-\pi','0','\pi'});
for k = 1:3
    ax(k+2) = nexttile; plot(t_ch{k},GRO{k},'Color',gcol(k,:),'LineWidth',1.2);
end
xlabel('Time (ms)');
set(ax(1:4),'XTickLabel',{});
set(ax,'Box','off');
linkaxes(ax,'x'); xlim([0 sum(seq.blockDurations(iShot(1):iShot(2)))*1e3]);
exportPanel(fig,[png_saveroot,'zoomin_readout.png'],[panelW(4) 7],fontSz,ylabSz,tickSz);

%%
function exportPanel(fig, fname, sz, fontSz, ylabSz, tickSz)
% export fig at printed size sz = [width height] (cm) with all text at fontSz (pt),
% y-axis labels at ylabSz and tick labels at tickSz (pt)
fig.Units = 'centimeters';
fig.Position(3:4) = sz;
set(findall(fig,'-property','FontSize'),'FontSize',fontSz);
% axes FontSize sets the tick labels; titles/labels already have their own size
for a = findall(fig,'Type','axes')', a.FontSize = tickSz; a.YLabel.FontSize = ylabSz; end
% thinner lines at printed size
for h = findall(fig,'Type','line')', h.LineWidth = 0.6*h.LineWidth; end
exportgraphics(fig,fname,'Resolution',600);
end
