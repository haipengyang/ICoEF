function Y = ResidualCapacity(F, C, n)
%RESIDUALCAPACITY 计算节点剩余容量
%   剩余容量 = 容量 - 当前负载 
Y = zeros(1, n);
for i = 1 : n  % 剩余容量，求Y矩阵
    if C(i) < F(i)
        Y(i) = 0;
    else
        Y(i) = C(i) - F(i);
    end
end
end