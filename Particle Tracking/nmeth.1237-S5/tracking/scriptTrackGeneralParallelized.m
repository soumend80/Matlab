%% Detection results: movieInfo
%
%For a movie with N frames, movieInfo is a structure array with N entries.
%Every entry has the fields xCoord, yCoord, zCoord (if 3D) and amp.
%If there are M features in frame i, each one of these fields in
%moveiInfo(i) will be an Mx2 array, where the first column is the value
%(e.g. x-coordinate in xCoord and amplitude in amp) and the second column
%is the standard deviation. If the uncertainty is unknown, make the second
%column all zero.

%movieInfo    : Array of size equal to the number of frames in a
%                      movie, containing the fields:
%             .xCoord      : x-coordinates of detected features. 
%                            1st column: value, 2nd column: standard
%                            deviation (zeros if not available).
%             .yCoord      : y-coordinates of detected features.
%                            1st column: value, 2nd column: standard
%                            deviation (zeros if not available).
%             .zCoord      : z-coordinates of detected features.
%                            1st column: value, 2nd column: standard
%                            deviation (zeros if not available).
%                            Optional. Skipped if problem is 2D. Default: zeros.
%             .amp         : "Intensities" of detected features.
%                            1st column: values (ones if not available),
%                            2nd column: standard deviation (zeros if not
%                            available).
%
%This is the automatic output of detectSubResFeatures2D_StandAlone, which
%is called via the accompanying "scriptDetectGeneral"
%This file is part of u-track.
%
%    u-track is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%    u-track is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with u-track.  If not, see <http://www.gnu.org/licenses/>.
%
%Copyright Jaqaman 01/08
%--------------------------------------------------------------------------
clearvars
load('F:\Soumen\Orbital Shaker\Raw Data\40 balls\1.5 v run 1 10.07.2019 exp 1821\Results\stats_1.5v.mat');
Nimage = length(stats);
movieInfo=repmat(struct('xCoord',[],'yCoord',[],'amp',[]),Nimage,1);
for i=1:Nimage
    movieInfo(i).xCoord=[stats{i}(:,1) zeros(length(stats{i}),1)];
    movieInfo(i).yCoord=[stats{i}(:,2) zeros(length(stats{i}),1)];
    movieInfo(i).amp=[1*ones(length(stats{i}),1) zeros(length(stats{i}),1)];
end
movieInfo(60001:end)=[];

clearvars -except movieInfo

tstart1=tic;
%% Cost functions

%Frame-to-frame linking
costMatrices(1).funcName = 'costMatLinearMotionLink';

%Gap closing, merging and splitting
costMatrices(2).funcName = 'costMatLinearMotionCloseGaps';

%--------------------------------------------------------------------------

%% Kalman filter functions

% kalmanFunctions=[];

%Memory reservation
kalmanFunctions.reserveMem = 'kalmanResMemLM';

%Filter initialization
kalmanFunctions.initialize = 'kalmanInitLinearMotion';

%Gain calculation based on linking history
kalmanFunctions.calcGain = 'kalmanGainLinearMotion';

%--------------------------------------------------------------------------

%% General tracking parameters

%Gap closing time window
gapCloseParam.timeWindow = 2;

%Flag for merging and splitting  
%value 1 if the merging and splitting of trajectories are to be consided; 
%and 0 if merging and splitting are not allowed.                                                     
gapCloseParam.mergeSplit = 0;

%Minimum track segment length (frames) used in the gap closing, merging and
%splitting step
gapCloseParam.minTrackLen = 2;

%--------------------------------------------------------------------------

%% Cost function specific parameters: Frame-to-frame linking

%Flag for linear motion
parameters.linearMotion = 1;

%Search radius lower limit
parameters.minSearchRadius = 6;

%Search radius upper limit
parameters.maxSearchRadius = 13;

%Standard deviation multiplication factor
parameters.brownStdMult = 1;

%Flag for using local density in search radius estimation
parameters.useLocalDensity = 1;

%Number of past frames used in nearest neighbor calculation
parameters.nnWindow = gapCloseParam.timeWindow;

%Store parameters for function call
costMatrices(1).parameters = parameters;
clear parameters

%--------------------------------------------------------------------------

%% Cost function specific parameters: Gap closing, merging and splitting

