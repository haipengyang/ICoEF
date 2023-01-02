function fitness = FitnessLocal(population, Adj, change_list, divide_n, divide_changde_sum)
%FUNCTIONVALUE 计算个体适应度
temp_Adj = Adj;
temp = population ==1;
temp_Adj(temp, :) = 0;
temp_Adj(:, temp) = 0;
temp_change = change_list(temp);
temp_change_sum = sum(temp_change);
Pair_wise_sum = divide_n * (divide_n - 1) / 2;
temp_change_cha = divide_changde_sum - temp_change_sum;
fitness = Pair_wise(temp_Adj) / Pair_wise_sum + temp_change_cha / divide_changde_sum;
% fitness = Pair_wise(temp_Adj);
end

