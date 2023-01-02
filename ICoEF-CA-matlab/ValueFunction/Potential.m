function node_value = Potential(Y, C, F, n,  Adj)
%POTENTIAL �ڵ�Ǳ��ֵ
%   ���������У�ÿ���ڵ�ʧЧ���ʧЧ�ڵ����͸��ر仯
node_value = zeros(1, n);
for v = 1 : n
    B = zeros(1, n);
    B(v) = 1;
    [node,  load, ~] = CascadeModel3(B, Y, C, F, Adj);%BΪ1��n��0���飬YΪ�ڵ�ʣ��������CΪ�ڵ�������FΪ�ڵ㸺�أ�AdjΪ���ݼ�
    CC1 = length(node) / n;%ʧЧӰ����
    CC2 = sum(load(setdiff((1 : n), node)) - F(setdiff((1 : n), node))) / sum(Y(setdiff((1 : n), node)));%����Ӱ����
    node_value(v) = CC1 + CC2;
end
end