%Same parameters as for the frame-to-frame linking cost function
parameters.linearMotion = costMatrices(1).parameters.linearMotion;
parameters.useLocalDensity = costMatrices(1).parameters.useLocalDensity;
parameters.maxSearchRadius = costMatrices(1).parameters.maxSearchRadius;
parameters.minSearchRadius = costMatrices(1).parameters.minSearchRadius;
parameters.brownStdMult = costMatrices(1).parameters.brownStdMult*ones(gapCloseParam.timeWindow,1);
parameters.nnWindow = costMatrices(1).parameters.nnWindow;

%Gap length (frames) at which f(gap) (in search radius definition) reaches its
%plateau
parameters.timeReachConfB = 2;

%Amplitude ratio lower and upper limits
parameters.ampRatioLimit = [0.5 4];

%Minimum length (frames) for track segment analysis
parameters.lenForClassify = 5;

%Standard deviation multiplication factor along preferred direction of
%motion
parameters.linStdMult = 3*ones(gapCloseParam.timeWindow,1);

%Gap length (frames) at which f'(gap) (in definition of search radius
%parallel to preferred direction of motion) reaches its plateau
parameters.timeReachConfL = gapCloseParam.timeWindow;

%Maximum angle between the directions of motion of two linear track
%segments that are allowed to get linked
parameters.maxAngleVV = 45;

%Store parameters for function call
costMatrices(2).parameters = parameters;
clear parameters

%--------------------------------------------------------------------------

%% additional input
n_frame = 1000;      %% no. of frame to analyze in each parallel loop
mkdir('F:\Soumen\Orbital Shaker\Raw Data\40 balls\1.5 v run 1 10.07.2019 exp 1821\Results\TrackingResult')

for l=1:length(movieInfo)/n_frame
%saveResults
saveResults(l).dir = 'F:\Soumen\Orbital Shaker\Raw Data\40 balls\1.5 v run 1 10.07.2019 exp 1821\Results\TrackingResult\'; %directory where to save input and output
saveResults(l).filename = strcat('testTracking',num2str(1+(l-1)*n_frame),'_',num2str(l*n_frame),'.mat'); %name of file where input and output are saved
% saveResults = 0; %don't save results
end
%verbose
verbose = 0;

%problem dimension
probDim = 2;

%--------------------------------------------------------------------------

%% tracking function call

parfor i=1:length(movieInfo)/n_frame
    tstart2=tic;
    
    [tracksFinal,kalmanInfoLink,errFlag] = trackCloseGapsKalman(movieInfo(1+(i-1)*n_frame:i*n_frame),...
        costMatrices,gapCloseParam,kalmanFunctions,probDim,saveResults(i),verbose);
    i
    toc(tstart2)
end
%--------------------------------------------------------------------------
toc(tstart1)
%% Output variables

%The important output variable is tracksFinal, which contains the tracks

%It is a structure array where each element corresponds to a compound
%track. Each element contains the following fields:
%           .tracksFeatIndxCG: Connectivity matrix of features between
%                              frames, after gap closing. Number of rows
%                              = number of track segments in compound
%                              track. Number of columns = number of frames
%                              the compound track spans. Zeros indicate
%                              frames where track segments do not exist
%                              (either because those frames are before the
%                              segment starts or after it ends, or because
%                              of losing parts of a segment.
%           .tracksCoordAmpCG: The positions and amplitudes of the tracked
%                              features, after gap closing. Number of rows
%                              = number of track segments in compound
%                              track. Number of columns = 8 * number of
%                              frames the compound track spans. Each row
%                              consists of
%                              [x1 y1 z1 a1 dx1 dy1 dz1 da1 x2 y2 z2 a2 dx2 dy2 dz2 da2 ...]
%                              NaN indicates frames where track segments do
%                              not exist, like the zeros above.
%           .seqOfEvents     : Matrix with number of rows equal to number
%                              of events happening in a track and 4
%                              columns:
%                              1st: Frame where event happens;
%                              2nd: 1 - start of track, 2 - end of track;
%                              3rd: Index of track segment that ends or starts;
%                              4th: NaN - start is a birth and end is a death,
%                                   number - start is due to a split, end
%                                   is due to a merge, number is the index
%                                   of track segment for the merge/split.


