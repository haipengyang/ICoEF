function [Offspring, search_success_flag, checks, wchecks] = New_localsearch_step1(B, Y, C, F, n, Adj, k, impact)              
%new_localsearch �ֲ�����
%   ��һ�׶�̰�ģ��ڶ��׶�����
addpath ValueFunction;

[node, load, capacity, degree_index, Adj1] = ResidualNet(B(1 : n),  Y, C, F, Adj, 1);  % Adj1Ϊʣ�����磬nodeΪʣ�������С�ڵ���1�Ľڵ�
node1 = setdiff((1 : n), node);  %node1���Ǽ���������δ�������Ľڵ㣻����������δʧЧ�ڵ��Լ��ȴ���1�Ľڵ�
% node1 = setdiff(node1, degree_index);
search_success_flag = 0;
if ~isempty(node1)
    population0(1 : n) = 0;
    t = zeros(1, length(node1));
    parfor i = 1 : length(node1)  %�Լ���֮���µ��������ֲ�����
        population1 = population0;
        population1(node1(i)) = 1;
        t(i) = length(CascadeModel2(population1, capacity, C, load, Adj1, k));
    end
    p = find(t == max(t));  % ������max���Ǽ�����min
    p1 = randperm(length(p));
    num = node1(p(p1(1)));   %̰��ѡ��ڵ�
    B1 = B(1 : n);
    B1(num) = 1;   %�¸���ind'����һ�׶�֮����¸���
    s = find(B(1 : n) == 1);  %����ind����Ľڵ�
    wchecks=length(s);
    checks=0;
    temp_impact = impact(s);
%     index = find(temp_impact == min(temp_impact));  % ע�⣬�Ǽ���������max������������min
    [~, index] = sort(temp_impact);  % ע�⣬�����kmin�ͳ�ʼ�����淴�������Ǽ��������ý��򣬼�������������
%     index = index(1 : floor(end / 2));
    Offspring = [];
    t1 = zeros(1, length(index));
    for i = 1 : length(index)
        B2 = B1;
        B2(s(index(i))) = 0;
        t1(i) = length(CascadeModel2(B2, Y, C, F, Adj, k));
        checks=checks+1;
        if -B(n + 2) < t1(i)  %�ֲ������ɹ�
            Offspring(1 : n) = B2;
            Offspring(n + 1) = FitnessCost(Offspring(1 : n));
            Offspring(n + 2) = -t1(i);
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
%     index = find(temp_impact == min(temp_impact));  % ע�⣬�Ǽ���������max������������min
    [~, index] = sort(temp_impact);  % ע�⣬�����kmin�ͳ�ʼ�����淴�������Ǽ��������ý��򣬼�������������
%     index = index(1 : floor(end / 2));
    t1 = zeros(1, length(index));
    for i = 1 : length(index)
        B2 = B(1 : n);
        B2(s(index(i))) = 0;
        t1(i) = length(CascadeModel2(B2, Y, C, F, Adj, k));
        checks=checks+1;
        if -B(n + 2) <= t1(i)
            Offspring(1 : n) = B2(1 : n);
            Offspring(n + 1) = FitnessCost(Offspring(1 : n));
            Offspring(n + 2) = -t1(i);
            search_success_flag = 1;
            break;
        end
    end
    if isempty(Offspring)
        Offspring = B;
    end
end
end

