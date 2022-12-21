
%% learning/experimental specs
alpha = 0.70; % learn rate

gamma = 0.9; % discount factor

epsilon0=0.1; % exploration rate at t0
epsilonMin=0.01; % minimal exploration rate
epsDecayEpisodes = 10000; % episodes from eps0 -> epsMin
epsilon = epsilon0; % current exploration rate
lambda = log(epsilonMin/epsilon0)/-epsDecayEpisodes; % decay factor of epsilon

MaxEpisodes = 20000;


% simulation options / constants over all episodes
SimOptions.tMax = 8*60; % minutes
SimOptions.ProcessingTime_Job1 = 1;
SimOptions.ProcessingTime_Job2 = 3;
SimOptions.RetoolingTime = 3;
SimOptions.SaleTime_Job1 = 10;
SimOptions.SaleTime_Job2 = 5;
SimOptions.MaxQueueLength = 30;
SimOptions.MaxDeltaQueue = 10;

% changing parameters 
EpisodeData.ExplorationProbability = epsilon;
EpisodeData.LearnRate = alpha;
EpisodeData.DiscountFactor = gamma; 
EpisodeData.Table = ones(2*31^2,2)*1000; % optimistic initial values (Reinforcement Learning: An Introduction, Ch. 2.6 -- Sutton & Barto)
EpisodeData.TotalReward = 0.0;
EpisodeData.LastEpisode = false;
EpisodeData.Seed = 1;


%% prepare Simulink Model
model = 'Prodline_EF_RL';
disp('loading model...');
load_system(model);
disp('done!');

% set simulation time span and turn FastRestart on 
set_param(model, 'FastRestart','off'); % has to be off in order to change start/stop time
set_param(model, "StartTime", '0');
set_param(model, "StopTime", 'Inf'); % simulation is stoped by the acceptor
set_param(model, 'FastRestart','on');

modelWorkspace = get_param(model, 'ModelWorkspace');
modelWorkspace.assignin('SimOptions',SimOptions);
modelWorkspace.assignin('EpisodeData',EpisodeData);

%% prepare statistics
totalRewardVec = zeros(1,MaxEpisodes);
tStart=tic;

%% run episodes
for n = 1:MaxEpisodes   
    % load the EpisodeData structure from matlab workspace into the model workspace
    modelWorkspace.assignin('EpisodeData',EpisodeData);
    
    % run episode and get results (EpisodeData.Table in matlab-workspace is updated from the agent!)  
    out = sim(model); 
    totalRewardVec(n) = out.TotalEpisodeReward.Data;

    % update the EpisodeData parameters
    epsilon = max(epsilonMin, epsilon*(1-lambda));
    EpisodeData.ExplorationProbability = epsilon;
    EpisodeData.Seed = EpisodeData.Seed + 1;
    EpisodeData.TotalReward = 0;

    % print some progress information 
    if mod(n,10)==0
        if n>=30
            avg = mean(totalRewardVec(n-30+1:n));
        else
            avg = mean(totalRewardVec(1:n));
        end
        fprintf("Epsiode #%4d\tmean Reward: %8.1f\t(%.3fs left)\n", n, ...
            avg, toc(tStart)/n * (MaxEpisodes-n));
    end
end
toc(tStart)

%% plot learning result
figure
plot(totalRewardVec); hold on
plot(movingAvg(totalRewardVec,30));
xlabel('Episodes');
ylabel('Reward');
legend(['per episode', 'moving average'],Location='northwest');
title(['learning Results of ' num2str(MaxEpisodes) ' episodes']);
hold off

function B = movingAvg(A, windowSize)

    offset = floor(windowSize/2);
    B = conv(A, ones(1,windowSize),'same');
    B = B/ windowSize;

    B(1:offset) = B(offset);
    B(end-offset:end) = B(end-offset);
    
end
    


