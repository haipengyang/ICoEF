function [node, load, capacity, degree_index, temp_matrix] = ResidualNet(solution,  Y, C, F, Adj,degree_flag)
%RESIDUALNET �ֲ����������ڼ���ʣ�����磬ͬʱ����ʣ��������ÿ���ڵ�Ķ�
[node, load, capacity] = CascadeModel3(solution, Y, C, F, Adj);
temp_matrix = Adj;
temp_matrix(node, :) = 0;
temp_matrix(:, node) = 0;
sum_degree = sum(temp_matrix);
degree_index = find(sum_degree <= degree_flag);
end

