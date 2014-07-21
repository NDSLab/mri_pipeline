function varargout = ME_Combine(prescanPath,sourcePath, targetPath, numberOfEchoes,WeightVolumes,strname)

oldFolder=pwd;


KernelSize = 3;
numberOfRuns = 1;
deleteOrNot = 0;
smoothing = 0;
smoothingPrefix = 'r';

%% Initialization %%
addpath('/home/common/matlab/spm8');
addpath(pwd);
% warning off all

startVolume = 1;
cd(sourcePath);
TE = zeros(numberOfRuns,numberOfEchoes);

%% clear output folder %%

if exist([targetPath '/PAID_data']) == 7
    rmdir([targetPath '/PAID_data'],'s');
end
if exist([targetPath '/converted_Weight_Volumes']) == 7
    rmdir([targetPath '/converted_Weight_Volumes'],'s');
end
if exist([targetPath '/converted_Volumes']) == 7
    rmdir([targetPath '/converted_Volumes'],'s');
end
delete([targetPath '/*']);
disp('Output folder is cleared!')

%% Display folders and variables
disp('Prescan folder:')
disp(prescanPath)
disp('Input folder:')
disp(sourcePath)
disp('Output folder:')
disp(targetPath)
str1=sprintf('Echoes: %d', numberOfEchoes);
disp(str1)
str2=sprintf('Volumes: %d', WeightVolumes);
disp(str2)

%% Dicom2Nifti %%

if ~isempty(prescanPath) %% first, prescan volumes are converted
    cd([targetPath]); 
    mkdir('converted_Weight_Volumes');
    cd([prescanPath]);
    TE_prescan = RB_ME_PAID_Dicom2Nifti(prescanPath, numberOfRuns, size(TE,2));
    unix(['mv ' prescanPath '/*.nii ' targetPath '/converted_Weight_Volumes']);
    cd([sourcePath]);
end

cd([targetPath]);
mkdir('converted_Volumes');
cd([sourcePath]);
TE = RB_ME_PAID_Dicom2Nifti(pwd, numberOfRuns, size(TE,2));
filesToBeMoved = dir('*.nii');
filesToBeMoved = char(filesToBeMoved.name);
fileMoveForLinux(sourcePath, [targetPath '/converted_Volumes'], filesToBeMoved, 100);
disp('DICOMs are converted!')


%% Realignment %%

if isempty(prescanPath) %% there is no prescan
    cd([targetPath '/converted_Volumes']);
    disp('Realignment started')

    filesTemp = dir('*01.nii');
    files = char(zeros(length(filesTemp),length(filesTemp(1).name)+2,size(TE,2)));
    for i=startVolume:size(files,1)
        files(i,1:length(filesTemp(i).name),1) = filesTemp(i).name;
    end

    spm_realign(files(:,:,1)); %% first echo volumes is realigned to the first volume of first echo

    for j=2:size(TE,2)
        filesTemp = dir(['*' num2str(j) '.nii']); %% assuming number of echoes is less than 10!
        for i=startVolume:size(files(:,:,j),1)
            files(i,1:length(filesTemp(i).name),j) = filesTemp(i).name;
        end
    end
    
    % Transformation matrices of all volumes of all echoes 
    % (except first echo) are changed to the matrix of first echo,
    % thus, realigned.
    for i=1:size(files,1)
        V{1} = spm_get_space(files(i,:,1));
        for j=2:size(TE,2)
            spm_get_space(files(i,:,j),V{1});
        end
    end
        
    resliceFiles = dir('*.nii'); %% reslicing of all volumes
    resliceFiles = char(resliceFiles.name);
    spm_reslice(resliceFiles);
    
