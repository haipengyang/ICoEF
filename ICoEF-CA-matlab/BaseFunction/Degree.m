function k = Degree(Adj)
%DEGREE �ڵ�ȼ���
%   ����ÿ���ڵ�ȵ�����
n = length(Adj);
k = zeros(1, n);
for i = 1:n
    k(i) = sum(Adj(i, :));
end
end

