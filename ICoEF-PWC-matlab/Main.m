function [ParetoFront, T, HV1] = Main(example,iii, pathname)
%MAIN ICoEF-PWC������
%   Эͬ�������
addpath BaseFunction;
addpath ValueFunction;
addpath DivideFunction;
addpath OtherFunction;
addpath matlab_bgl;
%% ���������������

popsize = 100;  % PopSize
iteration = 100;  % Iteration
Adj = example;
n = length(Adj);  % Number of nodes
k = Degree(Adj);  % Node Degree
short_paths = all_shortest_paths(Adj);
path_flag = short_paths == Inf;
short_paths(path_flag) = 0;
NC = max(max(short_paths));
impact = Potential(n, Adj);  % �ڵ�Ǳ��ֵ
max_num = Kmin(n, Adj, impact);  % Kmin
[divide_Adj_label, divide_Num] = Louvain(Adj, NC);  % ³�뻮�ָ�����,[���ű�ǩ����, ���ָ���]
[divide_Adj, divide_n, divide_Adj_index] = Divide(Adj, divide_Adj_label, divide_Num);  % �ֽ�Ϊ�ֲ�����,[�ֲ��������,�ֲ�����ڵ���,�ֲ��ڵ���ȫ������]
divide_k = cell(divide_Num, 1);
for i = 1 : divide_Num
    divide_k{i} = Degree(divide_Adj{i});
end
[divide_change, divide_changde_sum] = Change_degree(k, divide_Adj_index, divide_k, divide_Num, divide_n);   % [ȫ�ֵ��ֲ��Ľڵ�ȵı仯,�ֲ�����ȱ仯��]
allocate = Allocate(divide_n, max_num, n, divide_Num);    % Allocate the number of failed nodes
source_allocate = zeros(1, divide_Num);  % ������Դ����
%%  ��ѭ��

