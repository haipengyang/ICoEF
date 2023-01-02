function HV1=HV(ParetoFront, n)
 X = (ParetoFront(:, n + 1));
 Y = (ParetoFront(:, n + 2));
PopObj = [];
PopObj(:, 1) = double(X) / n;
PopObj(:,2) = 1 + double(Y) / n;
PF = [1.1, 1.1];
HV1 = NHV(PopObj, PF);
end