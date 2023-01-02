function [temp_solutions, temp_solutions_flag, CrowdList] = GridSelection(solution, FrontList, n, popsize, temp_len)
%SELECTION ����ѡ������Ӧ�������
%   Ŀ��ռ䰴�չ����ڵ������ֵ�ȷ�Ϊ10��������ÿ����������ԭ�и������ȱ���ѡ���
addpath BaseFunction;

unit_num = 10;  % ����ѡ�񻮷ָ���
% ����������л���
temp_failNum = solution(FrontList{1}, :);
temp_failNum = temp_failNum(:, n + 1);
failNum_max =max(temp_failNum);  % ȡ��֧������󹥻��ڵ����
unit = ceil(failNum_max / unit_num);
unit_solution = cell(unit_num, 1);
temp_num = temp_len;  % �ȴ�ѡ��Ľ�ĸ���
unit_solution_num = zeros(1, unit_num);  % ÿ�����䱣������Ŀ
for i = 1 : temp_len
    if (solution(i, n + 1) > failNum_max) || ((solution(i, n + 1) == 0) && (solution(i, n + 2) == 0))  % ������failNum���ڵ�һǰ��������failNum��ɾȥ
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
% ���������ѡ��⣬����Ӧ�������
[~, temp_index] = sort(unit_solution_num, 'ascend');
temp_size = 0;  % �Ѿ�ѡ��õĸ���
temp_solutions = [];  % �Ѿ�ѡ��õĽ�
temp_solutions_flag = zeros(1, popsize); % ��һ�׶ν��оֲ������Ľ��flag����������һһ��Ӧ
CrowdList = zeros(1, popsize);
unit_optimal_num = zeros(1, unit_num);  % ÿ�����䱣������Ŀ
temp_optimal_num = 0;  % ÿ��������֧�����ܺ�
for i = 1 : unit_num
    value = temp_index(i);
    if unit_solution_num(value) == 0
        continue;
    else  
        FunctionValue = unit_solution{value}(:, (n + 1) : (n + 2));  %��Ⱥ�����Ŀ�꺯��ֵ
        [~, ~, FrontList] = NDSort(FunctionValue, inf);  %������Ⱥ�����ǰ����
        unit_optimal_num(value) = length(FrontList{1});
        temp_optimal_num = temp_optimal_num + unit_optimal_num(value);
    end
end
for i = 1 : unit_num
    value = temp_index(i);
    solutions_flag = 0;  % �����ڿ��Ա�ѡ��Ľ�������ֹͣѡ���flag
    search_flag = 0;  % ÿ������ĵ�һǰ��������ʸ������һ�׶ν��оֲ�����
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
        
        FunctionValue = unit_solution{value}(:, (n + 1) : (n + 2));  %��Ⱥ�����Ŀ�꺯��ֵ
        [FrontValue, MaxFront, FrontList] = NDSort(FunctionValue, inf);  %������Ⱥ�����ǰ����
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

