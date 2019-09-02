% fNIRs 101
clc; clear all;
folder=('E:\fnirs_data\Nirxdata\EventAnalysis');  %Copy directory
files = dir (folder);
raw = nirs.io.loadDirectory(folder);
Fs=2;


data_cond11_run=[];
data_cond21_run=[];
data_cond10_run=[];
data_cond20_run=[];
data_baseline_run =[];
%%
for z=1: size(raw,1)
    
    data_cond11=[];
    data_cond21=[];
    data_cond10=[];
    data_cond20=[];
    data_baseline=[];
    index10= [];
    index20= [];
    index11= [];
    index21= [];
    
    data = raw(z);
    j = nirs.modules.RemoveStimless( );
    j = nirs.modules.Resample( j );
    j.Fs = Fs;
    j = nirs.modules.OpticalDensity( j );
    j = nirs.modules.BeerLambertLaw( j );
    hb = j.run( data);
    
    %% Estudo da Baseline
    data_baseline(1,:,:) = hb.data(7:23,:);
    data_baseline(2,:,:) = hb.data(24:40,:);
    data_baseline(3,:,:) = hb.data(end-17:end-1,:);
    data_baseline(4,:,:) = hb.data(end-34 : end-18,:);
    
    %concatenate data per run
    for e=1:size (data_baseline,1)
        data_baseline_run= [data_baseline_run; data_baseline(e,:,:)];
    end
    
    %% Trigger Analysis
    
    for i=1:hb.stimulus.count
        verify11(i) = (strcmp(hb.stimulus.keys{i}, 'stim_channel11'));
        verify21(i) = (strcmp(hb.stimulus.keys{i}, 'stim_channel21'));
        verify10(i) = (strcmp(hb.stimulus.keys{i}, 'stim_channel10'));
        verify20(i) = (strcmp(hb.stimulus.keys{i}, 'stim_channel20'));
    end
    index10=find(verify10, 1, 'first');
    index11=find(verify11, 1, 'first');
    index20=find(verify20, 1, 'first');
    index21=find(verify21, 1, 'first');
    
    
    
    %% Estudo das Transições (condição 11 e 21)
    
    PreStim =2*Fs; % TimePoint
    PosStim =6*Fs;
    
    %condition 11
    
    if isempty (index11) == 1
        disp ('Nao existe Condição nesta run')
        
    else
        
        for i=1: numel(hb.stimulus.values{index11}.onset)
            pre_cond11 = round(hb.stimulus.values{index11}.onset(i)*Fs -PreStim);
            pos_cond11 = round(hb.stimulus.values{index11}.onset(i)*Fs + PosStim);
            data_cond11(i,:,:) = hb.data( [pre_cond11:pos_cond11],:);
        end
        
        %concatenate data per run
        for e=1:numel(hb.stimulus.values{index11}.onset)
            data_cond11_run= [data_cond11_run; data_cond11(e,:,:)];
        end
    end

    
    %% condition 21
    
    if isempty(index21) == 1
        disp ('Nao existe Condição nesta run')
        
    else
        for i=1: numel(hb.stimulus.values{index21}.onset)
            pre_cond21 = round(hb.stimulus.values{index21}.onset(i)*Fs -PreStim);
            pos_cond21 = round(hb.stimulus.values{index21}.onset(i)*Fs + PosStim);
            data_cond21(i,:,:) = hb.data( [pre_cond21:pos_cond21],:);
        end
        
        %concatenate data per run
        for e=1:numel(hb.stimulus.values{index21}.onset)
            data_cond21_run= [data_cond21_run; data_cond21(e,:,:)];
        end
    end
    
    
    %% Estudo das Condições Estáveis  (condição 10 e 20)
    
    % Definir o intervalo: Queremos um intervalo de 8 pontos que começa 8 segundos após a transição
    PreStim = 8*Fs; % TimePoint
    PosStim = 16*Fs;
    
    %condition 10
    if isempty(index10) == 1
        disp ('Nao existe Condição nesta run')
        
        
    else
        for i=1: numel(hb.stimulus.values{index10}.onset)
            pre_cond10 = round(hb.stimulus.values{index10}.onset(i)*Fs +PreStim);
            pos_cond10 = round(hb.stimulus.values{index10}.onset(i)*Fs + PosStim);
            data_cond10(i,:,:) = hb.data( [pre_cond10:pos_cond10],:);
        end
        
        %concatenate data per run
        for e=1:numel(hb.stimulus.values{index10}.onset)
            data_cond10_run= [data_cond10_run; data_cond10(e,:,:)];
        end
    end
    

    %% condition 20
    
    if isempty(index20) == 1
        disp ('Nao existe Condição nesta run')
    else
        for i=1: numel(hb.stimulus.values{index20}.onset)
            pre_cond20 = round(hb.stimulus.values{index20}.onset(i)*Fs +PreStim);
            pos_cond20 = round(hb.stimulus.values{index20}.onset(i)*Fs + PosStim);
            data_cond20(i,:,:) = hb.data( [pre_cond20:pos_cond20],:);
        end
        
        %concatenate data per run
        for e=1:numel(hb.stimulus.values{index20}.onset)
            data_cond20_run= [data_cond20_run; data_cond20(e,:,:)];
        end
        
    end
   
end

label = hb.probe.link
channel = 1:40;
nrow = size(label,1);
label.Channel = channel'
label =label (:,[4,1,2,3])


save('EventAnalysis_FNIRS.mat', 'data_baseline_run', 'data_cond10_run', 'data_cond11_run', 'data_cond20_run', 'data_cond21_run' ,'label' )
