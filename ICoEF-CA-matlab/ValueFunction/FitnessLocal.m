function fitness = FitnessLocal(population, Adj, change_list, divide_n, divide_changde_sum, Y, C, F)
%FUNCTIONVALUE 计算个体适应度
temp = population ==1;
temp_change = change_list(temp);
temp_change_sum = sum(temp_change);
[node, ~, ~] = CascadeModel3(population, Y, C, F, Adj);
fitness = -((length(node) / divide_n) + temp_change_sum / divide_changde_sum);
% fitness = -length(node);
end

