% ����[�ֲ��������,�ֲ�����ڵ���,�ֲ��ڵ���ȫ������]
function [divide_Adj, divide_n, divide_Adj_index] = Divide(Adj, divide_Adj_label, divide_Num)
%DIVIDE ��������ֽ�Ϊ�ֲ�����
%   ���ؾֲ�������ڽӾ���
divide_Adj = cell(divide_Num, 1);
divide_Adj_index = cell(divide_Num, 1);  %  ��¼ÿ�����ŵĽڵ���
n = length(divide_Adj_label);
divide_n = zeros(1, divide_Num);
for i = 1 : n
    divide_Adj_index{divide_Adj_label(i)}(end + 1) = i;
end
for i = 1 : divide_Num
    divide_n(i) = length(divide_Adj_index{i});
    divide_Adj{i} = Adj(divide_Adj_index{i}, :);
    divide_Adj{i} = divide_Adj{i}(:, divide_Adj_index{i});
end
end

