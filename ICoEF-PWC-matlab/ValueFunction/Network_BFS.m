function component = Network_BFS(Adj)
%NETWORK_BFS �ù��������������ͼ
%   �ù��������������ʣ��ͼ������ʣ��ͼ����ͨ�������������û�����ߵĽڵ㲻����¼
component = {};
n = length(Adj);
search_flag = zeros(1,n);
for i = 1:n
    if search_flag(i) == -1
        continue
    end
    attack_flag = sum(Adj(i,:));
    if attack_flag == 0
        continue
    end
    queue = zeros(1,n);
    queue_index = 1;
    queue(queue_index) = i;
    search_flag(i) = -1;
    for value = 1:length(queue)
        if queue(value) == 0
            temp = queue == 0;
            queue(temp) = [];
            break
        end
        neighbor = find(Adj(queue(value),:) == 1);
        for value2 = 1:length(neighbor)
            if search_flag(neighbor(value2)) ~= -1
                queue_index = queue_index + 1;
                queue(queue_index) = neighbor(value2);
                search_flag(neighbor(value2)) = -1;
            end
        end
    end
    component{end+1} = queue;
    for value = 1:length(queue)
        Adj(queue(value),:) = 0;
        Adj(:,queue(value)) = 0;
    end
end
end

