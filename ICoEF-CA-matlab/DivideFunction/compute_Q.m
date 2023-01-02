function Q = compute_Q(Adj, com, m2, d)
%COMPUTE_Q 此处显示有关此函数的摘要
%   此处显示详细说明
Q = 0;
for i=1:length(Adj)
    Q = Q + Adj(i,i);
    for j=i+1:length(Adj)
        if com(i) == com(j)
            Q = Q + 2*(Adj(i,j) - (d(i)*d(j))/m2);
        end
    end
    Q = Q - (d(i)*d(i))/m2;
end
Q = Q / m2;
end

