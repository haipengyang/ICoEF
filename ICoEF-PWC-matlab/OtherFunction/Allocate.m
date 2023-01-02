function allocate = Allocate(divide_n, max_num, n, divide_Num)
%ALLOCATE ���乥���ڵ����
%   ÿ���ֲ����簴�������С�����ձ������乥���ڵ���������صĽ�����ں����ľֲ����ʼ����
[~, temp_index] = sort(divide_n, 'descend');
allocate = zeros(1, divide_Num);
attack_node_sum = 0;
for i = 1 : divide_Num
    if attack_node_sum < n
        temp_num = ceil(divide_n(temp_index(i)) / n * max_num);
        while 1
            if temp_num + attack_node_sum > max_num
                temp_num = temp_num - 1;
            else
                break;
            end
        end
        allocate(temp_index(i)) = temp_num;
        attack_node_sum = attack_node_sum + temp_num;
    else
        allocate(temp_index(i)) = 0;
    end
end
end

