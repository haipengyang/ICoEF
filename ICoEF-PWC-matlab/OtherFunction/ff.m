%f自适应参与因子初始值为1,num第一前沿面的个体数,CrowdDistance拥挤距离
function newnum=ff(f,num,CrowdDistance)
newlength=ceil(f*length(num));						%向上取整
q=0;
if newlength<=0
    newlength=1;
    q=1;
end
if q==0
[~,index]=sort(CrowdDistance(num),'descend');
newnum=num(index(1:newlength));
elseif q==1
    a=randperm(length(num));
    newnum=num(a(1));
end