len = str2num(p(1,2:3)); %#ok<*ST2NM>
last = 1;
for i=2:length(p)
    if str2num(p(i,2:3)) ~= len
        sorted = sort(str2num(p(last:i-1,5:7)));
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
        p(last:i-1,5:7) = ins;
        last = i;
        len = str2num(p(i,2:3));
    end
end
sorted = sort(str2num(p(last:i,5:7)));
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
p(last:i,5:7) = ins;
