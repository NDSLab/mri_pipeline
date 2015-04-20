% create CombineWrapper on test data and execute combining

clear all; clear classes; % need to delete any old instance, just in case class defintion changed..
clc
addpath('~/repos/spm12')


% Test data settings for combineWrapper 
runSeries = [7 11 15]; % series numbers of first echo of each run as indicated on the "Print List" paper
nEchoes = 4; % number of echoes per run - typically this is the same number; can be scalar or vector of same length as runSeries
dataDir = '~/repos/mri_pipeline/test_data/3014030.01_petvav_026_001/data_raw';
workingDir = '/data/test_CombineWrapper/test1';
outputDir = [dataDir '/../data_combined']; % this is the default - that's why it's not being passed to CombineWrapper(..) below
    
% create wrapper instance
wrapper = CombineWrapper(	'dataDir',dataDir,...
							'workingDir',workingDir,...
							'runSeries',runSeries,...
							'nEchoes', nEchoes);

combiner = wrapper.combiner;

% %Either call:
% % wrapper.DoMagic();


% % or step through individual steps 'manually'
% wrapper.AssertReadyToGo();
% wrapper.LoadAllDicoms();
% wrapper.CreateCombiner();
% % wrapper.RunCombining(); % this is  wrapper.combiner.DoMagic();
% % % again, use Magic call or
% % wrapper.combiner.DoMagic();
% % % step through individual steps
% wrapper.combiner.AssertReadyToGo();
% wrapper.combiner.ConvertDicoms();
% wrapper.combiner.SpikeDetection(); % not implemented yet
% wrapper.combiner.Realign();
% wrapper.combiner.SplitRealignmentParameters();
% wrapper.combiner.Reslice();
% wrapper.combiner.CalculateWeights();
% wrapper.combiner.ApplyWeights();
 % wrapper.combiner.CopyFilesToOutputDir();
% % finishing wrapper.DoMagic():
% wrapper.ArrangeCombinedFiles();

