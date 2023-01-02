function [ParetoFront, T, HV1] = Main(example,iii, pathname)
%MAIN ICoEF-PWC主函数
%   协同进化框架
addpath BaseFunction;
addpath ValueFunction;
addpath DivideFunction;
addpath OtherFunction;
addpath matlab_bgl;
%% 计算网络相关数据

popsize = 100;  % PopSize
iteration = 100;  % Iteration
Adj = example;
n = length(Adj);  % Number of nodes
k = Degree(Adj);  % Node Degree
short_paths = all_shortest_paths(Adj);
path_flag = short_paths == Inf;
short_paths(path_flag) = 0;
NC = max(max(short_paths));
impact = Potential(n, Adj);  % 节点潜力值
max_num = Kmin(n, Adj, impact);  % Kmin
[divide_Adj_label, divide_Num] = Louvain(Adj, NC);  % 鲁汶划分改良版,[社团标签编码, 划分个数]
[divide_Adj, divide_n, divide_Adj_index] = Divide(Adj, divide_Adj_label, divide_Num);  % 分解为局部网络,[局部网络矩阵,局部网络节点数,局部节点在全局索引]
divide_k = cell(divide_Num, 1);
for i = 1 : divide_Num
    divide_k{i} = Degree(divide_Adj{i});
end
[divide_change, divide_changde_sum] = Change_degree(k, divide_Adj_index, divide_k, divide_Num, divide_n);   % [全局到局部的节点度的变化,局部网络度变化和]
allocate = Allocate(divide_n, max_num, n, divide_Num);    % Allocate the number of failed nodes
source_allocate = zeros(1, divide_Num);  % 计算资源分配
%%  主循环

