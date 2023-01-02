function k = Degree(Adj)
%DEGREE 节点度计算
%   返回每个节点度的数组
n = length(Adj);
k = zeros(1, n);
for i = 1:n
    k(i) = sum(Adj(i, :));
end
end

