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
mip_data = readtable("/home/mustafafu/Dropbox/Git/mec_request_routing/common_script/solutions_mip.txt", opts);
lp_data = readtable("/home/mustafafu/Dropbox/Git/mec_request_routing/common_script/solutions_lp.txt", opts);
gdv2_data = readtable("/home/mustafafu/Dropbox/Git/mec_request_routing/common_script/solutions_gd2_v2.txt", opts);

clear opts


%%
mip_data = sortrows(mip_data,'iteration_index','ascend');
lp_data = sortrows(lp_data,'iteration_index','ascend');
gdv2_data = sortrows(gdv2_data,'iteration_index','ascend');

mip_matrix = mip_data(:,{'iteration_index','duration','solution'}).Variables;
lp_matrix = lp_data(:,{'iteration_index','duration','solution'}).Variables;
gd2_matrix = gdv2_data(:,{'iteration_index','duration','solution'}).Variables;
load('solutions_greedy.mat','combined_output')
gd1_matrix = combined_output;

%%
valid_iterations = intersect(intersect(gd2_matrix(:,1),mip_matrix(:,1)),lp_matrix(:,1));
mip_matrix = mip_matrix(sum((mip_matrix(:,1)' == valid_iterations),1)'==1,:);
lp_matrix = lp_matrix(sum((lp_matrix(:,1)' == valid_iterations),1)'==1,:);
gd2_matrix = gd2_matrix(sum((gd2_matrix(:,1)' == valid_iterations),1)'==1,:);
gd1_matrix = gd1_matrix(sum((gd1_matrix(:,1)' == valid_iterations),1)'==1,:);

results = [lp_matrix,mip_matrix,gd1_matrix,gd2_matrix];

mask = (lp_matrix(:,3) > mip_matrix(:,3)) & (lp_matrix(:,3) > gd2_matrix(:,3));

results = results(mask,:);

[~,I] = sort(results(:,3),'ascend');
results = results(I,:);

%%

figure()
plot(1:size(results,1),results(:,3),'rx','DisplayName',['LP']);
hold on;
plot(1:size(results,1),results(:,6),'g+','DisplayName',['MIP']);
plot(1:size(results,1),results(:,9),'bo','DisplayName',['H1']);
plot(1:size(results,1),results(:,12),'k*','DisplayName',['H2']);
legend()
grid on;
xlabel('Scenario Index')
ylabel('Objective Value')

figure()
semilogy(1:size(results,1),results(:,2),'rx','DisplayName',['LP']);
hold on;
semilogy(1:size(results,1),results(:,5),'g+','DisplayName',['MIP']);
semilogy(1:size(results,1),results(:,8),'bo','DisplayName',['H1']);
semilogy(1:size(results,1),results(:,11),'k*','DisplayName',['H2']);
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
plot(1:size(results,1),sgf,'bo','DisplayName',['H1']);
sgf = sgolayfilt(results(:,12),order,framelen);
plot(1:size(results,1),sgf,'k*','DisplayName',['H2']);
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
semilogy(1:size(results,1),sgf,'bo','DisplayName',['H1']);
sgf = sgolayfilt(results(:,11),order,framelen);
semilogy(1:size(results,1),sgf,'k*','DisplayName',['H2']);
legend()
grid on;
xlabel('Scenario Index')
ylabel('Solution Duration (ms)')