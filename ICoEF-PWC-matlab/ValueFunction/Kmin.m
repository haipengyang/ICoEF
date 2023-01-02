function max_num = Kmin(n, Adj, impact)
%KMIN 找到使网络完全断开的攻击的最少节点数量
%   用二分思想，目的是归减搜索空间
global total_i;
[~,b] = sort(impact);  %按照节点潜力值进行排名, 非级联场景用升序，级联场景用降序。
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

