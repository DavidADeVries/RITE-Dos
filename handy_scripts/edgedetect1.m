I = PercentDiffMatrix_Conv3;
figure; imagesc(I)

BW1 = edge(I,'sobel');
BW2 = edge(I,'canny');
figure; imshow(BW1); title('Sobel Filter');
figure; imshow(BW2); title('Canny Filter');