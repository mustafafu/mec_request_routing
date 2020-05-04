%% Canvas
canvas_size = [600,600];


%% Node Generation
num_nodes = 9;

nodes = zeros(num_nodes,1);
seperation = canvas_size(1)/sqrt(num_nodes);
x_vals = seperation/2 + seperation * (0:sqrt(num_nodes)-1);
y_vals = seperation/2 + seperation * (0:sqrt(num_nodes)-1);
[node_x, node_y] = meshgrid(x_vals,y_vals);
node_x = node_x(:);
node_y = node_y(:);

node_memory = 1e9 * ( 250 + 1e3 * rand( size(nodes) ) ); %[250,1250] Gbps
node_capacity = 1e9 * ( 1 + 9 * rand( size(nodes) ) ); %[1,10] GHz
node_connectivity = randi([30,100],size(nodes));

%% Edges
% num_edges = 20;

% link_origins = randi([1,num_nodes],[num_edges,1]);
% link_terminates = randi([1,num_nodes],[num_edges,1]);
% for ii=1:num_edges
%     while link_origins(ii) == link_terminates(ii)
%         link_terminates(ii) = randi([1,num_nodes]);
%     end
% end
% for now
link_origins =    [1,4,7,8,4,1,8,5,2,3,6,1,5,3,7,5,8,5];   
link_terminates = [4,7,8,9,5,2,5,2,3,6,9,5,9,2,3,6,7,4];
num_edges = length(link_origins);


link_delay = 4 + 6 * rand(num_edges,1); % 4 to 10 ms
link_capacity = 1e6 * (125 + 125 * rand(num_edges,1)); %125-250 Mbps

A = zeros(num_edges,num_nodes);
B = zeros(num_edges,num_nodes);
for ee=1:num_edges
    A(ee,link_origins(ee)) = 1;
    B(ee,link_terminates(ee)) = 1;
end

%% Plot the Edges
figure()
G = digraph(link_origins,link_terminates);
plot(G,'XData',node_x,'YData',node_y)
hold on;

%% Services
num_service = 100;
service_memory = 1e9 * ( 20 + 80 * rand( num_service,1 ) ); % 20-100 GBs
service_computation = 1e9 * ( 0.1 + 0.4 * rand( num_service,1 ) ); %0.1 to 0.5 GHz
service_traffic = 1e6 * ( 1 + 4 * rand( num_service,1 ) ); % 1- 5 Mbps
service_value = rand(num_service,1);
service_tolerance_delay = 20 + 80 * rand(num_service,1); % for now, need to adjust. 20-100 ms

service_memory = service_memory * 5;
service_computation = service_computation * 5;
service_traffic = service_traffic * 5;

%% User Generation
R = seperation;
num_users = 500;
% rU = R*sqrt(rand(num_users,1));%2*R/3 * ones(nT,1); %location of APs (distance from origin)
% alphaU = 2*pi*rand(num_users,1);
% user_x = rU .* cos(alphaU) + 250;
% user_y = rU .* sin(alphaU) + 250;
user_x = canvas_size(1) * rand([num_users,1]);
user_y = canvas_size(2) * rand([num_users,1]);
user_service = randi([1,num_service],[num_users,1]);


%% User Access Node computation
coverage = 150 ; % rectangle coverage for simplicity, a node on (x,y) can cover (x-150,y-150) to (x+150, y+150)
user_node_link = zeros(num_users,num_nodes);
for idx_node = 1:num_nodes
    x_0 = node_x(idx_node);
    y_0 = node_y(idx_node);
    users_covered = (x_0 - coverage) < user_x & user_x < (x_0 + coverage)...
                 & (y_0 - coverage) < user_y & user_y < (y_0 + coverage);
    user_node_link(:,idx_node) = users_covered;
    
end
user_node_link = logical(user_node_link);






%% Plotting
% figure()
scatter(node_x,node_y,'^r','filled')
hold on;
scatter(user_x,user_y,ones(num_users,1),'bo')
% for plotting a bs coverage.
% which_bs = 4;
% scatter(user_x(user_node_link(:,which_bs)),user_y(user_node_link(:,which_bs)),ones(sum(user_node_link(:,which_bs)),1),'go')
xlim([0,canvas_size(1)])
ylim([0,canvas_size(2)])



%% Writing the data to a file
fileID = fopen('service.dat','w');
formatSpec = 'param %s := %d;\n';
fprintf(fileID,formatSpec,'p',num_users);
fprintf(fileID,formatSpec,'n',num_nodes);
fprintf(fileID,formatSpec,'e',num_edges);
fprintf(fileID,formatSpec,'s',num_service);
fprintf(fileID,'\n');



write_matrix_integer(fileID,'A',A)
fprintf(fileID,'\n\n');

write_matrix_integer(fileID,'B',B)
fprintf(fileID,'\n\n');

write_array_float(fileID,'C',link_capacity)
fprintf(fileID,'\n\n'); 

write_array_float(fileID,'L',link_delay)
fprintf(fileID,'\n\n'); 




write_array_float(fileID,'S_M',service_memory)
fprintf(fileID,'\n\n'); 

write_array_float(fileID,'S_C',service_computation)
fprintf(fileID,'\n\n'); 

write_array_float(fileID,'S_T',service_tolerance_delay)
fprintf(fileID,'\n\n'); 

write_array_float(fileID,'S_H',service_traffic)
fprintf(fileID,'\n\n'); 

write_array_float(fileID,'S_W',service_value)
fprintf(fileID,'\n\n'); 



write_array_float(fileID,'N_M',node_memory)
fprintf(fileID,'\n\n'); 

write_array_float(fileID,'N_C',node_capacity)
fprintf(fileID,'\n\n'); 

write_array_integer(fileID,'N_K',node_connectivity)
fprintf(fileID,'\n\n');



write_matrix_integer(fileID,'U_N',user_node_link)
fprintf(fileID,'\n\n');

write_array_integer(fileID,'U_S',user_service)
fprintf(fileID,'\n\n');

fprintf(fileID,'\n\n'); 


