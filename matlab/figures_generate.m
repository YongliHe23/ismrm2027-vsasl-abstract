% Generate figures for ismrm2027 abstract on VSASL + OVS fMRI

%% Sequence Diagram
seqFile = '/home/yonglihe/codes/matlab/VSASL/sosp/ASL/sequence/scanfiles/20261011/asl_brain_ovs_R1_VSI.seq';
seq = mr.Sequence();
seq.read(seqFile);

fig = seq.paperPlot('blockRange',[1,50],'lineWidth',1.8);