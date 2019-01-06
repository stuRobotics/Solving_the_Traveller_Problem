close all;
clc,clear                               %清空环境中的变量
tic
iter = 1;                               %迭代次数初值
a=0.99;                                 %温度衰减系数
t0=97;                                  %初始温度
tf=3;                                   %最后温度
t=t0;
Markov=500;                           %Markov链长度
load posi.txt                          %读入城市的坐标
city=posi;
n = size(city,1);                       %城市数目
D = zeros(n,n);                                                    
for i = 1:n                             
    for j = 1:n
        D(i,j) = sqrt(sum((city(i,:) - city(j,:)).^2));    
    end    
end                                                                                
route=1:n;         %产生初始解，route是每次产生的新解                     
route_new=route;   %route_new是当前解
best_route=route;  %best_route是冷却中的最好解
Length=Inf;        %Length是当前解对应的回路距离
best_length=Inf;   %best_length是最优解

%%
while t>=tf
    for j=1:Markov
	%产生随机扰动,长成新的序列route_new;
        if (rand<0.7)
        %交换两个数的顺序
            ind1=0;ind2=0;
            while(ind1==ind2&&ind1>=ind2)
                ind1=ceil(rand*n);          %进一取整
                ind2=ceil(rand*n);
            end                      
            temp=route_new(ind1);
            route_new(ind1)=route_new(ind2);
            route_new(ind2)=temp;
        else
            %三交换
            ind=zeros(3,1);
            L_ind=length(unique(ind));
            while (L_ind<3)
                ind=ceil([rand*n rand*n rand*n]);
                L_ind=length(unique(ind));
            end
            ind0=sort(ind);
            a1=ind0(1);b1=ind0(2);c1=ind0(3);
            route0=route_new;
            route0(a1:a1+c1-b1-1)=route_new(b1+1:c1);
            route0(a1+c1-b1:c1)=route_new(a1:b1);
            route_new=route0;    
        end 
        %计算路径的距离,Length_new 
        length_new = 0;
        Route=[route_new route_new(1)];%route_new(1)指第一个城市
        for j = 1:n
            length_new = length_new+ D(Route(j),Route(j + 1));
        end
        if length_new<Length      
            Length=length_new;
            route=route_new;
            %对最优路线和距离更新
            if length_new<best_length
                iter = iter + 1;    
                best_length=length_new;
                best_route=route_new;
            end
        else
            %若新解的目标函数值大于当前解，
            %则仅以一定概率接受新解
            if rand<exp(-(length_new-Length)/t)
                route=route_new;
                Length=length_new;
            end
        end
        route_new=route; 
    end              
	t=t*a;  %控制参数t（温度）减少为原来的a倍
end

%% 结果显示 
toc
Route=[best_route best_route(1)];
xy=[(city(Route ,1)),(city(Route ,2))]
fid=fopen('save1.txt','w+');
fprintf(fid,'%g  %g\n\t\t',xy)
plot([city(Route ,1)], [city(Route ,2)],'o-');
    disp('最优解为：')
    disp(best_route)
    disp('最短距离：')
    disp(best_length)
    disp('最优解迭代次数：')
    disp(iter)

for i = 1:n
    %对每个城市进行标号
%     xy=[city(i,1),city(i,2)]
    text(city(i,1),city(i,2),['   ' num2str(i)]);
end
xlabel('城市位置横坐标')
ylabel('城市位置纵坐标')
title(['模拟退火算法(最短距离）:' num2str(best_length) ''])