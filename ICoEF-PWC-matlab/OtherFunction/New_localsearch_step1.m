function [Offspring, search_success_flag, checks, wchecks] = New_localsearch_step1(B, n, Adj, impact)              
%new_localsearch �ֲ�����
%   ��һ�׶�̰�ģ��ڶ��׶�����
addpath ValueFunction;

[node, Adj1] = ResidualNet(B(1 : n), Adj, 1);  % Adj1Ϊʣ�����磬nodeΪʣ�������С�ڵ���1�Ľڵ�
ResidualPair_wise = Pair_wise(Adj1);
node1 = setdiff((1 : n), node);  %node1���Ǽ���������δ�������Ľڵ㣻����������δʧЧ�ڵ��Լ��ȴ���1�Ľڵ�
search_success_flag = 0;
if (ResidualPair_wise ~= 0) && (~isempty(node1))
    population0(1 : n) = 0;
    t = zeros(1, length(node1));
    parfor i = 1 : length(node1)  %�Լ���֮���µ��������ֲ�����
        population1 = population0;
        population1(node1(i)) = 1;
        t(i) = FitnessGlobal(population1, Adj1);
    end
    p = find(t == min(t));
    p1 = randperm(length(p));
    num = node1(p(p1(1)));   %̰��ѡ��ڵ�
    B1 = B(1 : n);
    B1(num) = 1;   %�¸���ind'����һ�׶�֮����¸���
    s = find(B(1 : n) == 1);  %����ind����Ľڵ�
    wchecks=length(s);
    checks=0;
    temp_impact = impact(s);
    index = find(temp_impact == max(temp_impact));  % ע�⣬�Ǽ���������max������������min
    %[~, index] = sort(impact(s), 'descend');  % ע�⣬�����kmin�ͳ�ʼ�����淴�������Ǽ��������ý��򣬼�������������
    Offspring = [];
    t1 = zeros(1, length(index));
    for i = 1 : length(index)
        B2 = B1;
        B2(s(index(i))) = 0;
        t1(i) =  FitnessGlobal(B2, Adj);
        checks=checks+1;
        if B(n+2) > t1(i)  %�ֲ������ɹ�
            Offspring(1 : n) = B2;
            Offspring(n + 1) = FitnessCost(Offspring(1 : n));
            Offspring(n + 2) = t1(i);
            search_success_flag = 1;
            break;
        end
    end
    if isempty(Offspring)  %����û�з������£��ֲ�����ʧ��
        Offspring = B;
    end
else % ������ڵ�ȫ��������������ʣ����ͨ��Ϊ0
    Offspring = [];
    s = find(B(1 : n) == 1);
    wchecks=length(s);
    checks=0;
    temp_impact = impact(s);
    index = find(temp_impact == max(temp_impact));  % ע�⣬�Ǽ���������max������������min
    %[~, index] = sort(impact(s), 'descend');  % ע�⣬�����kmin�ͳ�ʼ�����淴�������Ǽ��������ý��򣬼�������������
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

