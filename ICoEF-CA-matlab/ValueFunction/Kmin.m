function max_num = Kmin(n, Adj, impact, Y, C, F)
%KMIN �ҵ�ʹ������ȫʧЧ�Ĺ��������ٽڵ�����
%   �ö���˼�룬Ŀ���ǹ�������ռ�
global total_i;
[~, b] = sort(impact, 'descend');  %���սڵ�Ǳ��ֵ��������, �Ǽ������������򣬼��������ý���
right = n;
left = 0;
while abs(right - left) > 1
    mid = floor((right + left)/2);
    c = b(1 : mid);
    solution = zeros(1, n);
    solution(c) = 1;
    num = CascadeModel(solution, Y, C, F, Adj);
    total_i = total_i + 1;
    if num >= n
        right = mid;
    else
        left = mid;
    end
end
max_num = right;
end

