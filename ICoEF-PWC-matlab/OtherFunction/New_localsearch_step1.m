function [Offspring, search_success_flag, checks, wchecks] = New_localsearch_step1(B, n, Adj, impact)              
%new_localsearch 局部搜索
%   第一阶段贪心，第二阶段排序
addpath ValueFunction;

[node, Adj1] = ResidualNet(B(1 : n), Adj, 1);  % Adj1为剩余网络，node为剩余网络度小于等于1的节点
ResidualPair_wise = Pair_wise(Adj1);
node1 = setdiff((1 : n), node);  %node1：非级联场景：未被攻击的节点；级联场景：未失效节点以及度大于1的节点
search_success_flag = 0;
if (ResidualPair_wise ~= 0) && (~isempty(node1))
    population0(1 : n) = 0;
    t = zeros(1, length(node1));
    parfor i = 1 : length(node1)  %对级联之后新的网络做局部搜索
        population1 = population0;
        population1(node1(i)) = 1;
        t(i) = FitnessGlobal(population1, Adj1);
    end
    p = find(t == min(t));
    p1 = randperm(length(p));
    num = node1(p(p1(1)));   %贪心选择节点
    B1 = B(1 : n);
    B1(num) = 1;   %新个体ind'，第一阶段之后的新个体
    s = find(B(1 : n) == 1);  %个体ind里面的节点
    wchecks=length(s);
    checks=0;
    temp_impact = impact(s);
    index = find(temp_impact == max(temp_impact));  % 注意，非级联场景用max，级联场景用min
    %[~, index] = sort(impact(s), 'descend');  % 注意，这里和kmin和初始化里面反过来，非级联场景用降序，级联场景用升序
    Offspring = [];
    t1 = zeros(1, length(index));
    for i = 1 : length(index)
        B2 = B1;
        B2(s(index(i))) = 0;
        t1(i) =  FitnessGlobal(B2, Adj);
        checks=checks+1;
        if B(n+2) > t1(i)  %局部搜索成功
            Offspring(1 : n) = B2;
            Offspring(n + 1) = FitnessCost(Offspring(1 : n));
            Offspring(n + 2) = t1(i);
            search_success_flag = 1;
            break;
        end
    end
    if isempty(Offspring)  %表明没有发生更新，局部搜索失败
        Offspring = B;
    end
else % 若网络节点全部被攻击，或者剩余连通性为0
    Offspring = [];
    s = find(B(1 : n) == 1);
    wchecks=length(s);
    checks=0;
    temp_impact = impact(s);
    index = find(temp_impact == max(temp_impact));  % 注意，非级联场景用max，级联场景用min
    %[~, index] = sort(impact(s), 'descend');  % 注意，这里和kmin和初始化里面反过来，非级联场景用降序，级联场景用升序
    t1 = zeros(1, length(index));
    for i = 1 : length(index)
        B2 = B(1 : n);
        B2(s(index(i))) = 0;
        t1(i) = FitnessGlobal(B2, Adj);
        checks=checks+1;
        if B(n+2) == t1(i)
            Offspring(1 : n) = B2(1 : n);
            Offspring(n + 1) = FitnessCost(Offspring(1 : n));
            Offspring(n + 2) = t1(i);
            search_success_flag = 1;
            break;
        end
    end
    if isempty(Offspring)
        Offspring = B;
    end
end
end

