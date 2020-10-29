function [ret] = MSRetinex(im, sigmaS, nscale, scalefactor, saturatedpix, precision)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Multiscale Retinex for image enhancement based on Petro, A. B., Sbert, %
% C., & Morel, J. M. (2014). Multiscale retinex. Image Processing On     %
% Line, 71-88.                                                           %
% - im is the input grayimage that estimated the image illumination or   %
% simply rgb2gray() of the color image                                   %
% - sigmaS is the size of the gaussian kernel in each scales             %
% - nscale is the number of scales                                       %
% - scalefactor is the scalefactor between each scales                   %
% - saturatedpix is 1x2 scalar vector precising the percentage of pixels %
% to be saturated in each sides                                          %
% - precision is the precision for im scaling                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% convert im to precision (8, 16 or 32 bit) scale and add 1 for log
im = double(floor((2^precision - 1).*(im - min(im(:)))./(max(im(:)) - min(im(:)))) + 1);
% process over each scale
if nscale > 1
    % pad to the next power of scalefactor
    I = ones(scalefactor^ceil(log(size(im, 1))/log(scalefactor)), scalefactor^ceil(log(size(im, 2))/log(scalefactor)));
    I(ceil(size(I, 1)/2) + (1:size(im, 1)) - ceil(size(im, 1)/2), ceil(size(I, 2)/2) + (1:size(im, 2)) - ceil(size(im, 2)/2)) = im;
    for n = 1:nscale
        if n == 1
            % convolve with gaussian kernel and pad output to the next
            % power of scalefactor
            ibl = imgaussfilt(im, sigmaS);
            Ibl = ones(size(I));
            Ibl(ceil(size(I, 1)/2) + (1:size(im, 1)) - ceil(size(im, 1)/2), ceil(size(I, 2)/2) + (1:size(im, 2)) - ceil(size(im, 2)/2)) = ibl;
            % substract it to the image
            ret = (log(I) - log(Ibl))./nscale;
        else
            % same as before but use imresize to go to the next scale
            Ibl = imresize(imgaussfilt(imresize(I, 1/(scalefactor^(n - 1))), sigmaS), scalefactor^(n - 1));
            ret = 0.5.*(ret + (log(I) - log(Ibl))./nscale);
        end
    end
    % remove spurious imaginary part due to approximation
    ret = real(ret);
    ret = exp(ret(ceil(size(I, 1)/2) + (1:size(im, 1)) - ceil(size(im, 1)/2), ceil(size(I, 2)/2) + (1:size(im, 2)) - ceil(size(im, 2)/2))) - 1;
else
    % if only one scale no need to pad
    ibl = imfilter(im, g, 'replicate');
    %ibl = imgaussfilt(im, sigmaS);
    ret = exp(log(im) - log(ibl)) - 1;
end
% rescale to [0 1]
ret = (ret - min(ret(:)))./(max(ret(:)) - min(ret(:)));
% apply the simplest color balance algorithm to get better output
s1 = saturatedpix(1)/100; % lower percentage cutoff
s2 = (100 - saturatedpix(2))/100; % upper percentage cutoff
[count, bins] = imhist(ret, min(2^precision, 1e6)); % use a maximum of 1e6 bins even if precision is set to 32bit
cumhist = cumsum(count)./numel(ret(:));
if isempty(find(cumhist < s1, 1, 'last')) && ~isempty(find(cumhist > s2, 1, 'first'))
    x = [0, bins(find(cumhist > s2, 1, 'first'))];
elseif ~isempty(find(cumhist < s1, 1, 'last')) && isempty(find(cumhist > s2, 1, 'first'))
    x = [bins(find(cumhist < s1, 1, 'last')), 2^precision - 1];
elseif isempty(find(cumhist < s1, 1, 'last')) && isempty(find(cumhist > s2, 1, 'first'))
    x = [0, 2^precision - 1];
else
    x = bins([find(cumhist < s1, 1, 'last'), find(cumhist > s2, 1, 'first')]);
end
ret(ret < x(1)) = x(1);
ret(ret > x(2)) = x(2);
% rescale ret to the precision scale
ret = floor((2^precision - 1).*(ret - min(ret(:)))./max(ret(:)));
end