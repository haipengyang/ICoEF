function NewPopulation=F_generator(MatingPool)
new=[];
[N,M]=size(MatingPool);
for i=1:2:N    %交叉
     if rand()<0.9
         k1=MatingPool(i,:);
         k2=MatingPool(i+1,:);
         a=round(rand(1,M));
         for j=1:M
             if a(j)==1
                 k1(j)=k2(j);
             end    
         end
         new=[new;k1];
     end
end
 [N1,M1]=size(new);
  new1=[];
   for i=1:N1   %对交叉的个体进行变异
       k3=new(i,:);
        for j=1:M1
            if rand<=1/M1
               if k3(j)==0
                  k3(j)=1;
               elseif k3(j)==1
                   k3(j)=0;
               end
            end
        end    
           new1=[new1;k3];
   end
NewPopulation=single(new);
A=size(new,1);    
B=randperm(100);
NewPopulation=([NewPopulation;MatingPool(B(1:(100-A)),:)]);
end