else  %% with prescan
    cd([targetPath '/converted_Weight_Volumes']); %% first, prescan volumes are realigned
    disp('Realignment of prescan volumes started')

    filesTemp = dir('*01.nii');
    filesPrescan = char(zeros(length(filesTemp),length(filesTemp(1).name)+2,size(TE,2)));
    for i=startVolume:size(filesPrescan,1)
        filesPrescan(i,1:length(filesTemp(i).name),1) = filesTemp(i).name;
    end
    
    cd([targetPath '/converted_Volumes']);
    
    filesTemp = dir('*01.nii');
    files = char(zeros(length(filesTemp),length(filesTemp(1).name)+2,size(TE,2)));
    for i=startVolume:size(files,1)
        files(i,1:length(filesTemp(i).name),1) = filesTemp(i).name;
    end
       
      
    cd([targetPath '/converted_Weight_Volumes']);
    filesToBeMoved = dir('*01.nii');
    filesToBeMoved = char(filesToBeMoved.name);
    fileMoveForLinux([targetPath '/converted_Weight_Volumes'], [targetPath '/converted_Volumes'], filesToBeMoved, 1000);
    
    cd([targetPath '/converted_Volumes']);
    filesFirstEcho = cat(1,filesPrescan(:,:,1),files(:,:,1));    
    spm_realign(filesFirstEcho(:,:,1)); %% first echo volumes are realigned to the first volume of first echo
    
    % move first echoes of prescan back to their original directory
    fileMoveForLinux([targetPath '/converted_Volumes/'], [targetPath '/converted_Weight_Volumes'], filesPrescan(:,1:end-2,1), 1000);
    
    cd([targetPath '/converted_Weight_Volumes']);
    
    for j=2:size(TE,2)
        filesTemp = dir(['*' num2str(j) '.nii']); %% assuming number of echoes is less than 10!
        for i=startVolume:size(filesPrescan(:,:,j),1)
            filesPrescan(i,1:length(filesTemp(i).name),j) = filesTemp(i).name;
        end
    end
 
    % Transformation matrices of all volumes of all echoes 
    % (except first echo) are changed to the matrix of first echo,
    % thus, realigned.
    for i=1:size(filesPrescan,1)
        VPrescan{1} = spm_get_space(filesPrescan(i,:,1));
        for j=2:size(TE,2)
            spm_get_space(filesPrescan(i,:,j),VPrescan{1});
        end
    end
    % Now, all the prescan volumes, also echoes 2,3,..
    % are realigned ==> by spm_getspace
    % now, taking them back to ..\converted volumes
    % to reslice, but this part should be implmeneted in a better and
    % efficient way
    
%     filesTemp = dir('*.nii');
%     filesPrescan = char(zeros(length(filesTemp),length(filesTemp(1).name)+2,size(TE,2)));
%     for i=startVolume:size(filesPrescan,1)
%         filesPrescan(i,1:length(filesTemp(i).name),1) = filesTemp(i).name;
%     end    
%     resliceFiles = dir('*.nii'); %% reslicing of weight volumes
%     resliceFiles = char(resliceFiles.name);
%     spm_reslice(resliceFiles);
    
    cd([targetPath '/converted_Volumes']); %% all the other volumes are realigned
    disp('Realignment of all the other volumes started')
    
    for j=2:size(TE,2)
        filesTemp = dir(['*' num2str(j) '.nii']); %% assuming number of echoes is less than 10!
        for i=startVolume:size(filesTemp,1)
            files(i,1:length(filesTemp(i).name),j) = filesTemp(i).name;
        end
    end
    
    % Transformation matrices of all volumes of all echoes 
    % (except first echo) are changed to the matrix of first echo,
    % thus, realigned.
    for i=1:size(files,1)
        V{1} = spm_get_space(files(i,:,1));
        for j=2:size(TE,2)
            spm_get_space(files(i,:,j),V{1});
        end
    end

    for i=1:size(TE,2)        
        fileMoveForLinux([targetPath '/converted_Weight_Volumes'], [targetPath '/converted_Volumes'], filesPrescan(:,1:end-2,i), 1000);
    end
    
    
    cd([targetPath '/converted_Volumes']);
    
    resliceFiles = dir('*.nii'); %% reslicing of original scan volumes
    resliceFiles = char(resliceFiles.name);
    spm_reslice(resliceFiles);
    
    for i=1:size(TE,2)
        fileMoveForLinux([targetPath '/converted_Volumes'], [targetPath '/converted_Weight_Volumes'], filesPrescan(:,1:end-2,i), 1000);
        fileMoveForLinux([targetPath '/converted_Volumes'], [targetPath '/converted_Weight_Volumes'], cat(2,repmat('r',[WeightVolumes 1]),filesPrescan(:,1:end-2,i)), 1000);
    end
    
end

disp('Realignment finished!')

%% Smoothing %%
if smoothing
    smoothingPrefix = 's';
    if isempty(prescanPath) %% there is no prescan
        for j=1:size(TE,2)    
            for i=startVolume:startVolume+WeightVolumes-1
                spm_smooth(['r' files(i,:,j)],['s' files(i,:,j)],KernelSize);
            end
        end
    else %% with prescan
        cd([targetPath '/converted_Weight_Volumes']);
        for j=1:size(TE,2)    
            for i=startVolume:startVolume+WeightVolumes-1
                spm_smooth(['r' filesPrescan(i,:,j)],['s' filesPrescan(i,:,j)],KernelSize);
            end
        end
        cd([targetPath '/converted_Volumes']);
    end
    disp('Smoothing is applied to weight calculation volumes')
