function Y = ResidualCapacity(F, C, n)
%RESIDUALCAPACITY ����ڵ�ʣ������
%   ʣ������ = ���� - ��ǰ���� 
Y = zeros(1, n);
for i = 1 : n  % ʣ����������Y����
    if C(i) < F(i)
        Y(i) = 0;
    else
        Y(i) = C(i) - F(i);
    end
end
end