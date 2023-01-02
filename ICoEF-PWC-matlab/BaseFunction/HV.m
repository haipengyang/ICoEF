function HV1=HV(ParetoFront, n)
 X = (ParetoFront(:, n + 1));
 Y = (ParetoFront(:, n + 2));

PopObj = [];
PopObj(:, 1) = double(X) / n;
temp_n = (n - 1) * n / 2;
PopObj(:,2) = double(Y) / temp_n;

PF = [1.1, 1.1];
HV1 = NHV(PopObj, PF);
end