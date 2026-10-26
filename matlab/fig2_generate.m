% Figure 2: background-suppression timing design.
% Mz(t) of static CSF/GM/WM through one preparation, showing how D1/D2 are
% chosen so CSF crosses zero exactly at the readout while GM/WM stay suppressed.
%
% Pure simulation -- no .seq is read, so this is kept separate from
% figures_generate.m (which builds the sequence-diagram panels of Fig. 1).
% Block names, colors and the D0/D1/D2/D3 notation follow Fig. 1
% (latex/seq_diagm_body.tex, latex/seq_colors.tex).
%
% Model (same as sosp/ASL/sequence/optimizeBGStiming.m, csfTraj):
%   presat -> Mz = 0, recover D0, FT-VSI label (static spins inverted to
%   -eta_lab*Mz), recover D1, adiabatic inversion (-eta_inv), recover D2,
%   inversion again, recover to readout. Pulses are instantaneous here; the
%   finite module durations only matter for the realizability of D3.

png_saveroot = '../figures/';
panelW = 8.6;   % cm, printed width
panelH = 6.0;   % cm
tS     = 5;     % pt, all text (matches the zoom-in panels of Fig. 1)

%% ---------------------------------------------------------------- parameters
T1   = [4.3 1.2 0.8];        % s, CSF / GM / WM at 3T
nm   = {'CSF','GM','WM'};
cols = [0.17 0.47 0.84;      % CSF  blue
        0.89 0.29 0.28;      % GM   red
        0.42 0.42 0.42];     % WM   gray

eta_lab = 0.81;   % |Mz| after the FT-VSI label, relative to +1 (Bloch sim of FTVSI/)
eta_inv = 0.90;   % adiabatic inversion efficiency

% optimized timing, brain / FT-VSI label / vascular crusher + OVS prep
% (setup_asl_params.m; PLD pinned so every arm shares a TR)
D0  = 2.0000;     % s, presat -> label
D1  = 1.1573;     % s, label  -> Inv1
D2  = 0.1492;     % s, Inv1   -> Inv2
PLD = 1.4000;     % s, label  -> readout

% drawn block widths (s). The label width is the real FT-VSI duration; presat
% and the inversions are widened to stay visible at this time scale.
wPresat = 0.025; wLabel = 0.052; wInv = 0.012;

% block fills, from latex/seq_colors.tex
cGray  = hex2rgb('C9C9C9');   % presat, Inv1, Inv2  (cgray, darkened to read on white)
cLabel = hex2rgb('F9CB9C');   % label               (clabel)
cLabDk = hex2rgb('E69138');   % label text          (clabeldk)

tLab = D0; tI1 = tLab + D1; tI2 = tI1 + D2; tRO = tLab + PLD;

%% ---------------------------------------------------------------- trajectory
fig = figure('Color','w','Position',[100 100 900 620]);
tl  = tiledlayout(2,1,'TileSpacing','compact','Padding','compact');
yl  = [-1.0 1.0];
Mend = zeros(1,3);

