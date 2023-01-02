% 返回[局部网络矩阵,局部网络节点数,局部节点在全局索引]
function [divide_Adj, divide_n, divide_Adj_index] = Divide(Adj, divide_Adj_label, divide_Num)
%DIVIDE 完整网络分解为局部网络
%   返回局部网络的邻接矩阵
divide_Adj = cell(divide_Num, 1);
divide_Adj_index = cell(divide_Num, 1);  %  记录每个社团的节点编号
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

