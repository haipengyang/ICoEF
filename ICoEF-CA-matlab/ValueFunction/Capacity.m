function C = Capacity(F, c, n)
%CAPACITY Ϊÿ���ڵ����ø�������
%   ÿ���ڵ�Ķȣ�����1.5Ϊ�������ø�������
C = zeros(1, n);
for i = 1 : n
    C(i) = c * F(i);
end
end