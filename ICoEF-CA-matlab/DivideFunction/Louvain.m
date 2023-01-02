% 返回[社团标签编码, 划分个数]
function [com, divide_Num] = Louvain(Adj, NC)
%LOUVAIN Louvain函数，改良版
%   第一阶段普通是Louvain划分，第二阶段若划分个数超过NC，则开始合并迷你社团，最终返回标签编码
%% 第一阶段普通是Louvain划分

% Number of edges m and its double m2
m2 = sum(sum(Adj));
m = m2/2;

% Degree vector
d = sum(Adj,2);

% Neighbours list for each node
for i=1:length(Adj)
    Nbs{i} = find(Adj(i,:));
    Nbs{i}(Nbs{i}==i) = [];
end

% Total weight of each community
wcom = d;


% Community of each node
com = 1:length(Adj);

% Initial Q value
Q = compute_Q(Adj, com, m2, d);

% While changes can be made
check_nodes = true;
check_communities = true;
while check_nodes
    %        disp('MO big loop');
    
    % Nodes moving
    moved = true;
    while moved
        %fprintf('Node loop\n');
        moved = false;
        
        % Create list of nodes to inspect
        l = 1:length(Adj);
        
        % While the list of candidates is not finished
        while ~isempty(l)
            
            % Pick at random a node n from l and remove it from l
            idx = randi(length(l));
            n = l(idx);
            l(idx) = [];
            
            % Find neighbour communities of n
            ncom = unique(com(Nbs{n}));
            ncom(ncom == com(n)) = [];
            % For each neighbour community of n
            best_dQ = 0;
            
            nb = Nbs{n};
            nb1 = nb(com(nb) == com(n));
            sum_nb1 = -sum(Adj(n,nb1));
            w1 = wcom(com(n)) - d(n);
            
            for i=1:length(ncom)
                % Compute dQ for moving n to current community
                
                c = ncom(i);
                nb2 = nb(com(nb) == c);
                dQ = sum_nb1+sum(Adj(n,nb2));
                dQ = (dQ + (d(n)*(w1-wcom(c)))/m2)/m;
                
                % If positive, keep track of the best
                if dQ > best_dQ
                    best_dQ = dQ;
                    new_c = ncom(i);
                end
            end
            
            % If a move is worth it, do it
            if best_dQ > 0
                
                % Update total weight of communities
                wcom(com(n)) = wcom(com(n)) - d(n);
                wcom(new_c) = wcom(new_c) + d(n);
                
                % Update community of n
                com(n) = new_c;
                % Update Q
                Q = Q + best_dQ;
                % Debug code: check Q computed by adding dQs is accuarate
                %                     eqQ = compute_Q(adj, com, m2, d);
                %                     if abs(Q - eqQ) >= 0.00001
                %                         fprintf('Warning: found Q=%f, should be Q=%f. Diff = %f\n',Q, eqQ, abs(Q-eqQ));
                %                     end
                % A move occured
                moved = true;
                check_communities = true;
            end
            
        end
        
    end % Nodes
    check_nodes = false;
    
    if ~check_communities
        break;
    end
    
    % Community merging
    moved = true;
    while moved
        %fprintf('Community loop\n');
        moved = false;
        
        % Create community list cl
        cl = unique(com);
        
        % While the list of candidates is not finished
        while ~isempty(cl)
            
            % Pick at random a community cn from cl and remove it from cl
            idx = randi(length(cl));
            cn = cl(idx);
            cl(idx) = [];
            
            % Find neighbour communities of cn
            ncn = find(com==cn);
            nbn = unique([Nbs{ncn}]);%sum(adj(idx,:) ~= 0,1) ~= 0;
            ncom = unique(com(nbn));
            ncom(ncom == cn) = [];
            
            % For each neighbour community of cn
            best_dQ = 0;
            
            sum_dn1 = sum(d(ncn));
            
            for ncom_idx=1:length(ncom)
                % Compute dQ for merging cn with current community
                %dQ = com_dQ(adj,com,cn,ncom(ncom_idx),m2,d);
                
                n2 = com==ncom(ncom_idx);
                dQ = (sum(sum(Adj(ncn,n2))) - sum_dn1*sum(d(n2))/m2)/m;
                
                % If positive, keep track of the best
                if dQ > best_dQ
                    best_dQ = dQ;
                    new_cn = ncom(ncom_idx);
                end
            end
            
            % If a move is worth it, do it
            if best_dQ > 0
                
                % Update total weight of communities
                wcom(new_cn) = wcom(new_cn) + wcom(cn);
                wcom(cn) = 0;
                
                % Merge communities
                com(ncn) = new_cn;
                % Update Q
                Q = Q + best_dQ;
                % Debug code: check Q computed by adding dQs is accuarate
                %                     eqQ = compute_Q(adj, com, m2, d);
                %                     if abs(Q - eqQ) >= 0.00001
                %                         fprintf('Warning: found Q=%f, should be Q=%f. Diff = %f\n',Q, eqQ, abs(Q-eqQ));
                %                     end
                % A move occured
                moved = true;
                check_nodes = true;
            end
            
        end
        
    end % Communities
    check_communities = false;
    
end % while changes can be made

% Reindexing communities
ucom = unique(com);
for i=1:length(com)
    com(i) = find(ucom==com(i));
end
com = com';

%% 第二阶段合并迷你社团

num_com = length(ucom);  % 社团个数
list1 = cell(num_com, 1);  %  记录每个社团的节点编号
n = length(com);
for i = 1 : n
    list1{com(i)}(end + 1) = i;
end
list2 = cell(num_com, 3);  % [社团索引,社团节点数,最终社团索引]
for i = 1 : num_com
    list2{i, 1} = i;
    list2{i, 2} = length(list1{i});
    list2{i, 3} = i;
end
% 合并社团索引
while 1
    list2 = sortrows(list2, 2);
    temp_N = list2{1, 2} + list2{2, 2};
    temp_N_2 = 0;
    for j = 3 : size(list2, 1)
        temp_N_2 = temp_N_2 + list2{j, 2};
    end
    temp_N_2 = temp_N_2 / (size(list2, 1) - 2);
    if (size(list2, 1) <= NC) && (temp_N > temp_N_2) && (temp_N > list2{end, 2})
        break;
    end
    temp1 = list2{1, 2} + list2{2, 2};
    if list2{1, 3} < list2{2, 3}
        temp2 = list2{1, 3};
    else
        temp2 = list2{2, 3};
    end
    list2{2, 1} = [list2{2, 1}, list2{1, 1}];
    list2{2, 2} = temp1;
    list2{2, 3} = temp2;
    list2(1, :) = [];
end
[a, ~] = size(list2);
% 重新编码
index_change = zeros(1, num_com);  % 原先社团合并后的最终社团索引
for i = 1 : a
    list2{i, 3} = i;
    for j = 1 : length(list2{i, 1})
        index_change(list2{i, 1}(j)) = i;
    end
end
for i = 1 : n
    com(i) = index_change(com(i));
end
num_com = a;
divide_Num = num_com;
end



