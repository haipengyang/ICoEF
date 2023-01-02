function max_num = Kmin(n, Adj, impact)
%KMIN �ҵ�ʹ������ȫ�Ͽ��Ĺ��������ٽڵ�����
%   �ö���˼�룬Ŀ���ǹ�������ռ�
global total_i;
[~,b] = sort(impact);  %���սڵ�Ǳ��ֵ��������, �Ǽ������������򣬼��������ý���
right = n;
left = 0;
while abs(right - left) > 1
    mid = floor((right + left)/2);
    c = b(1 : mid);
    solution = zeros(1, n);
    solution(c) = 1;
    num = FitnessGlobal(solution, Adj);
    total_i = total_i + 1;
    if num == 0
        right = mid;
    else
        left = mid;
    end
end
max_num = right;
end

