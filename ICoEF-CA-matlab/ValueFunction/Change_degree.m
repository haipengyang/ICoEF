function [divide_change, divide_change_sum] = Change_degree(k, divide_Adj_index, divide_k, divide_Num, divide_n)
%CHANGE_DEGREE �˴���ʾ�йش˺�����ժҪ
%   ���ھֲ��ĸ�����������¼�����б߽�ڵ�����в��������ڵ��ھӽڵ�Ķ�֮��
divide_change = cell(divide_Num, 1);
divide_change_sum = zeros(1, divide_Num);
for i = 1 : divide_Num
    temp_change = zeros(1, divide_n(i));
    for j = 1 : divide_n(i)
        global_index = divide_Adj_index{i}(j);
        temp_change(j) = k(global_index) - divide_k{i}(j);
    end
    divide_change{i} = temp_change;
    divide_change_sum(i) = sum(divide_change{i});
end
end