for row = 1:2
    ax = nexttile; hold on

    % --- blocks, behind the curves
    patch([0 wPresat wPresat 0],       yl([1 1 2 2]), cGray,  'EdgeColor','none');
    patch(tLab+[0 wLabel wLabel 0],    yl([1 1 2 2]), cLabel, 'EdgeColor','none');
    for te = [tI1 tI2]
        patch(te+[0 wInv wInv 0],      yl([1 1 2 2]), cGray,  'EdgeColor','none');
    end
    xline(tRO,'-','Color','k','LineWidth',0.9);
    yline(0,':','Color',[.45 .45 .45]);

    % --- Mz(t)
    for i = 1:3
        [t,m] = bgsTraj(T1(i), D0, D1, D2, PLD, eta_lab, eta_inv);
        plot(t, m, '-', 'Color', cols(i,:), 'LineWidth', 1.3);
        Mend(i) = m(end);
    end
    set(ax,'FontSize',tS,'TickDir','out','YTick',-1:0.5:1,'Layer','top');
    box off; ylim(yl); ylabel('M_z / M_0','FontSize',tS);

    if row == 1
        xlim([0 tRO+0.05]);
        % D0 and D1 are the only intervals legible at full scale. They sit at
        % different heights: before the label every curve is positive, so D0
        % can ride high; after it GM/WM dip to -0.75, so D1 must clear that.
        dimLine(wPresat, tLab,        -0.30, 'D0', tS);
        dimLine(tLab+wLabel, tI1,     -0.86, 'D1', tS);
        dimLine(tLab+wLabel, tRO,      0.92, 'PLD', tS);
        text(wPresat+0.02, -0.99,'presat','FontSize',tS, ...
            'VerticalAlignment','bottom','Color',[.3 .3 .3]);
        % right-aligned into the empty strip left of the label block, so it
        % clears the D1 bracket that starts at the block's right edge
        text(tLab-0.02, -0.99,'label (FT-VSI)','FontSize',tS, ...
            'HorizontalAlignment','right','VerticalAlignment','bottom', ...
            'Color',cLabDk,'FontWeight','bold');
        % band marking the range expanded below -- drawn last, so send it back
        hb = patch([tI1-0.03 tRO+0.05 tRO+0.05 tI1-0.03], yl([1 1 2 2]), ...
                   [.93 .93 .93],'EdgeColor','none');
        uistack(hb,'bottom');
    else
        xlim([tI1-0.03 tRO+0.05]);
        dimLine(tI1+wInv, tI2,        -0.80, 'D2', tS);
        dimLine(tI2+wInv, tRO,        -0.93, 'D3 + vasc + OVSprep', tS);
        text(tI1+wInv/2, 0.97,'Inv1','FontSize',tS,'HorizontalAlignment','center', ...
            'VerticalAlignment','top','Color',[.3 .3 .3]);
        text(tI2+wInv/2, 0.97,'Inv2','FontSize',tS,'HorizontalAlignment','center', ...
            'VerticalAlignment','top','Color',[.3 .3 .3]);
        % colored inline labels instead of a legend box (as in Fig. 1), stacked
        % in the NE corner -- free here, since no curve exceeds +0.33 after Inv2
        for i = 1:3
            text(tRO+0.045, 0.95-0.15*(i-1), nm{i},'FontSize',tS,'Color',cols(i,:), ...
                'FontWeight','bold','HorizontalAlignment','right', ...
                'VerticalAlignment','middle');
        end
        % WM ends only 0.11 above GM, so lift its value to clear GM's
        dyLbl = [0 0 0.09];
        for i = 1:3
            lbl = sprintf('%+.2f', Mend(i));
            if abs(Mend(i)) < 0.005, lbl = sprintf('%+.3f', Mend(i)); end
            text(tRO-0.006, Mend(i)+0.085+dyLbl(i), lbl,'FontSize',tS,'Color',cols(i,:), ...
                'HorizontalAlignment','right','VerticalAlignment','middle');
        end
        xlabel('time from presat (s)','FontSize',tS);
    end
end

fprintf('Mz at readout:  CSF %+.4f   GM %+.4f   WM %+.4f\n', Mend);
fprintf('timing: D0=%.3f  D1=%.4f  D2=%.4f  PLD=%.4f s\n', D0, D1, D2, PLD);
exportPanel(fig, [png_saveroot 'fig2_bgs_timing.png'], [panelW panelH], tS);

%% ---------------------------------------------------------------- helpers
function [t, m] = bgsTraj(T1, D0, D1, D2, PLD, eta_lab, eta_inv)
% Piecewise Mz(t) with instantaneous pulse jumps. Mirrors csfTraj/sampleTraj
% in optimizeBGStiming.m for opt.label = 'inv' and vs_static = 1.
durs  = [D0, D1, D2, PLD-D1-D2];
jumps = {@(M) -eta_lab*M, @(M) -eta_inv*M, @(M) -eta_inv*M, @(M) M};
t = 0; m = 0; cur = 0; tc = 0;
for k = 1:numel(durs)
    tt = linspace(0, durs(k), max(2, round(durs(k)/5e-4)));
    mm = 1 - (1-cur).*exp(-tt/T1);
    t  = [t, tc+tt(2:end)];  m = [m, mm(2:end)];       %#ok<AGROW>
    tc = tc + durs(k);  cur = jumps{k}(mm(end));
    t  = [t, tc];            m = [m, cur];             %#ok<AGROW>  vertical jump
end
end

function dimLine(x1, x2, y, txt, tS, lw)
% double-ended dimension arrow, matching the \dim style of Fig. 1's TikZ
% (Stealth heads both ends). Heads are drawn as filled triangular markers so
% everything stays in data coordinates -- annotation() would need figure-
% normalized units, which tiledlayout makes awkward to compute.
if nargin < 6 || isempty(lw), lw = 0.30; end   % thin, so the rules stay recessive
c = [.3 .3 .3];
plot([x1 x2],[y y],'-','Color',c,'LineWidth',lw);
plot(x1, y, '<', 'MarkerSize',2.4,'MarkerFaceColor',c,'MarkerEdgeColor','none');
plot(x2, y, '>', 'MarkerSize',2.4,'MarkerFaceColor',c,'MarkerEdgeColor','none');
text((x1+x2)/2, y+0.055, txt,'HorizontalAlignment','center', ...
    'VerticalAlignment','bottom','FontSize',tS,'Interpreter','tex');
end

function c = hex2rgb(h)
c = double(sscanf(h,'%2x%2x%2x'))'/255;
end

function exportPanel(fig, fname, sz, tS)
% export at printed size sz = [width height] (cm) with all text at tS (pt)
fig.Units = 'centimeters';  fig.Position(3:4) = sz;
set(findall(fig,'-property','FontSize'),'FontSize',tS);
for h = findall(fig,'Type','line')', h.LineWidth = 0.85*h.LineWidth; end
exportgraphics(fig, fname, 'Resolution', 600);
end
