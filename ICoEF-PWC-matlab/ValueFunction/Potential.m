function node_value = Potential(n, Adj)
%POTENTIAL �ڵ�Ǳ��ֵ
%   �Ǽ��������У�ÿ���ڵ�ʧЧ��ľ�ָ̬��ֵ(PWC)
node_value = zeros(1, n);
for i = 1 : n
    temp_Adj = Adj;
    temp_Adj(i, :) = 0;
    temp_Adj(:, i) = 0;
    node_value(i) = Pair_wise(temp_Adj);
end
end

