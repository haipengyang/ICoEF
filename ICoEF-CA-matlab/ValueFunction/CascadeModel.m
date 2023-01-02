function A = CascadeModel(B, Y, C, F, Adj)
%CASCADEMODEL 级联失效模型
%   B为1到n的0数组，每次只设一个节点为1，Y为节点剩余容量，C为节点容量，F为节点负载，Adj为数据集
%   找出失效节点的个数
t = 1;                                                            %初始级联
Y1 = {};                                                          %采用元胞数组储存信息，如Y1={Y（1），Y（2），Y（3），...，Y（t）}，每一个Y（t）表示t时候更新的数据
Y1{t} = Y;
F1 = {};
F1{t} = F;
e{t} = find(B == 1);                                                 %e为每次级联的失效点
temp_search = B;
ezz{t} = e{t};                                                     %ezz为累积的失效点，注、初始时刻（即t=1时），ez{t=1}=e{t=1}
while ~isempty(e{t})
    t = t + 1;
    e{t} = [];
    Y1{t} = Y1{t - 1};
    F1{t} = F1{t - 1};
    d5 = [];
    for i = 1 : length(e{t - 1})                                         %上一次级联的失效点
        Y1{t}(e{t - 1}(i)) = 0;
        d1 = find(Adj(e{t - 1}(i), :) == 1);                                %失效点邻居节点
%         d2 = intersect(ezz{t - 1}, d1);                                 %找出邻居节点中的失效节点
%         d1 = setdiff(d1, d2);                                         %找出邻居节点中未失效节点，向其分配负载
%         d5{i} = d1;                                                  %储存累计的d1，即负载将会增加的点,元胞数组的长度等于上一次级联的失效点的个数
        if ~isempty(d1)                                           %向邻居节点分配负载,分配比例与负载有关
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
    %d6 = unique([d5{:, :}]);                                           %负载增加的节点
    d6 = d5;
    q = 0;
    temp_F1 = zeros(1, length(Adj));
    for i = 1 : length(d6)                                              %更新负载、剩余负载
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