function pairwise = Pair_wise(Adj)
%PAIR_WISE ����ʣ��ͼ�ĳɶ���ͨ��
%   �ȼ���ʣ��ͼ�ĸ������������Ȼ���ټ�����������ͨ�ԣ����Ӻ�
% component = Network_BFS(Adj);
% component_num = size(component);
% component_num = component_num(2);
% pairwise = 0;
% for value = 1:component_num
%     con_num = length(component{1,value});
%     pairwise = pairwise + con_num * (con_num - 1) / 2;
% end
[~, component] = components(Adj);
pairwise = 0;
for value = 1 : length(component)
    con_num = component(value);
    pairwise = pairwise + con_num * (con_num - 1) / 2;
end
end