end
%%

%% Weight Calculation%%

dimVolume = spm_vol(files(1,:,1));
dim = dimVolume.dim;

for i=1:size(TE,2)
    volume4D(:,:,:,:,i) = zeros(dim(1),dim(2),dim(3),WeightVolumes);
end

if isempty(prescanPath) %% there is no prescan
    for i=startVolume:startVolume+WeightVolumes-1
        for j=1:size(TE,2)
            V{j} = spm_vol([smoothingPrefix files(i,:,j)]);
            volume4D(:,:,:,i-(startVolume-1),j) = spm_read_vols(V{j});       
        end
    end
else
    cd([targetPath '/converted_Weight_Volumes']);
    for i=startVolume:startVolume+WeightVolumes-1
        for j=1:size(TE,2)
            V{j} = spm_vol([smoothingPrefix filesPrescan(i,:,j)]);
            volume4D(:,:,:,i-(startVolume-1),j) = spm_read_vols(V{j});       
        end
    end
    cd([targetPath '/converted_Volumes']);
end

for j=1:size(TE,2)
     tSNR(:,:,:,j) = mean(volume4D(:,:,:,:,j),4)./std(volume4D(:,:,:,:,j),0,4);
     CNR(:,:,:,j) = tSNR(:,:,:,j) * TE(1,j); %% assuming all runs have the same TEs!!
end

CNRTotal = sum(CNR,4);

for i=1:size(TE,2)
    weight(:,:,:,i) = CNR(:,:,:,i) ./ CNRTotal;
end

for i=startVolume:startVolume+size(files,1)-1
    
    for j=1:size(TE,2)
        V{j} = spm_vol(['r' files(i,:,j)]);
    end    
    
    newVolume = V{1};
    if i<10
        newVolume.fname = [strname '.000' num2str(i) '.nii'];
    elseif i<100
        newVolume.fname = [strname '.00' num2str(i) '.nii'];
    elseif i<1000
        newVolume.fname = [strname '.0' num2str(i) '.nii'];
    else
        newVolume.fname = [strname '.' num2str(i) '.nii'];
    end
    
    I_weighted = zeros(newVolume.dim);
    for j=1:size(TE,2)
        I(:,:,:,j) = spm_read_vols(V{j});
        I_weighted = I_weighted + I(:,:,:,j).*weight(:,:,:,j); 
    end        
      
    spm_create_vol(newVolume);
    spm_write_vol(newVolume,I_weighted);
    
end
cd(targetPath);
mkdir('PAID_data');
cd([targetPath '/converted_Volumes']);

% filesToBeMoved = dir('M_volume*');
filesToBeMoved = dir([strname '.*']);
filesToBeMoved = char(filesToBeMoved.name);
%movefile([handles.targetPath '/converted_Volumes'], [handles.targetPath '/PAID_data'], filesToBeMoved);

fileMoveForLinux([targetPath '/converted_Volumes'], [targetPath '/PAID_data'], filesToBeMoved, 1000);
listing=dir('r*.txt');
copyfile(listing(1,1).name,['realignment.parameters.',strname,'.txt'])
listing=dir('mean*.nii');
copyfile(listing(1,1).name,['me.combination.mean.',strname,'.nii'])
% copyfile('mean*.nii',char(['mean',strname,'.nii']))
filesToBeMoved = dir('*.txt');
filesToBeMoved = char(filesToBeMoved.name);

%movefile([handles.targetPath '/converted_Volumes'], [handles.targetPath '/PAID_data'], filesToBeMoved);
fileMoveForLinux([targetPath '/converted_Volumes'], [targetPath '/PAID_data'], filesToBeMoved, 1000);

disp('Volumes are combined!')
cd(oldFolder);

%% Delete unnecessary output files %%

if deleteOrNot
    filesTemp = dir('PAID_data/*.nii');
    cd([targetPath '/PAID_data']);
    filesTemp = dir('*.nii');
    for i=1:WeightVolumes
        delete([targetPath '/PAID_data/' filesTemp(i).name]);
    end
end


