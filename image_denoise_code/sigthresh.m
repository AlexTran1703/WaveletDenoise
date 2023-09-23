function [T] = sigthresh(M, level, test_matrix)
%[a,b] = size(M);
%M is only HH band
C = 0.6745;
variance = (median(abs(M(:)))/C)^2;
beta = sqrt(log(length(M)/level));
T = beta*variance/std2(test_matrix);
end
