function [degree_index, temp_matrix] = ResidualNet(solution, Adj_matrix, degree_flag)
%RESIDUALNET �ֲ����������ڼ���ʣ�����磬ͬʱ����ʣ��������ÿ���ڵ�Ķ�
temp_matrix = Adj_matrix;
node_index = find(solution == 1);
temp_matrix(node_index, :) = 0;
temp_matrix(:, node_index) = 0;
sum_degree = sum(temp_matrix);
degree_index = find(sum_degree <= degree_flag);
end

