function C = Capacity(F, c, n)
%CAPACITY 为每个节点设置负载容量
%   每个节点的度，按照1.5为比例设置负载容量
C = zeros(1, n);
for i = 1 : n
    C(i) = c * F(i);
end
end