function node_value = Potential(n, Adj)
%POTENTIAL 节点潜力值
%   非级联场景中，每个节点失效后的静态指标值(PWC)
node_value = zeros(1, n);
for i = 1 : n
    temp_Adj = Adj;
    temp_Adj(i, :) = 0;
    temp_Adj(:, i) = 0;
    node_value(i) = Pair_wise(temp_Adj);
end
end