HV1 = zeros(1, iteration);
HV_Pop = cell(divide_Num, 1);
for Time = 6 : 15
    
    init_unit = popsize / 2;  % ��ʼ���֣�������һ�룬�ֲ���һ��
    population = cell(divide_Num, 1);
    %��ʼ���ֲ���
    fprintf('��ʼ���ֲ����忪ʼ\n');
    for d = 1 : divide_Num
        population{d} = Initialize_local(allocate(d), divide_Adj_index{d}, impact, divide_Adj{d}, divide_n(d), init_unit);
        fprintf('����%d����\n', d);
    end
    fprintf('��ʼ���ֲ��������\n');
    
    %��ʼ��ȫ�ֽ�
    fprintf('��ʼ����������忪ʼ\n');
    solution = Initialize_global(max_num, impact, Adj, n, init_unit);
    fprintf('��ʼ��������������\n');
    
    % ����ȫ�ֽ�
    fprintf('������������忪ʼ\n');
    failNumSolution = zeros(init_unit, 1);  % ���庯������
    fitnessSolution = zeros(init_unit, 1);
    parfor i = 1 : init_unit   % parfor:���У����߳�
        failNumSolution(i) = FitnessCost(solution(i, 1 : n));  % ����cost
    end
    parfor i = 1 : init_unit
        fitnessSolution(i) = FitnessGlobal(solution(i, 1 : n), Adj);   % ����Pair_wise
    end
    for i=1 : init_unit  % ��ÿ������Ĵ��ۺ͹���Ч�����ڸ������֮��
        solution(i, n + 1) = failNumSolution(i);   % ����ֵ
        solution(i, n + 2) = fitnessSolution(i);
    end
    fprintf('����������������\n');
    records_solution = solution;  % ��ʱ��������ǰ����������
    
    % ȫ�ֽ�ֽ�ɾֲ���
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
    
    % �����ֲ���
    fprintf('���۾ֲ�����忪ʼ\n');
    for d = 1 : divide_Num
        failNumList_temp = zeros(popsize, 1);
        fitnessList_temp = zeros(popsize, 1);
        parfor i = 1 : popsize   % parfor:���У����߳�
            failNumList_temp(i) = FitnessCost(population{d}(i, 1 : divide_n(d)));  % ����cost
        end
        parfor i = 1 : popsize
            fitnessList_temp(i) = FitnessLocal(population{d}(i, 1 : divide_n(d)), divide_Adj{d}, divide_change{d}, divide_n(d), divide_changde_sum(d));   % ����Pair_wise�;ֲ���ʧ��Ϣ
        end
        for i=1 : popsize  % ��ÿ������Ĵ��ۺ͹���Ч�����ڸ������֮��
            population{d}(i, divide_n(d) + 1) = failNumList_temp(i);   % ����ֵ
            population{d}(i, divide_n(d) + 2) =  fitnessList_temp(i);
        end
    end
    fprintf('���۾ֲ���������\n');
    
    g_flag = 0;  % ��ǰ��ȫ�ֻ��Ǿֲ������ı�ʶ��1Ϊȫ�֣�0Ϊ�ֲ�
    flag_g_l = 1;  % ����ǰ��ȫ�ֻ��Ǿֲ������ı�ʶ��1Ϊȫ�֣�0Ϊ�ֲ�
    global_count = 0;  % ȫ��������������
    generation = 0;  % ��ǰ��������
    local_stop_flag = 0;  % �ֲ�����ֹͣ��־
    adaptive_f=1;
    end_flag = 0;
    
    tic;
    % �����׶�
    while generation ~= iteration
        generation = generation + 1;
        
        if g_flag == 1
            %% ���������
            
            fprintf('��ǰ���������\n');
            global_count = global_count + 1;
            
            % ��һ���Ǿֲ���������ǰ�����ȹ���������Ȼ���ٽ���
            if flag_g_l == 0
                % ����������
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
                
                % ����ȫ�ֽ�
                failNumSolution = zeros(popsize, 1);  % ���庯������
                fitnessSolution = zeros(popsize, 1);
                parfor i = 1 : popsize   % parfor:���У����߳�
                    failNumSolution(i) = FitnessCost(solution(i, 1 : n));  % ����cost
                end
                parfor i = 1 : popsize
                    fitnessSolution(i) = FitnessGlobal(solution(i, 1 : n), Adj);   % ����Pair_wise
                end
                for i=1 : popsize  % ��ÿ������Ĵ��ۺ͹���Ч�����ڸ������֮��
                    solution(i, n + 1) = failNumSolution(i);   % ����ֵ
                    solution(i, n + 2) = fitnessSolution(i);
                end
            end
            
            % ��һ����ȫ�ֽ�������ǰ����ֱ�ӽ������
            FunctionValue = solution(:, (n + 1) : (n + 2));  %��Ⱥ�����Ŀ�꺯��ֵ
            [FrontValue, ~, ~] = NDSort(FunctionValue, inf);  %������Ⱥ�����ǰ����
            CrowdDistance = F_distance(FunctionValue, FrontValue);
            
            % �����Ӵ�
            MatingPool = F_mating(solution, FrontValue, CrowdDistance, n);   %��Ԫ�������������
            Offspring = F_generator(MatingPool);
            
            % �����Ӵ�ȫ�ֽ�
            failNumSolution = zeros(popsize, 1);  % ���庯������
            fitnessSolution = zeros(popsize, 1);
            parfor i = 1 : popsize   % parfor:���У����߳�
                failNumSolution(i) = FitnessCost(Offspring(i, 1 : n));  % ����cost
            end
            parfor i = 1 : popsize
                fitnessSolution(i) = FitnessGlobal(Offspring(i, 1 : n), Adj);   % ����Pair_wise
            end
            for i=1 : popsize  % ��ÿ������Ĵ��ۺ͹���Ч�����ڸ������֮��
                Offspring(i, n + 1) = failNumSolution(i);   % ����ֵ
                Offspring(i, n + 2) = fitnessSolution(i);
            end
            
            % ����ѡ��
            if flag_g_l == 0  % ��һ���Ǿֲ����������ں����һ�ε�������
                flag_g_l = 1;
                solution = [solution; records_solution];
            end
            solution = [solution; Offspring];
            solution = unique(solution, 'rows');
            [temp_len, ~] = size(solution);
            fprintf('�Ӵ����������������ȥ�غ� = %d\n', temp_len);
            FunctionValue = solution(:, (n + 1) : (n + 2));  %��Ⱥ�����Ŀ�꺯��ֵ
            [~, ~, FrontList] = NDSort(FunctionValue, inf);  %������Ⱥ�����ǰ����
            [temp_solutions, temp_solutions_flag, CrowdList] = GridSelection(solution, FrontList, n, popsize, temp_len);  % ����ѡ������Ӧ�������
            
            % �ֲ��������׶�һ�����׶ξֲ�����
            search_num = find(temp_solutions_flag == 1);                                    % ���оֲ������ĸ���
            newnum{generation} = ff(adaptive_f, search_num, CrowdList);
            PP = zeros(length(newnum{generation}), n + 2);
            search_success_flag = zeros(1, length(newnum{generation}));
            parfor i = 1 : length(newnum{generation})
                [PP(i, :), search_success_flag(i), checks(i), wchecks(i)] = New_localsearch_step1(temp_solutions(newnum{generation}(i), :), n, Adj, impact);
            end
            Totalchecks{generation}=checks;checks=[];Totalwchecks{generation}=wchecks;wchecks=[];
            adaptive_f=Adaptive(Totalchecks{generation},Totalwchecks{generation});                 %������һ��������Ӧ��������
            for i = 1 : length(newnum{generation})
                temp_solutions(newnum{generation}(i), :) = PP(i, :);
            end
            search_success_num = sum(search_success_flag);  % �ֲ������ɹ�����
            fprintf('�����⣬%d�����ֲ��������ԣ�������%d�����ɹ���%d\n', size(temp_solutions, 1), length(newnum{generation}), search_success_num);
            
            % �ֲ��������׶ζ�����������滻
            solution = New_localsearch_step2(n, temp_solutions, Adj, popsize);
            
            FunctionValue = solution(:, (n + 1) : (n + 2));  %��Ⱥ�����Ŀ�꺯��ֵ
            plot(FunctionValue(:, 1), FunctionValue(:, 2), 'r*');
            drawnow
            [~, ~, FrontList] = NDSort(FunctionValue, inf);  %������Ⱥ�����ǰ����
            P = solution(FrontList{1}, :);
            HV1(Time, generation)=HV(P,n);                                            %����HVֵ
            
            if (global_count == 5) && (local_stop_flag == 0)
                g_flag = 0;  % �������ȫ�ֻ��Ǿֲ������ı�ʶ��1Ϊȫ�֣�0Ϊ�ֲ�
                flag_g_l = 1;  % ����ǰ��ȫ�ֻ��Ǿֲ������ı�ʶ��1Ϊȫ�֣�0Ϊ�ֲ�
                global_count = 0;  % ȫ��������������
                
                records_solution = solution;  % ����ǰ����������Ⱥ���һ����Ϣ
                
                % ȫ�ֽ�ֽ�ɾֲ���
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
                % �����ֲ���
                for d = 1 : divide_Num
                    failNumList_temp = zeros(popsize, 1);
                    fitnessList_temp = zeros(popsize, 1);
                    parfor i = 1 : popsize   % parfor:���У����߳�
                        failNumList_temp(i) = FitnessCost(population{d}(i, 1 : divide_n(d)));  % ����cost
                    end
                    parfor i = 1 : popsize
                        fitnessList_temp(i) = FitnessLocal(population{d}(i, 1 : divide_n(d)), divide_Adj{d}, divide_change{d}, divide_n(d), divide_changde_sum(d)); 
                    end
                    for i=1 : popsize  % ��ÿ������Ĵ��ۺ͹���Ч�����ڸ������֮��
                        population{d}(i, divide_n(d) + 1) = failNumList_temp(i);   % ����ֵ
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
            %%  �ֲ�����
            
            fprintf('��ǰ�ֲ������\n');
            g_flag_temp = sum(source_allocate);  % ��ǰ�ֲ�����Ⱥͣ����
            for d =1 : divide_Num  % ˳��ѭ������ֲ�����Ⱥ
                if source_allocate(d) == 1
                    continue;
                end
                FunctionValue = population{d}(:, (divide_n(d) + 1) : (divide_n(d) + 2));  %��Ⱥ�����Ŀ�꺯��ֵ
                [FrontValue, ~, ~] = NDSort(FunctionValue, inf);  %������Ⱥ�����ǰ����
                CrowdDistance = F_distance(FunctionValue, FrontValue);
                
                % �����Ӵ�
                MatingPool = F_mating(population{d}, FrontValue, CrowdDistance, divide_n(d));   %��Ԫ�������������
                Offspring = F_generator(MatingPool);
                
                % �����Ӵ��ֲ���
                failNumList_temp = zeros(popsize, 1);
                fitnessList_temp = zeros(popsize, 1);
                parfor i = 1 : popsize   % parfor:���У����߳�
                    failNumList_temp(i) = FitnessCost(Offspring(i, 1 : divide_n(d)));  % ����cost
                end
                parfor i = 1 : popsize
                    fitnessList_temp(i) = FitnessLocal(Offspring(i, 1 : divide_n(d)), divide_Adj{d}, divide_change{d}, divide_n(d), divide_changde_sum(d));   % ����Pair_wise�;ֲ���ʧ��Ϣ
                end
                for i=1 : popsize  % ��ÿ������Ĵ��ۺ͹���Ч�����ڸ������֮��
                    Offspring(i, divide_n(d) + 1) = failNumList_temp(i);   % ����ֵ
                    Offspring(i, divide_n(d) + 2) =  fitnessList_temp(i);
                end
                
                %��������Ⱥ
                % ��һ����ȫ�ֽ���
                if (g_flag == 0) && (flag_g_l == 1)
                    if d == divide_Num
                        flag_g_l = 0;
                    end
                    if generation ~=1
                        % ��������һ�ν���Ľ�����ں�
                        population{d} = [population{d}; records_population{d}];
                    end
                end
                population{d} = [population{d}; Offspring];
                population{d} = unique(population{d}, 'rows');
                [temp_len, ~] = size(population{d});
                fprintf('�ֲ���ȥ�� = %d\n', temp_len);
                FunctionValue = population{d}(:, divide_n(d) + 1 : divide_n(d) + 2);  %��Ⱥ�����Ŀ�꺯��ֵ
                [FrontValue, MaxFront, FrontList] = NDSort(FunctionValue, inf);  %������Ⱥ�����ǰ����
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
                NoN = numel(FrontValue, FrontValue < temp_MaxFront);                      %����ӵ������ѡ�����ǰ�����ϵĸ���
                Next(1 : NoN) = find(FrontValue < temp_MaxFront);
                Last = find(FrontValue == temp_MaxFront);
                [~,Rank] = sort(CrowdDistance(Last), 'descend');
                Next(NoN+1 : popsize) = Last(Rank(1 : popsize - NoN));
                population{d} = population{d}(Next, :);
                [~, ~, FrontList] = NDSort(population{d}(:, (divide_n(d)+1) : (divide_n(d) + 2)), inf);
                
                % �жϵ�ǰ����Ⱥ�����Ƿ�ͣ��
                Pop = population{d}(FrontList{1}, :);
                HV_Pop{d} = [HV_Pop{d}, HV_Sub(Pop, divide_n(d))];                                            %����HVֵ
                if (generation ~= 1) && (HV_Pop{d}(end) - HV_Pop{d}(end - 1) < 0.0001)
                    g_flag_temp = g_flag_temp + 1;
                    source_allocate(d) = 1;  % ����Ⱥͣ�ͣ���ʱ��������Դ���ȴ���һ��ȫ�ֽ�����������ٷ�����Դ
                end
            end
            
            fprintf('g_flag_temp = %d\n',g_flag_temp);
			
            % ��һ������ȫ�ֽ���
            if (g_flag_temp ~= 0) && (g_flag_temp / divide_Num >= 0.5)
                flag_g_l = 0;  % ����ǰ��ȫ�ֻ��Ǿֲ������ı�ʶ��1Ϊȫ�֣�0Ϊ�ֲ�
                g_flag = 1;
                source_allocate = zeros(1, divide_Num);  % ������Դ���·���
                % ����ǰ��������Ⱥ���һ����Ϣ
                records_population = population;
                if g_flag_temp == divide_Num
                    local_stop_flag = 1;
                end
            else
                g_flag = 0;
            end
        end
        Ti=roundn(toc, -2);
        fprintf('ICoEF-PWC-matlab, ��%2s��, ��%2s��, %5s����, �����%4s, ��ʱ%5s��\n', num2str(Time), num2str(generation), num2str(iii), num2str(roundn(generation / iteration * 100, -1)), num2str(Ti));
        T=Ti;
        if end_flag == 1
            break;
        end
    end
    ParetoFront=unique(P, 'rows');
    
    datapathHV1='Result\HV1';                                         %������ļ���·��
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

