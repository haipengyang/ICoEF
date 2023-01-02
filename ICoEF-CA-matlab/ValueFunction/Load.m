function F = Load(k, a, n)
%LOAD 为每个节点分配负载
%   每个节点的度，按照1为比例分配负载
F = zeros(1, n);
for i = 1 : n  %初始负载求F矩阵
    F(i) = a * (k(i)^a);
end
end
% function F=fuzai(Adj,a)
% n=length(Adj);
% for i=1:n
%     k(i)=0;
%     for j=1:n
%         k(i)=k(i)+Adj(i,j);
%     end
% end
% for i=1:n  %初始负载求F矩阵
%   F(i)=a*(k(i)^a);
% end
% end
