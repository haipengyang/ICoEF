function [temp_solutions, temp_solutions_flag, CrowdList] = GridSelection(solution, FrontList, n, popsize, temp_len)
%SELECTION 环境选择自适应网格策略
%   目标空间按照攻击节点数最大值等分为10个分区，每个分区按照原有个体数等比例选择解
addpath BaseFunction;

unit_num = 10;  % 环境选择划分个数
% 对完整解进行划分
temp_failNum = solution(FrontList{1}, :);
temp_failNum = temp_failNum(:, n + 1);
failNum_max =max(temp_failNum);  % 取非支配解的最大攻击节点个数
unit = ceil(failNum_max / unit_num);
unit_solution = cell(unit_num, 1);
temp_num = temp_len;  % 等待选择的解的个数
unit_solution_num = zeros(1, unit_num);  % 每个区间保存解的数目
for i = 1 : temp_len
    if (solution(i, n + 1) > failNum_max) || ((solution(i, n + 1) == 0) && (solution(i, n + 2) == 0))  % 如果解的failNum大于第一前沿面的最大failNum则删去
        temp_num = temp_num - 1;
        continue;
    end
    temp_unit = floor(solution(i, n + 1) / unit) + 1;
    if temp_unit > unit_num
        temp_unit = unit_num;
    elseif temp_unit < 1
        temp_unit = 2;
    end
    unit_solution_num(temp_unit) = unit_solution_num(temp_unit) + 1;
    unit_solution{temp_unit} = [unit_solution{temp_unit}; solution(i, :)];
end
% 面向多样性选择解，自适应网格策略
[~, temp_index] = sort(unit_solution_num, 'ascend');
temp_size = 0;  % 已经选择好的个数
temp_solutions = [];  % 已经选择好的解
temp_solutions_flag = zeros(1, popsize); % 下一阶段进行局部搜索的解的flag，与解的索引一一对应
CrowdList = zeros(1, popsize);
unit_optimal_num = zeros(1, unit_num);  % 每个区间保存解的数目
temp_optimal_num = 0;  % 每个分区非支配解的总和
for i = 1 : unit_num
    value = temp_index(i);
    if unit_solution_num(value) == 0
        continue;
    else  
        FunctionValue = unit_solution{value}(:, (n + 1) : (n + 2));  %种群个体的目标函数值
        [~, ~, FrontList] = NDSort(FunctionValue, inf);  %计算种群个体的前沿面
        unit_optimal_num(value) = length(FrontList{1});
        temp_optimal_num = temp_optimal_num + unit_optimal_num(value);
    end
end
for i = 1 : unit_num
    value = temp_index(i);
    solutions_flag = 0;  % 区间内可以被选择的解已满，停止选择的flag
    search_flag = 0;  % 每个区间的第一前沿面才有资格进行下一阶段进行局部搜索
    if unit_solution_num(value) == 0
        continue;
    else
        if i == unit_num
            temp_unit_num = popsize - temp_size;
        else
            %temp_unit_num = ceil(unit_solution_num(value) / temp_num * popsize);
            temp_unit_num = ceil(unit_optimal_num(value) / temp_optimal_num * popsize);
            if temp_unit_num <= 1
                temp_unit_num = 2;
            end
        end
        if (temp_unit_num <= 0) || (temp_size >= popsize)
            continue;
        end
        
        FunctionValue = unit_solution{value}(:, (n + 1) : (n + 2));  %种群个体的目标函数值
        [FrontValue, MaxFront, FrontList] = NDSort(FunctionValue, inf);  %计算种群个体的前沿面
        CrowdDistance = F_distance(FunctionValue, FrontValue);
        for f = 1 : MaxFront
            if length(FrontList{f}) <= temp_unit_num
                for t = 1 : length(FrontList{f})
                    temp_unit_num = temp_unit_num - 1;
                    temp_size = temp_size + 1;
                    temp_solutions(temp_size, :) = unit_solution{value}(FrontList{f}(t), :);
                    CrowdList(temp_size) = CrowdDistance(FrontList{f}(t));
                    if search_flag == 0
                        temp_solutions_flag(temp_size) = 1;
                    end
                    if temp_unit_num == 0
                        solutions_flag = 1;
                        break;
                    end
                end
            else
                [~,Rank] = sort(CrowdDistance(FrontList{f}), 'descend');
                for t = 1 : length(Rank)
                    temp_unit_num = temp_unit_num - 1;
                    temp_size = temp_size + 1;
                    temp_solutions(temp_size, :) = unit_solution{value}(FrontList{f}(Rank(t)), :);
                    CrowdList(temp_size) = CrowdDistance(FrontList{f}(Rank(t)));
                    if search_flag == 0
                        temp_solutions_flag(temp_size) = 1;
                    end
                    if temp_unit_num == 0
                        solutions_flag = 1;
                        break;
                    end
                end
            end
            search_flag = 1;
            if solutions_flag == 1
                break;
            end
        end
    end
end
while size(temp_solutions, 1) < popsize
    temp_solutions = [temp_solutions; temp_solutions(randi(size(temp_solutions, 1), 1), :)];
end
end