% % --- Executes on button press in checkbox1.
% function checkbox1_Callback(hObject, eventdata, handles)
% % hObject    handle to checkbox1 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hint: get(hObject,'Value') returns toggle state of checkbox1
% % temporaryData = guidata(hObject);
% handles.deleteOrNot = get(handles.checkbox1,'Value');
% guidata(hObject,handles);
% 
% 
% 
% % --- Executes on button press in checkbox2.
% function checkbox2_Callback(hObject, eventdata, handles)
% % hObject    handle to checkbox2 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% set(handles.edit9,'Visible','on');
% set(handles.text15,'Visible','on');
% set(handles.checkbox3,'Value',1);
% set(handles.pushbutton14,'Visible','on');
% % Hint: get(hObject,'Value') returns toggle state of checkbox2
% 
% 
% 
% function edit9_Callback(hObject, eventdata, handles)
% % hObject    handle to edit9 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% numberOfRuns = str2double(get(hObject, 'String'));
% if isnan(numberOfRuns)
%     set(hObject, 'String', 1);
%     errordlg('No input for # of runs, default value of 1 will be used','Error');
% end
% 
% handles.numberOfRuns = numberOfRuns;
% guidata(hObject,handles)
% 
% % Hints: get(hObject,'String') returns contents of edit9 as text
% %        str2double(get(hObject,'String')) returns contents of edit9 as a double
% 
% 
% % --- Executes during object creation, after setting all properties.
% function edit9_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to edit9 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: edit controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
% 
% 
% % 
% function edit10_Callback(hObject, eventdata, handles)
% % hObject    handle to edit10 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: get(hObject,'String') returns contents of edit10 as text
% %        str2double(get(hObject,'String')) returns contents of edit10 as a double
% 
% 
% % --- Executes during object creation, after setting all properties.
% function edit10_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to edit10 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: edit controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
% 
% 
% % --- Executes on button press in checkbox3.
% function checkbox3_Callback(hObject, eventdata, handles)
% % hObject    handle to checkbox3 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% set(handles.pushbutton14,'Visible','on');
% 
% % Hint: get(hObject,'Value') returns toggle state of checkbox3
% 
% 
% % --- Executes on button press in pushbutton10.
% function pushbutton10_Callback(hObject, eventdata, handles)
% % hObject    handle to pushbutton10 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% 
% 
% function edit11_Callback(hObject, eventdata, handles)
% % hObject    handle to edit11 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: get(hObject,'String') returns contents of edit11 as text
% %        str2double(get(hObject,'String')) returns contents of edit11 as a double
% 
% 
% % --- Executes during object creation, after setting all properties.
% function edit11_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to edit11 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: edit controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end


% % --- Executes on button press in pushbutton12.
% function pushbutton12_Callback(hObject, eventdata, handles)
% % hObject    handle to pushbutton12 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% handles.sourcePath = uigetdir(pwd, 'Select folder for DICOM data (INPUT)');
% guidata(hObject,handles)
% 
% 
% % --- Executes on button press in pushbutton13.
% function pushbutton13_Callback(hObject, eventdata, handles)
% % hObject    handle to pushbutton13 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% handles.targetPath = uigetdir(pwd, 'Select folder for NIFTI data (OUTPUT)');
% guidata(hObject,handles)
% 
% 
% % --- Executes on button press in pushbutton14.
% function pushbutton14_Callback(hObject, eventdata, handles)
% % hObject    handle to pushbutton14 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% handles.prescanPath = uigetdir(pwd, 'Select folder for Prescan (DICOM) data (INPUT)');
% guidata(hObject,handles)


% % --- Executes on button press in checkbox4.
% function checkbox4_Callback(hObject, eventdata, handles)
% % hObject    handle to checkbox4 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% handles.smoothing = get(handles.checkbox4,'Value');
% guidata(hObject,handles);
% set(handles.text2,'Visible','on');
% set(handles.edit8,'Visible','on');
% set(handles.text5,'Visible','on');
% 
% % Hint: get(hObject,'Value') returns toggle state of checkbox4



% function edit12_Callback(hObject, eventdata, handles)
% % hObject    handle to edit12 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% numberOfEchoes = str2double(get(hObject, 'String'));
% if isnan(numberOfEchoes)
%     set(hObject, 'String', 5);
%     errordlg('No input for # of echoes, default value of 5 will be used','Error');
% end
% 
% handles.numberOfEchoes = numberOfEchoes;
% guidata(hObject,handles)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double

% 
% % --- Executes during object creation, after setting all properties.
% function edit12_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to edit12 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: edit controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end


% % --- Executes when uipanel1 is resized.
% function uipanel1_ResizeFcn(hObject, eventdata, handles)
% % hObject    handle to uipanel1 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
