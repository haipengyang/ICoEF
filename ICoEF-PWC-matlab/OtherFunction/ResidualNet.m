function [degree_index, temp_matrix] = ResidualNet(solution, Adj_matrix, degree_flag)
%RESIDUALNET 局部搜索中用于计算剩余网络，同时计算剩余网络中每个节点的度
temp_matrix = Adj_matrix;
node_index = find(solution == 1);
temp_matrix(node_index, :) = 0;
temp_matrix(:, node_index) = 0;
sum_degree = sum(temp_matrix);
degree_index = find(sum_degree <= degree_flag);
end