HV1 = zeros(1, iteration);
HV_Pop = cell(divide_Num, 1);
for Time = 6 : 15
    
    init_unit = popsize / 2;  % 初始划分，完整解一半，局部解一半
    population = cell(divide_Num, 1);
    %初始化局部解
    fprintf('初始化局部个体开始\n');
    for d = 1 : divide_Num
        population{d} = Initialize_local(allocate(d), divide_Adj_index{d}, impact, divide_Adj{d}, divide_n(d), init_unit);
        fprintf('分区%d结束\n', d);
    end
    fprintf('初始化局部个体结束\n');
    
    %初始化全局解
    fprintf('初始化完整解个体开始\n');
    solution = Initialize_global(max_num, impact, Adj, n, init_unit);
    fprintf('初始化完整解个体结束\n');
    
    % 评估全局解
    fprintf('评价完整解个体开始\n');
    failNumSolution = zeros(init_unit, 1);  % 个体函数评价
    fitnessSolution = zeros(init_unit, 1);
    parfor i = 1 : init_unit   % parfor:并行，多线程
        failNumSolution(i) = FitnessCost(solution(i, 1 : n));  % 评价cost
    end
    parfor i = 1 : init_unit
        fitnessSolution(i) = FitnessGlobal(solution(i, 1 : n), Adj);   % 评价Pair_wise
    end
    for i=1 : init_unit  % 将每个个体的代价和攻击效果加在个体编码之后
        solution(i, n + 1) = failNumSolution(i);   % 函数值
        solution(i, n + 2) = fitnessSolution(i);
    end
    fprintf('评价完整解个体结束\n');
    records_solution = solution;  % 临时进化交替前保存完整解
    
    % 全局解分解成局部解
    for d = 1 : divide_Num
        for i = 1 : init_unit
            integralIndividual = zeros(1, divide_n(d) + 2);
            for j = 1 : divide_n(d)
                temp1 = divide_Adj_index{d}(j);
                integralIndividual(j) = solution(i, temp1);
            end
            population{d} = [population{d}; integralIndividual];
        end
    end
    
    % 评估局部解
    fprintf('评价局部解个体开始\n');
    for d = 1 : divide_Num
        failNumList_temp = zeros(popsize, 1);
        fitnessList_temp = zeros(popsize, 1);
        parfor i = 1 : popsize   % parfor:并行，多线程
            failNumList_temp(i) = FitnessCost(population{d}(i, 1 : divide_n(d)));  % 评价cost
        end
        parfor i = 1 : popsize
            fitnessList_temp(i) = FitnessLocal(population{d}(i, 1 : divide_n(d)), divide_Adj{d}, divide_change{d}, divide_n(d), divide_changde_sum(d));   % 评价Pair_wise和局部损失信息
        end
        for i=1 : popsize  % 将每个个体的代价和攻击效果加在个体编码之后
            population{d}(i, divide_n(d) + 1) = failNumList_temp(i);   % 函数值
            population{d}(i, divide_n(d) + 2) =  fitnessList_temp(i);
        end
    end
    fprintf('评价局部解个体结束\n');
    
    g_flag = 0;  % 当前是全局还是局部进化的标识，1为全局，0为局部
    flag_g_l = 1;  % 交替前是全局还是局部进化的标识，1为全局，0为局部
    global_count = 0;  % 全局连续进化次数
    generation = 0;  % 当前进化代数
    local_stop_flag = 0;  % 局部进化停止标志
    adaptive_f=1;
    end_flag = 0;
    
    tic;
    % 进化阶段
    while generation ~= iteration
        generation = generation + 1;
        
        if g_flag == 1
            %% 完整解进化
            
            fprintf('当前完整解进化\n');
            global_count = global_count + 1;
            
            % 上一代是局部进化，则当前代是先构建完整解然后再进化
            if flag_g_l == 0
                % 构建完整解
                solution = zeros(popsize, n + 2);
                for i =1 : popsize
                    integralIndividual = zeros(1, n + 2);
                    for d = 1 : divide_Num
                        temp_index = randperm(popsize, 1);
                        temp1 = population{d}(temp_index, :);
                        for j = 1 : divide_n(d)
                            temp2 = divide_Adj_index{d}(j);
                            integralIndividual(temp2) = temp1(j);
                        end
                    end
                    solution(i, :) = integralIndividual;
                end
                
                % 评估全局解
                failNumSolution = zeros(popsize, 1);  % 个体函数评价
                fitnessSolution = zeros(popsize, 1);
                parfor i = 1 : popsize   % parfor:并行，多线程
                    failNumSolution(i) = FitnessCost(solution(i, 1 : n));  % 评价cost
                end
                parfor i = 1 : popsize
                    fitnessSolution(i) = FitnessGlobal(solution(i, 1 : n), Adj);   % 评价Pair_wise
                end
                for i=1 : popsize  % 将每个个体的代价和攻击效果加在个体编码之后
                    solution(i, n + 1) = failNumSolution(i);   % 函数值
                    solution(i, n + 2) = fitnessSolution(i);
                end
            end
            
            % 上一代是全局进化，当前代就直接交叉变异
            FunctionValue = solution(:, (n + 1) : (n + 2));  %种群个体的目标函数值
            [FrontValue, ~, ~] = NDSort(FunctionValue, inf);  %计算种群个体的前沿面
            CrowdDistance = F_distance(FunctionValue, FrontValue);
            
            % 产生子代
            MatingPool = F_mating(solution, FrontValue, CrowdDistance, n);   %二元联赛产生交配池
            Offspring = F_generator(MatingPool);
            
            % 评估子代全局解
            failNumSolution = zeros(popsize, 1);  % 个体函数评价
            fitnessSolution = zeros(popsize, 1);
            parfor i = 1 : popsize   % parfor:并行，多线程
                failNumSolution(i) = FitnessCost(Offspring(i, 1 : n));  % 评价cost
            end
            parfor i = 1 : popsize
                fitnessSolution(i) = FitnessGlobal(Offspring(i, 1 : n), Adj);   % 评价Pair_wise
            end
            for i=1 : popsize  % 将每个个体的代价和攻击效果加在个体编码之后
                Offspring(i, n + 1) = failNumSolution(i);   % 函数值
                Offspring(i, n + 2) = fitnessSolution(i);
            end
            
            % 环境选择
            if flag_g_l == 0  % 上一代是局部进化，则融合最近一次的完整解
                flag_g_l = 1;
                solution = [solution; records_solution];
            end
            solution = [solution; Offspring];
            solution = unique(solution, 'rows');
            [temp_len, ~] = size(solution);
            fprintf('子代父代混合完整解中去重后 = %d\n', temp_len);
            FunctionValue = solution(:, (n + 1) : (n + 2));  %种群个体的目标函数值
            [~, ~, FrontList] = NDSort(FunctionValue, inf);  %计算种群个体的前沿面
            [temp_solutions, temp_solutions_flag, CrowdList] = GridSelection(solution, FrontList, n, popsize, temp_len);  % 环境选择自适应网格策略
            
            % 局部搜索，阶段一，两阶段局部搜索
            search_num = find(temp_solutions_flag == 1);                                    % 进行局部搜索的个体
            newnum{generation} = ff(adaptive_f, search_num, CrowdList);
            PP = zeros(length(newnum{generation}), n + 2);
            search_success_flag = zeros(1, length(newnum{generation}));
            parfor i = 1 : length(newnum{generation})
                [PP(i, :), search_success_flag(i), checks(i), wchecks(i)] = New_localsearch_step1(temp_solutions(newnum{generation}(i), :), n, Adj, impact);
            end
            Totalchecks{generation}=checks;checks=[];Totalwchecks{generation}=wchecks;wchecks=[];
            adaptive_f=Adaptive(Totalchecks{generation},Totalwchecks{generation});                 %计算下一代的自适应参与因子
            for i = 1 : length(newnum{generation})
                temp_solutions(newnum{generation}(i), :) = PP(i, :);
            end
            search_success_num = sum(search_success_flag);  % 局部搜索成功个数
            fprintf('完整解，%d个，局部搜索策略，搜索：%d个，成功：%d\n', size(temp_solutions, 1), length(newnum{generation}), search_success_num);
            
            % 局部搜索，阶段二，性能最大化替换
            solution = New_localsearch_step2(n, temp_solutions, Adj, popsize);
            
            FunctionValue = solution(:, (n + 1) : (n + 2));  %种群个体的目标函数值
            plot(FunctionValue(:, 1), FunctionValue(:, 2), 'r*');
            drawnow
            [~, ~, FrontList] = NDSort(FunctionValue, inf);  %计算种群个体的前沿面
            P = solution(FrontList{1}, :);
            HV1(Time, generation)=HV(P,n);                                            %计算HV值
            
            if (global_count == 5) && (local_stop_flag == 0)
                g_flag = 0;  % 交替后是全局还是局部进化的标识，1为全局，0为局部
                flag_g_l = 1;  % 交替前是全局还是局部进化的标识，1为全局，0为局部
                global_count = 0;  % 全局连续进化次数
                
                records_solution = solution;  % 交替前保存完整种群最后一代信息
                
                % 全局解分解成局部解
                population = cell(divide_Num, 1);
                for d = 1 : divide_Num
                    for i = 1 : popsize
                        integralIndividual = zeros(1, divide_n(d) + 2);
                        for j = 1 : divide_n(d)
                            temp1 = divide_Adj_index{d}(j);
                            integralIndividual(j) = solution(i, temp1);
                        end
                        population{d} = [population{d}; integralIndividual];
                    end
                end
                % 评估局部解
                for d = 1 : divide_Num
                    failNumList_temp = zeros(popsize, 1);
                    fitnessList_temp = zeros(popsize, 1);
                    parfor i = 1 : popsize   % parfor:并行，多线程
                        failNumList_temp(i) = FitnessCost(population{d}(i, 1 : divide_n(d)));  % 评价cost
                    end
                    parfor i = 1 : popsize
                        fitnessList_temp(i) = FitnessLocal(population{d}(i, 1 : divide_n(d)), divide_Adj{d}, divide_change{d}, divide_n(d), divide_changde_sum(d)); 
                    end
                    for i=1 : popsize  % 将每个个体的代价和攻击效果加在个体编码之后
                        population{d}(i, divide_n(d) + 1) = failNumList_temp(i);   % 函数值
                        population{d}(i, divide_n(d) + 2) =  fitnessList_temp(i);
                    end
                end
            else
                if local_stop_flag == 1
                    hv_result = HV1(Time, generation);
                    end_flag = 1;
                    for hv_time = 1 : 5
                        if roundn(HV1(Time, generation - hv_time), 4) == 0
                            end_flag = 0;
                            break;
                        end
                        if roundn(hv_result, 4) ~= roundn(HV1(Time, generation - hv_time), 4)
                            end_flag = 0;
                            break;
                        end
                    end
                end
            end
        else
            %%  局部进化
            
            fprintf('当前局部解进化\n');
            g_flag_temp = sum(source_allocate);  % 当前局部子种群停滞数
            for d =1 : divide_Num  % 顺序循环处理局部子种群
                if source_allocate(d) == 1
                    continue;
                end
                FunctionValue = population{d}(:, (divide_n(d) + 1) : (divide_n(d) + 2));  %种群个体的目标函数值
                [FrontValue, ~, ~] = NDSort(FunctionValue, inf);  %计算种群个体的前沿面
                CrowdDistance = F_distance(FunctionValue, FrontValue);
                
                % 产生子代
                MatingPool = F_mating(population{d}, FrontValue, CrowdDistance, divide_n(d));   %二元联赛产生交配池
                Offspring = F_generator(MatingPool);
                
                % 评估子代局部解
                failNumList_temp = zeros(popsize, 1);
                fitnessList_temp = zeros(popsize, 1);
                parfor i = 1 : popsize   % parfor:并行，多线程
                    failNumList_temp(i) = FitnessCost(Offspring(i, 1 : divide_n(d)));  % 评价cost
                end
                parfor i = 1 : popsize
                    fitnessList_temp(i) = FitnessLocal(Offspring(i, 1 : divide_n(d)), divide_Adj{d}, divide_change{d}, divide_n(d), divide_changde_sum(d));   % 评价Pair_wise和局部损失信息
                end
                for i=1 : popsize  % 将每个个体的代价和攻击效果加在个体编码之后
                    Offspring(i, divide_n(d) + 1) = failNumList_temp(i);   % 函数值
                    Offspring(i, divide_n(d) + 2) =  fitnessList_temp(i);
                end
                
                %更新子种群
                % 上一代是全局进化
                if (g_flag == 0) && (flag_g_l == 1)
                    if d == divide_Num
                        flag_g_l = 0;
                    end
                    if generation ~=1
                        % 分区和上一次交替的解进行融合
                        population{d} = [population{d}; records_population{d}];
                    end
                end
                population{d} = [population{d}; Offspring];
                population{d} = unique(population{d}, 'rows');
                [temp_len, ~] = size(population{d});
                fprintf('局部解去重 = %d\n', temp_len);
                FunctionValue = population{d}(:, divide_n(d) + 1 : divide_n(d) + 2);  %种群个体的目标函数值
                [FrontValue, MaxFront, FrontList] = NDSort(FunctionValue, inf);  %计算种群个体的前沿面
                CrowdDistance = F_distance(FunctionValue, FrontValue);
                temp_len = 0;
                for t = 1 : MaxFront
                    temp_len = temp_len + length(FrontList{t});
                    if temp_len >= popsize
                        temp_MaxFront = t;
                        break;
                    end
                end
                Next = zeros(1, popsize);
                NoN = numel(FrontValue, FrontValue < temp_MaxFront);                      %根据拥挤距离选出最后前沿面上的个体
                Next(1 : NoN) = find(FrontValue < temp_MaxFront);
                Last = find(FrontValue == temp_MaxFront);
                [~,Rank] = sort(CrowdDistance(Last), 'descend');
                Next(NoN+1 : popsize) = Last(Rank(1 : popsize - NoN));
                population{d} = population{d}(Next, :);
                [~, ~, FrontList] = NDSort(population{d}(:, (divide_n(d)+1) : (divide_n(d) + 2)), inf);
                
                % 判断当前子种群进化是否停滞
                Pop = population{d}(FrontList{1}, :);
                HV_Pop{d} = [HV_Pop{d}, HV_Sub(Pop, divide_n(d))];                                            %计算HV值
                if (generation ~= 1) && (HV_Pop{d}(end) - HV_Pop{d}(end - 1) < 0.0001)
                    g_flag_temp = g_flag_temp + 1;
                    source_allocate(d) = 1;  % 子种群停滞，暂时不分配资源，等待下一次全局进化交替回来再分配资源
                end
            end
            
            fprintf('g_flag_temp = %d\n',g_flag_temp);
			
            % 下一代进行全局进化
            if (g_flag_temp ~= 0) && (g_flag_temp / divide_Num >= 0.5)
                flag_g_l = 0;  % 交替前是全局还是局部进化的标识，1为全局，0为局部
                g_flag = 1;
                source_allocate = zeros(1, divide_Num);  % 计算资源重新分配
                % 交替前保存子种群最后一代信息
                records_population = population;
                if g_flag_temp == divide_Num
                    local_stop_flag = 1;
                end
            else
                g_flag = 0;
            end
        end
        Ti=roundn(toc, -2);
        fprintf('ICoEF-PWC-matlab, 第%2s次, 第%2s轮, %5s问题, 已完成%4s, 耗时%5s秒\n', num2str(Time), num2str(generation), num2str(iii), num2str(roundn(generation / iteration * 100, -1)), num2str(Ti));
        T=Ti;
        if end_flag == 1
            break;
        end
    end
    ParetoFront=unique(P, 'rows');
    
    datapathHV1='Result\HV1';                                         %储存的文件夹路径
    datapathParetoFront='Result\ParetoFront';
    datapathT='Result\T';
    %dirpath=[datapath,'\','filename{i}',num2str(i),'\',name];
    datanameHV=['ICoEF-PWC-matlab_100g_HV_T',num2str(Time),'_', pathname];
    datanameParetoFront=['ICoEF-PWC-matlab_100g_ParetoFront_T',num2str(Time),'_', pathname];
    datanameT = ['ICoEF-PWC-matlab_100g_T_T',num2str(Time),'_', pathname];
    datafHV1=[datapathHV1,'\',datanameHV];
    datafParetoFront=[datapathParetoFront,'\',datanameParetoFront];
    datafT=[datapathT,'\',datanameT];
    save(datafHV1,'HV1');
    save(datafParetoFront,'ParetoFront');
    save(datafT,'T');
end
end

