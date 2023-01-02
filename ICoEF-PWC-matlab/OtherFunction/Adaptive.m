function f=Adaptive(MY_solutions,All_solutions)
% a=sum(MY_solutions);
% b=sum(All_solutions);
% if b~=0
% f=(b-a)/b;
% else
%     f=0;
% end
n=length(MY_solutions);
for i=1:n
    if All_solutions(i)~=0
        f(i)=MY_solutions(i)/All_solutions(i);
    else
        f(i)=0;
    end
end
f=1-sum(f)/n;
end




