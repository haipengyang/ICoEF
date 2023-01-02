function [node, load, capacity, degree_index, temp_matrix] = ResidualNet(solution,  Y, C, F, Adj,degree_flag)
%RESIDUALNET 局部搜索中用于计算剩余网络，同时计算剩余网络中每个节点的度
[node, load, capacity] = CascadeModel3(solution, Y, C, F, Adj);
temp_matrix = Adj;
temp_matrix(node, :) = 0;
temp_matrix(:, node) = 0;
sum_degree = sum(temp_matrix);
degree_index = find(sum_degree <= degree_flag);
end

