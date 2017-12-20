function [ fdirssorted ] = fdirsort( fdirs )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

len = str2num(fdirs(1,2:3)); %#ok<*ST2NM>
last = 1;

for i=2:length(fdirs)
    if str2num(fdirs(i,2:3)) ~= len
        sorted = sort(str2num(fdirs(last:i-1,5:7)));
        ins = char(zeros(length(sorted),3));
        for j=1:length(sorted)
            if sorted(j) > 0
                if sorted(j) < 10
                    ins(j,:) = ['+0' num2str(sorted(j))];
                else
                    ins(j,:) = ['+' num2str(sorted(j))];
                end
            elseif sorted(j) == 0
                ins(j,:) = ['+00'];
            else
                if sorted(j) > -10
                    temp = num2str(sorted(j));
                    ins(j,:) = [temp(1) '0' temp(2)];
                else
                    ins(j,:) = num2str(sorted(j));
                end
            end
        end
        fdirs(last:i-1,5:7) = ins;
        last = i;
        len = str2num(fdirs(i,2:3));
    end
end

sorted = sort(str2num(fdirs(last:i,5:7)));
ins = char(zeros(length(sorted),3));

for j=1:length(sorted)
    if sorted(j) > 0
        if sorted(j) < 10
            ins(j,:) = ['+0' num2str(sorted(j))];
        else
            ins(j,:) = ['+' num2str(sorted(j))];
        end
    elseif sorted(j) == 0
        ins(j,:) = ['+00'];
    else
        if sorted(j) > -10
            temp = num2str(sorted(j));
            ins(j,:) = [temp(1) '0' temp(2)];
        else
            ins(j,:) = num2str(sorted(j));
        end
    end
end

fdirs(last:i,5:7) = ins;
fdirssorted = fdirs;

end

