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
mip_data = readtable("/home/mustafafu/Dropbox/Git/mec_request_routing/common_script/Results/solutions_mip.txt", opts);
lp_data = readtable("/home/mustafafu/Dropbox/Git/mec_request_routing/common_script/Results/solutions_lp.txt", opts);
gdv2_data = readtable("/home/mustafafu/Dropbox/Git/mec_request_routing/common_script/Results/solutions_gd2_v2.txt", opts);

clear opts


%%
mip_data = sortrows(mip_data,'iteration_index','ascend');
lp_data = sortrows(lp_data,'iteration_index','ascend');
gdv2_data = sortrows(gdv2_data,'iteration_index','ascend');

mip_matrix = mip_data(:,{'iteration_index','duration','solution'}).Variables;
lp_matrix = lp_data(:,{'iteration_index','duration','solution'}).Variables;
gd2_matrix = gdv2_data(:,{'iteration_index','duration','solution'}).Variables;
load('./Results/reg_solutions_greedy.mat','combined_output')
gd1_matrix_regular = combined_output;
load('./Results/mem_solutions_greedy.mat','combined_output')
gd1_matrix_memory = combined_output;
load('./Results/comp_solutions_greedy.mat','combined_output')
gd1_matrix_computation = combined_output;

%%
valid_iterations = intersect(intersect(gd2_matrix(:,1),mip_matrix(:,1)),lp_matrix(:,1));
mip_matrix = mip_matrix(sum((mip_matrix(:,1)' == valid_iterations),1)'==1,:);
%some scenarios are run twice as some mip solutions were larger than lp. We
%wanted to see if the problem was with hpc and we run those in local
%computer. Still some of them are problematic, so it has to do something
%else than the hpc. We suspect cplex solver branch and bound method can
%converge to wrong minimums.
for i=size(mip_matrix,1):-1:2
    if mip_matrix(i,1) == mip_matrix(i-1,1)
        mip_matrix(i-1,:) = [];
    end
end
lp_matrix = lp_matrix(sum((lp_matrix(:,1)' == valid_iterations),1)'==1,:);
gd2_matrix = gd2_matrix(sum((gd2_matrix(:,1)' == valid_iterations),1)'==1,:);
gd1_matrix_regular = gd1_matrix_regular(sum((gd1_matrix_regular(:,1)' == valid_iterations),1)'==1,:);
gd1_matrix_computation = gd1_matrix_computation(sum((gd1_matrix_computation(:,1)' == valid_iterations),1)'==1,:);
gd1_matrix_memory = gd1_matrix_memory(sum((gd1_matrix_memory(:,1)' == valid_iterations),1)'==1,:);

results = [lp_matrix,mip_matrix,gd2_matrix,gd1_matrix_regular,gd1_matrix_memory,gd1_matrix_computation];

%sometimes mip give larger results than lp, we want to remove those
%scenarios as it is not theoretically possible. This might has something to
%do with the cplex solver, branch and bound converging to some wrong place
%or memory error etc. needs testing.
mask = (lp_matrix(:,3) > mip_matrix(:,3)) & (lp_matrix(:,3) > gd2_matrix(:,3));

results = results(mask,:);

[~,I] = sort(results(:,3),'ascend');
results = results(I,:);

%%

% figure()
% plot(1:size(results,1),results(:,3),'rx','DisplayName',['LP']);
% hold on;
% plot(1:size(results,1),results(:,6),'g+','DisplayName',['MIP']);
% plot(1:size(results,1),results(:,9),'bo','DisplayName',['H1']);
% plot(1:size(results,1),results(:,12),'k*','DisplayName',['H2']);
% legend()
% grid on;
% xlabel('Scenario Index')
% ylabel('Objective Value')
% 
% figure()
% semilogy(1:size(results,1),results(:,2),'rx','DisplayName',['LP']);
% hold on;
% semilogy(1:size(results,1),results(:,5),'g+','DisplayName',['MIP']);
% semilogy(1:size(results,1),results(:,8),'bo','DisplayName',['H1']);
% semilogy(1:size(results,1),results(:,11),'k*','DisplayName',['H2']);
% legend()
% grid on;
% xlabel('Scenario Index')
% ylabel('Solution Duration (ms)')
% 



%% smoothed figures

order = 3;
framelen = 21;

marker_size = 4;

h=figure()
plot(1:size(results,1),results(:,3),'rx','MarkerSize',marker_size,'DisplayName',['LP']);
hold on;
sgf = sgolayfilt(results(:,6),order,framelen);
plot(1:size(results,1),sgf,'g+','MarkerSize',marker_size,'DisplayName',['MIP']);
sgf = sgolayfilt(results(:,9),order,framelen);
plot(1:size(results,1),sgf,'bo','MarkerSize',marker_size,'DisplayName',['H2']);
sgf = sgolayfilt(results(:,12),order,framelen);
plot(1:size(results,1),sgf,'k^','MarkerSize',marker_size,'DisplayName',['H1\_reg']);
sgf = sgolayfilt(results(:,15),order,framelen);
plot(1:size(results,1),sgf,'m>','MarkerSize',marker_size,'DisplayName',['H1\_mem']);
sgf = sgolayfilt(results(:,18),order,framelen);
plot(1:size(results,1),sgf,'cv','MarkerSize',marker_size,'DisplayName',['H1\_comp']);
legend()
grid on;
xlabel('Scenario Index')
ylabel('Objective Value')



save_fig_string = strrep('obj','.',',');

save_fig_string_1 = ['./Figures/',save_fig_string, '.jpeg'];
saveas(h,save_fig_string_1);
save_fig_string_1 = ['./Figures/',save_fig_string, '.eps'];
saveas(h,save_fig_string_1,'epsc');
save_fig_string_1 = ['./Figures/',save_fig_string, '.fig'];
saveas(h,save_fig_string_1);

h=figure()
sgf = sgolayfilt(results(:,2),order,framelen);
semilogy(1:size(results,1),sgf,'rx','MarkerSize',marker_size,'DisplayName',['LP']);
hold on;
sgf = sgolayfilt(results(:,5),order,framelen);
semilogy(1:size(results,1),sgf,'g+','MarkerSize',marker_size,'DisplayName',['MIP']);
sgf = sgolayfilt(results(:,8),order,framelen);
semilogy(1:size(results,1),sgf,'bo','MarkerSize',marker_size,'DisplayName',['H2']);
sgf = sgolayfilt(results(:,11),order,framelen);
semilogy(1:size(results,1),sgf,'k^','MarkerSize',marker_size,'DisplayName',['H1\_reg']);
sgf = sgolayfilt(results(:,14),order,framelen);
semilogy(1:size(results,1),sgf,'m>','MarkerSize',marker_size,'DisplayName',['H1\_mem']);
sgf = sgolayfilt(results(:,17),order,framelen);
semilogy(1:size(results,1),sgf,'cv','MarkerSize',marker_size,'DisplayName',['H1\_comp']);
legend()
grid on;
xlabel('Scenario Index')
ylabel('Solution Duration (ms)')

save_fig_string = strrep('time','.',',');

save_fig_string_1 = ['./Figures/',save_fig_string, '.jpeg'];
saveas(h,save_fig_string_1);
save_fig_string_1 = ['./Figures/',save_fig_string, '.eps'];
saveas(h,save_fig_string_1,'epsc');
save_fig_string_1 = ['./Figures/',save_fig_string, '.fig'];
saveas(h,save_fig_string_1);