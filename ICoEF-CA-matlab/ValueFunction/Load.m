function F = Load(k, a, n)
%LOAD Ϊÿ���ڵ���为��
%   ÿ���ڵ�Ķȣ�����1Ϊ�������为��
F = zeros(1, n);
for i = 1 : n  %��ʼ������F����
    F(i) = a * (k(i)^a);
end
end
% function F=fuzai(Adj,a)
% n=length(Adj);
% for i=1:n
%     k(i)=0;
%     for j=1:n
%         k(i)=k(i)+Adj(i,j);
%     end
% end
% for i=1:n  %��ʼ������F����
%   F(i)=a*(k(i)^a);
% end
% end
