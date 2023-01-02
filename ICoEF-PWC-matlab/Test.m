path = 'D:\Files\Code\Mine\ICoEF-PWC-matlab\Dataset\';
%path = 'D:\Files\Code\Mine\ICoEF-PWC-matlab\';
namelist = dir([path,'*.mat']);

for iii = 1 : 1
    clc;
    filename{iii} = [path,namelist(iii).name];
    example = load(filename{iii});
    example = double(example.example);
    example = sparse(example);
    [ParetoFront,T,HV1] = Main(example, iii, namelist(iii).name);
end