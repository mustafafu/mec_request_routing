%% Reading the data and cleaning rows which has <BREAK>, Infeasible etc.
opts = delimitedTextImportOptions("NumVariables", 4);

% Specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["method", "iteration_index", "duration", "solution"];
opts.VariableTypes = ["string", "double", "double", "double"];
opts = setvaropts(opts, 1, "EmptyFieldRule", "auto");
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Setup rules for import
opts.ImportErrorRule = "omitrow";
opts.MissingRule = "omitrow";

% Import the data
cleaned_data = readtable("/home/mustafafu/Dropbox/Git/mec_request_routing/common_script/solutions.txt", opts);


clear opts


%%
cleaned_data = sortrows(cleaned_data,'iteration_index','ascend');

iterations = cleaned_data(:,{'iteration_index','duration','solution'}).Variables;
methods = cleaned_data(:,{'method'}).Variables;

%%
num_iterations = 1000;
num_method=4;
cell_per_method = 3;
results = zeros(num_iterations,num_method*cell_per_method);
for ii=1:size(iterations,1)
    switch methods(ii)
        case "LP"
            results(iterations(ii,1),1:3) = iterations(ii,:);
        case "MIP"
            results(iterations(ii,1),4:6) = iterations(ii,:);
        case "GD2"
            results(iterations(ii,1),7:9) = iterations(ii,:);
        case "GD1"
            results(iterations(ii,1),10:12) = iterations(ii,:);
    end
    
end

load('solutions_greedy.mat')
results(:,10:12)=combined_output;

mask = (results(:,1)==0) | (results(:,4)==0) | (results(:,7)==0) | (results(:,10)==0);
results(mask,:) = [];
mask = results(:,3)< results(:,6);
results(mask,:)=[];


[~,I] = sort(results(:,3),'ascend');
results = results(I,:);



figure()
plot(1:size(results,1),results(:,3),'rx','DisplayName',['LP']);
hold on;
plot(1:size(results,1),results(:,6),'g+','DisplayName',['MIP']);
plot(1:size(results,1),results(:,9),'bo','DisplayName',['GD2']);
plot(1:size(results,1),results(:,12),'k*','DisplayName',['GD1']);
legend()
grid on;
xlabel('Scenario Index')
ylabel('Objective Value')

figure()
semilogy(1:size(results,1),results(:,2),'rx','DisplayName',['LP']);
hold on;
semilogy(1:size(results,1),results(:,5),'g+','DisplayName',['MIP']);
semilogy(1:size(results,1),results(:,8),'bo','DisplayName',['GD2']);
semilogy(1:size(results,1),results(:,11),'k*','DisplayName',['GD1']);
legend()
grid on;
xlabel('Scenario Index')
ylabel('Solution Duration (ms)')




%% smoothed figures

order = 3;
framelen = 11;

figure()
plot(1:size(results,1),results(:,3),'rx','DisplayName',['LP']);
hold on;
sgf = sgolayfilt(results(:,6),order,framelen);
plot(1:size(results,1),sgf,'g+','DisplayName',['MIP']);
sgf = sgolayfilt(results(:,9),order,framelen);
plot(1:size(results,1),sgf,'bo','DisplayName',['GD2']);
sgf = sgolayfilt(results(:,12),order,framelen);
plot(1:size(results,1),sgf,'k*','DisplayName',['GD1']);
legend()
grid on;
xlabel('Scenario Index')
ylabel('Objective Value')

figure()
sgf = sgolayfilt(results(:,2),order,framelen);
semilogy(1:size(results,1),sgf,'rx','DisplayName',['LP']);
hold on;
sgf = sgolayfilt(results(:,5),order,framelen);
semilogy(1:size(results,1),sgf,'g+','DisplayName',['MIP']);
sgf = sgolayfilt(results(:,8),order,framelen);
semilogy(1:size(results,1),sgf,'bo','DisplayName',['GD2']);
sgf = sgolayfilt(results(:,11),order,framelen);
semilogy(1:size(results,1),sgf,'k*','DisplayName',['GD1']);
legend()
grid on;
xlabel('Scenario Index')
ylabel('Solution Duration (ms)')