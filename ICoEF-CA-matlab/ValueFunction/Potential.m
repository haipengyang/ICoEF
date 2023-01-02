function node_value = Potential(Y, C, F, n,  Adj)
%POTENTIAL 节点潜力值
%   级联场景中，每个节点失效后的失效节点数和负载变化
node_value = zeros(1, n);
for v = 1 : n
    B = zeros(1, n);
    B(v) = 1;
    [node,  load, ~] = CascadeModel3(B, Y, C, F, Adj);%B为1到n的0数组，Y为节点剩余容量，C为节点容量，F为节点负载，Adj为数据集
    CC1 = length(node) / n;%失效影响力
    CC2 = sum(load(setdiff((1 : n), node)) - F(setdiff((1 : n), node))) / sum(Y(setdiff((1 : n), node)));%负载影响力
    node_value(v) = CC1 + CC2;
end
end

