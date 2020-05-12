if isempty(iteration_limit)
    iteration_limit = [1,2]
end
for nAI=iteration_limit(1):iteration_limit(2)
    load_file_string = ['Data/service_',num2str(nAI)];
    load_file_string = strrep(load_file_string,'.',',')
    load(load_file_string);
    %% Get Parameters
    service_value = Parameters.service_value;
    service_traffic = Parameters.service_traffic;
    service_tolerance_delay = Parameters.service_tolerance_delay;
    service_memory = Parameters.service_memory;
    service_computation = Parameters.service_computation;
    init_node_memory = Parameters.node_memory;
    init_node_connectivity = Parameters.node_connectivity;
    init_node_capacity = Parameters.node_capacity;
    user_service = Parameters.user_service;
    user_node_link = Parameters.user_node_link;
    link_terminates = Parameters.link_terminates;
    link_origins = Parameters.link_origins;
    link_delay = Parameters.link_delay;
    init_link_cost = Parameters.link_cost;
    init_link_capacity = Parameters.link_capacity;
    G = Parameters.Graph;
    
    node_memory = init_node_memory;
    node_capacity = init_node_capacity;
    node_connectivity = init_node_connectivity;
    link_capacity = init_link_capacity;
    
    user_value = service_value(user_service);
    [user_value, users] = sort(user_value,'descend');
    %% output variables
    server_indicator = zeros(Parameters.num_users,Parameters.num_nodes);
    access_indicator = zeros(Parameters.num_users,Parameters.num_nodes);
    link_indicator = zeros(Parameters.num_users,Parameters.num_edges);
    isUser_served = zeros(Parameters.num_users,1);
    objective = 0;
    %% greedy method trying to serve users with highest value
    for idx = 1:length(users)
        best_user = users(idx);
        % Greeedy without routing
        tgt_nodes_w_resource = user_node_link(best_user,:) &...
            (node_memory > service_memory(user_service(best_user))).' &...
            (node_capacity > service_computation(user_service(best_user))).';
        tgt_nodes = find(tgt_nodes_w_resource);
        if ~isempty(tgt_nodes)
            %serve at source nodes, select a random node
            target = tgt_nodes(randi(length(tgt_nodes)));
            node_memory(target) = node_memory(target) - service_memory(user_service(best_user));
            node_capacity(target) = node_capacity(target) - service_computation(user_service(best_user));
            server_indicator(best_user,target) = 1;
            access_indicator(best_user,target) = 1;
            isUser_served(best_user) = 1;
            objective = objective + service_value(user_service(best_user));
        else
            %% route somewhere
            % Greedy with routing, need to find a place.x
            nodes_w_resource = (node_memory > service_memory(user_service(best_user))) & (node_capacity > service_computation(user_service(best_user)));
            candidate_nodes = find(nodes_w_resource);
            source_nodes =  find(user_node_link(best_user,:));
            if ~isempty(intersect(candidate_nodes,source_nodes))
                disp('source nodes still have capacity stg is wrong')
            end
            P = cell(length(source_nodes),length(candidate_nodes));
            %path finding
            for ii=1:length(source_nodes)
                for jj=1:length(candidate_nodes)
                    s = source_nodes(ii);
                    t = candidate_nodes(jj);
                    P{ii,jj} = shortestpath(G,s,t);
                end
            end
            %routing decision
            for ii=1:length(source_nodes)
                % if in order to use only one path
                if isUser_served(best_user) == 1
                    break
                end
                for jj=1:length(candidate_nodes)
                    %if is only to use one path
                    if isUser_served(best_user) == 1
                        break
                    end
                    if ~isempty(P{ii,jj})
                        this_path = P{ii,jj};
                        hops = length(this_path)-1;
                        is_edge_avail = zeros(hops,1);
                        edge = zeros(hops,1);
                        total_delay = 0;
                        for hh=1:hops
                            edges_o = find(link_origins == this_path(hops));
                            edges_t = find(link_terminates == this_path(hops+1));
                            edge(hh) = intersect(edges_o,edges_t);
                            if link_capacity(edge(hh)) > service_traffic(user_service(best_user))
                                is_edge_avail(hh)=1;
                                total_delay = total_delay + link_delay(edge(hh));
                            end
                        end
                        if sum(is_edge_avail) == hops && total_delay < service_tolerance_delay(user_service(best_user))
                            s = source_nodes(ii);
                            t = candidate_nodes(jj);
                            %% output variables
                            server_indicator(best_user,t) = 1;
                            access_indicator(best_user,s) = 1;
                            isUser_served(best_user) = 1;
                            objective = objective + service_value(user_service(best_user));
                            node_memory(t) = node_memory(t) - service_memory(user_service(best_user));
                            node_capacity(t) = node_capacity(t) - service_computation(user_service(best_user));
                            for hh=1:hops
                                link_capacity(edge(hh)) = link_capacity(edge(hh)) - service_traffic(user_service(best_user));
                                link_indicator(best_user,edge(hh))=1;
                            end
                        end
                    end
                end
            end
        end
    end
    [node_memory,node_capacity];
    save_file_string = ['Output/greedy_',num2str(nAI)];
    save_file_string = strrep(save_file_string,'.',',')
    save(save_file_string,'objective','server_indicator','access_indicator','link_indicator');
    
    
end