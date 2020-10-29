function q = weightedguidedfilter(I, p, r, eps)
%   weightedguidedfilter implementation of the WGIF[1].
%	Code Implemented by Kou Fei (koufei@hotmail.com) 

%	[1] Z. Li, J. Zheng, Z. Zhu, W. Yao, and S. Wu, "Weighted guided image
%	filtering," IEEE Trans. Image Process., vol. 24, no. 1, pp. 120-129,
%	Jan. 2015.

%   - guidance image: I (should be a gray-scale/single channel image)
%   - filtering input image: p (should be a gray-scale/single channel image)
%   - local window radius: r
%   - regularization parameter: eps

[hei, wid] = size(I);
N = boxfilter(ones(hei, wid), r); % the size of each local patch; N=(2r+1)^2 except for boundary pixels.

mean_I = boxfilter(I, r) ./ N;
mean_p = boxfilter(p, r) ./ N;
mean_Ip = boxfilter(I.*p, r) ./ N;
cov_Ip = mean_Ip - mean_I .* mean_p; % this is the covariance of (I, p) in each local patch.

mean_II = boxfilter(I.*I, r) ./ N;
var_I = mean_II - mean_I .* mean_I;

r2=1;  
N2 = boxfilter(ones(hei, wid), r2); % the size of each local patch; N=(2r+1)^2 except for boundary pixels.
mean_I2 = boxfilter(I, r2) ./ N2;
mean_II2 = boxfilter(I.*I, r2) ./ N2;
var_I2 = mean_II2 - mean_I2 .* mean_I2;


eps0 = (0.001)^2;
varfinal0 = (var_I2+eps0)*sum(sum(1./(var_I2+eps0)))/(hei*wid);

a = cov_Ip ./ (var_I + eps./varfinal0); 
b = mean_p - a .* mean_I; 

mean_a = boxfilter(a, r) ./ N;
mean_b = boxfilter(b, r) ./ N;

q = mean_a .* I + mean_b; 
end