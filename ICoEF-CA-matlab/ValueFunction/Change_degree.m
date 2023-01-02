function [divide_change, divide_change_sum] = Change_degree(k, divide_Adj_index, divide_k, divide_Num, divide_n)
%CHANGE_DEGREE 此处显示有关此函数的摘要
%   用于局部的个体评估，记录子网中边界节点的所有不在子网内的邻居节点的度之和
divide_change = cell(divide_Num, 1);
divide_change_sum = zeros(1, divide_Num);
for i = 1 : divide_Num
    temp_change = zeros(1, divide_n(i));
    for j = 1 : divide_n(i)
        global_index = divide_Adj_index{i}(j);
        temp_change(j) = k(global_index) - divide_k{i}(j);
    end
    divide_change{i} = temp_change;
    divide_change_sum(i) = sum(divide_change{i});
end
end

