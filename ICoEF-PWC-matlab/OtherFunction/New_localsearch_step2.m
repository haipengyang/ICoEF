function solutions = New_localsearch_step2(n, solutions, Adj, popsize)
%NEW_LOCALSEARCH_STEP2 此处显示有关此函数的摘要
%   此处显示详细说明
FunctionValue = solutions(:, (n + 1) : (n + 2));  %种群个体的目标函数值
[~, MaxFront, FrontList] = NDSort(FunctionValue, inf);  %计算种群个体的前沿面
num = FrontList{1};
local_search_flag = 0;
edge_sum = n * (n - 1) / 2;
change_factor = zeros(length(num), 1);
for i = 1 : length(num)
    change_factor(i) = (edge_sum - solutions(num(i), n + 2)) / solutions(num(i), n + 1);
    if isnan(change_factor(i)) == 1
        change_factor(i) = -1;
    end
end
[change_factor_sort, change_factor_sort_index] = sort(change_factor, 'descend');   % 比例因子排序
change_index = num(change_factor_sort_index(1));  % 添加第一个参考点
[fail_list1, ~] = ResidualNet(solutions(change_index(1), 1 : n), Adj, 0);  %第一个参考点的失效范围
change_solution_index = [];  % 需要进行替换的解
if length(change_factor_sort) > 1
    temp_change_index1 = change_factor_sort(1 : end - 1);
    temp_change_index2 = change_factor_sort(2 : end);
    temp_change_factor = temp_change_index1 -  temp_change_index2;
    [~, change_factor_index] = max(temp_change_factor);
    temp_change_index3 = num(change_factor_sort_index(change_factor_index));
    if temp_change_index3 ~= change_index
        change_index = [change_index, temp_change_index3];  % 添加第二个参考点
        [fail_list2, ~] = ResidualNet(solutions(change_index(2), 1 : n), Adj, 0);  %第二个参考点的失效范围
    end
    change_solution_index = change_factor_sort_index(change_factor_index + 1 : end);
    change_solution_index = num(change_solution_index);  % 需要进行替换的解
end
for t = 2 : MaxFront
    change_solution_index = [change_solution_index, FrontList{t}];
end
new_change = [];  % 被替换的新解
for i = 1 : length(change_solution_index)
    temp_flag = 0;
    value = change_solution_index(i);
    if length(change_index) == 2
        if (value ~= change_index(2)) && (solutions(value, n + 1) > solutions(change_index(2), n + 1))
            [temp_flag_2, temp_change] = Max_change(n, solutions(change_index(2), :), fail_list2, solutions(value, :), Adj);
            temp_flag = temp_flag_2;
            if temp_flag == 1
                new_change = [new_change; temp_change];
                local_search_flag = local_search_flag + 1;
            end
            continue;
        end
    end
    if (value ~= change_index(1)) && (solutions(value, n + 1) > solutions(change_index(1), n + 1))
        [temp_flag_2, temp_change] = Max_change(n, solutions(change_index(1), :), fail_list1, solutions(value, :), Adj);
        temp_flag = temp_flag_2;
        if temp_flag == 1
            new_change = [new_change; temp_change];
            local_search_flag = local_search_flag + 1;
        end
    end
end
fprintf('性能最大化替代策略，成功：%d\n', local_search_flag);
if ~isempty(new_change)
    solutions = [solutions; new_change];
    solutions = unique(solutions, 'rows');
    [temp_len, ~] = size(solutions);
    fprintf('性能最大化替代策略混合后，去重后 = %d\n', temp_len);
    if temp_len > 100
        FunctionValue = solutions(:, (n + 1) : (n + 2));  %种群个体的目标函数值
        [~, ~, FrontList] = NDSort(FunctionValue, inf);  %计算种群个体的前沿面
        [solutions, ~, ~] = GridSelection(solutions, FrontList, n, popsize, temp_len);  % 环境选择自适应网格策略    
    elseif temp_len ~= 100
        rand_index = randi(temp_len, 1, popsize - temp_len);
        for i = 1 : length(rand_index)
            solutions = [solutions; solutions(rand_index(i), :)];
        end
    end 
    fprintf('性能最大化替代策略，环境选择后，完整解 ：%d 个\n', size(solutions, 1));
end
end

