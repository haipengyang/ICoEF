function solution = Initialize_global(max_num, impact, Adj, n, init_unit)
%INITIALIZE_GLOBAL ��ʼ��������
fail_min = 1;
fail_max = max_num - 1;
t = (fail_max - fail_min) / (init_unit - 1);
[~, impact_sort_index2] = sort(impact);  %���սڵ�Ǳ��ֵ��������, �Ǽ������������򣬼��������ý���
impact_sort_index = impact_sort_index2;
if length(impact_sort_index) >= init_unit
    impact_sort_index = impact_sort_index(1 : init_unit);
    random_index = randperm(init_unit);
else
    random_index = randperm(length(impact_sort_index));
    while length(random_index) < init_unit
        random_index = [random_index, randperm(length(impact_sort_index), 1)];
    end
end
solution = zeros(init_unit, n + 2);
for a = 1 : (init_unit - 1)
    num0 = floor((a - 1) * t + fail_min);
    num1 =floor(a *t + fail_min);
    if num1 <= num0
        num1 = num0+1;
    end
    num = randi([num0 num1]);
    
    %�������ѡ��
    sol(1 : n + 2) = 0;
    d = impact_sort_index(random_index(a));  % ��ʼ�ڵ�
    for j = 1 : num
        ni = (1 : n);
        sol(d) = 1;                                %�����jλ������Ϊ1
        node(j) = d;                                      %��j����ʼ�����ڵ�
        e = find(Adj(d, :) == 1);                            %Ѱ�ҵ�j����ʼ�����ڵ���ھӽڵ�
        e = setdiff(e, node);
        if ~isempty(e)
            f = e(find(impact(e) == min(impact(e))));  % ����Ҫע�⣬�Ǽ�����min��������max
            g = randperm(length(f));
            d = f(g(1));
        else
            ni(node) = [];
            c = randperm(length(ni));
            d = c(1);
        end
    end
    solution(a, :) =  sol;
end
impact_sort_index2 = impact_sort_index2(1 : max_num);
sol(1 : n + 2) = 0;
sol(impact_sort_index2) = 1;
solution(init_unit, :) =  sol;
end

