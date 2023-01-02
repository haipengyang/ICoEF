function [change_flag, solution] = Max_change(n, min_fail, min_fail_list, solution, Adj)
%MAX_CHANGE 性能最大化替换
%   利用已经找到的优质解做为参考，对其他解进行部分替换
change_flag = 0;
temp_code = min_fail(1 : n) == 1;
temp_flag = find(solution(temp_code) == 1);  % 包含最小代价决策变量的占有率
temp_flag = length(temp_flag);
% if (temp_flag / sum(temp_code) >= 0.99) || (sum(temp_code) - temp_flag <= 1)
if (temp_flag == sum(temp_code)) || (sum(temp_code) - temp_flag <= 1)
    temp_solution = solution;
    temp_solution(min_fail_list) = 0;
    temp_solution(temp_code) = 1;
    temp_solution(n + 1) = FitnessCost(temp_solution(1 : n));
    temp_solution(n + 2) = FitnessGlobal(temp_solution(1 : n), Adj);
    if (temp_solution(n + 2) < min_fail(n + 2)) && (temp_solution(n + 1) < solution(n + 1))
        change_flag = 1;
        solution = temp_solution;
    end
end
end

