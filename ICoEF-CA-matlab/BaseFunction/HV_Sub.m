function HV1 = HV_Sub(ParetoFront, n)
%HV_SUB 此处显示有关此函数的摘要
%   此处显示详细说明
 X = (ParetoFront(:, n + 1));
 Y = (ParetoFront(:, n + 2));
PopObj = [];
PopObj(:, 1) = double(X) / n;
PopObj(:, 2) = (2 + double(Y)) / 2;
PF = [1.1, 1.1];
HV1 = NHV(PopObj, PF);
end

