function [result_loc, time, test_loc] = IS_CellKNN()%train_data,test_data,k,RP_time_data)


[test_data, train_data, test_labels, test_loc]= FSD_cell_knn(nodesP);

time = (1:size(train_data,2));

result = cell(1,1);


%% ----------- KNN Classification -----------
testqty = size(test_data, 2);
tempcell = cell(size(train_data));

%% number of nearest neighbours
for k = 1

for i = 1:testqty
    % Check if test data conforms with train data
    if length(test_data{i}) < length(train_data{i})
        test_data{i}(end+1 : length(train_data{i})) = 0; % assign -1000 to test data
        if length(test_data{i}) > length(train_data{i})
            test_data{i}(length(train_data{i})+1 : end)= [];
        end
        
    end
    
    % first cell (i) in test_data array
    tempcell(:,:) = test_data(i); 
    % subtract tempcell from train_data and square it
    EuclideanDistancecell = cellfun(@(x,y) (x - y).^2, train_data, tempcell, 'UniformOutput', false);
    % square root the sum of euclidean distance
    EuclideanDistance = sqrt(cellfun(@sum, EuclideanDistancecell));
    % sorts the euclidean distance and stores the index of the values.
    [sorted_Euclidean, index] = sort(EuclideanDistance(:)); 

    % map linear index to subscript
    [y_index, x_index] = ind2sub(size(train_data), index); 
    
    %% Calculate the mean (used when solving for regression) KNN
if k == 1
        result{i,:} = (nodesP(x_index(1:k),:))/k;
    else
        y_knn = sum(nodesP(y_index(1:k),:)) / k; 
        x_knn = sum(nodesP(x_index(1:k),:)) / k;
        result{i,1} = x_knn;
        %result{i,2} = y_knn;
end


end


result_loc = cell2mat(result);

error_knn(k,:) = sqrt((test_loc(:,1) - result_loc(:,1)).^2 + (test_loc(:,2) - result_loc(:,2)).^2);
error_avg = mean(error_knn(k,:));
error_std = std(error_knn(k,:));
error_min = min(error_knn(k,:));
error_max = max(error_knn(k,:));
IScell_error_K(k,:) = [error_avg, error_std, error_min, error_max];

end

Y = plot(test_loc(:,1),test_loc(:,2),'ko','MarkerSize',6); axis equal;
title('Cellular Localization');
ylabel('Y coordinate (m)')
xlabel('X coordinate (m)')
hold on

X = plot(result_loc(:,1),result_loc(:,2),'rx'); axis equal;
legend([Y X], 'Original location', 'Cellular localization');
xlim([-1 65]) %fsd

% save('FSD_cell_error3_K1','error_knn');
% xlswrite('IS_cell_error',IScell_error_K)
%xlswrite('IS_cell_KNN_error',error_knn);

end