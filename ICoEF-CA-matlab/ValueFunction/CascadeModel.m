function A = CascadeModel(B, Y, C, F, Adj)
%CASCADEMODEL ����ʧЧģ��
%   BΪ1��n��0���飬ÿ��ֻ��һ���ڵ�Ϊ1��YΪ�ڵ�ʣ��������CΪ�ڵ�������FΪ�ڵ㸺�أ�AdjΪ���ݼ�
%   �ҳ�ʧЧ�ڵ�ĸ���
t = 1;                                                            %��ʼ����
Y1 = {};                                                          %����Ԫ�����鴢����Ϣ����Y1={Y��1����Y��2����Y��3����...��Y��t��}��ÿһ��Y��t����ʾtʱ����µ�����
Y1{t} = Y;
F1 = {};
F1{t} = F;
e{t} = find(B == 1);                                                 %eΪÿ�μ�����ʧЧ��
temp_search = B;
ezz{t} = e{t};                                                     %ezzΪ�ۻ���ʧЧ�㣬ע����ʼʱ�̣���t=1ʱ����ez{t=1}=e{t=1}
while ~isempty(e{t})
    t = t + 1;
    e{t} = [];
    Y1{t} = Y1{t - 1};
    F1{t} = F1{t - 1};
    d5 = [];
    for i = 1 : length(e{t - 1})                                         %��һ�μ�����ʧЧ��
        Y1{t}(e{t - 1}(i)) = 0;
        d1 = find(Adj(e{t - 1}(i), :) == 1);                                %ʧЧ���ھӽڵ�
%         d2 = intersect(ezz{t - 1}, d1);                                 %�ҳ��ھӽڵ��е�ʧЧ�ڵ�
%         d1 = setdiff(d1, d2);                                         %�ҳ��ھӽڵ���δʧЧ�ڵ㣬������为��
%         d5{i} = d1;                                                  %�����ۼƵ�d1�������ؽ������ӵĵ�,Ԫ������ĳ��ȵ�����һ�μ�����ʧЧ��ĸ���
        if ~isempty(d1)                                           %���ھӽڵ���为��,��������븺���й�
            sum = 0;
            for j = 1 : length(d1)
                if temp_search(d1(j)) == 1
                    continue;
                end
                sum = sum + F(d1(j));
                d5 = [d5, d1(j)];
            end
            for j = 1 : length(d1)
                if temp_search(d1(j)) == 1
                    continue;
                end
                F1{t}(d1(j)) = F1{t}(d1(j)) + F1{t - 1}(e{t - 1}(i)) * F(d1(j)) / sum;
            end
        end
    end
    %d6 = unique([d5{:, :}]);                                           %�������ӵĽڵ�
    d6 = d5;
    q = 0;
    temp_F1 = zeros(1, length(Adj));
    for i = 1 : length(d6)                                              %���¸��ء�ʣ�ฺ��
        if temp_F1(d6(i)) == 1
            continue;
        end
        if F1{t}(d6(i)) > C(d6(i))
            Y1{t}(d6(i)) = 0;
            q = q + 1;
            e{t}(q) = d6(i);
            temp_search(d6(i)) = 1;
            temp_F1(d6(i)) = 1;
        else
            Y1{t}(d6(i)) = C(d6(i)) - F1{t}(d6(i));
            temp_F1(d6(i)) = 1;
        end
    end
    ezz{t} = [e{:,:}];
end
A = length(ezz{t});
end