%f����Ӧ�������ӳ�ʼֵΪ1,num��һǰ����ĸ�����,CrowdDistanceӵ������
function newnum=ff(f,num,CrowdDistance)
newlength=ceil(f*length(num));						%����ȡ��
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