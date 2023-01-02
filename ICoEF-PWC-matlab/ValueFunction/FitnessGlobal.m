function fitness = FitnessGlobal(population, Adj)
%FUNCTIONVALUE 计算个体适应度
temp_Adj = Adj;
temp = population == 1;
temp_Adj(temp, :) = 0;
temp_Adj(:, temp) = 0;
fitness = Pair_wise(temp_Adj);
end

